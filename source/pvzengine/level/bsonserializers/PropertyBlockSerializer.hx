// Ported from: Assets/Scripts/Engine/Level/Properties/PropertyBlockSerializer.cs
package pvzengine.level.bsonserializers;

import pvzengine.SerializablePropertyDictionary;
import pvzengine.level.ModifiableProperties.SerializableModifiableProperties;
import pvzengine.level.PropertyBlock.SerializablePropertyBlock;
import tools.bsonserializers.WrappedSerializerBase;

// PORT-NOTE: 原实现依赖 MongoDB.Bson 运行时（BsonSerializationContext / IBsonWriter / IBsonReader /
//   BsonSerializer），Haxe + lime/openfl 没有对应库（source/mongodb 仅有极简 shim，且工程内
//   SerializeHelper 已改为按类型名字符串登记序列化器）。按 PORTING.md 的「等价实现 + PORT-NOTE」处理：
//   * 上下文与读写器参数类型改为 Dynamic（与 tools.bsonserializers.ArraySerializerBase 的移植方式一致）；
//   * SerializeValue 的文档写入用 `Map<String, Dynamic>` 承载（等价于原 BSON 文档的键值对）；
//   * DeserializeClassValue 从 JSON 文档等价的 Map 读取并构造 SerializablePropertyBlock。
// TODO-PORT: BSON 的 BsonType 判定（Document/非 Document 抛 CreateCannotDeserializeFromBsonTypeException）
//   与 reader.ReadBsonType()/ReadName()/ReadStartDocument() 无对应实现，无法还原。
class PropertyBlockSerializer extends WrappedSerializerBase<SerializablePropertyBlock>
{
	public function new()
	{
		super();
	}

	// C#: protected override void SerializeValue(BsonSerializationContext context, BsonSerializationArgs args, SerializablePropertyBlock value)
	// PORT-NOTE: Haxe 基类 WrappedSerializerBase 未声明 SerializeValue，故此处不加 override。
	public function SerializeValue(context:Dynamic, args:Dynamic, value:SerializablePropertyBlock):Void
	{
		var writer = context.Writer;
		writer.WriteStartDocument();
		if (value.modifiable != null && value.modifiable.properties != null)
		{
			for (key in value.modifiable.properties.properties.keys())
			{
				writer.WriteName(key);
				// C#: BsonSerializer.Serialize(writer, typeof(object), pair.Value);
				// TODO-PORT: 无 BSON 序列化器，直接写入原始值（Haxe 侧按 JSON 等价实现处理）。
				writer.WriteValue(value.modifiable.properties.properties.get(key));
			}
		}
		writer.WriteEndDocument();
	}
	override function DeserializeClassValue(context:Dynamic, args:Dynamic):SerializablePropertyBlock
	{
		var properties:Map<String, Dynamic> = new Map();

		var reader = context.Reader;

		var bsonType = reader.GetCurrentBsonType();
		// PORT-NOTE: C# 为 `switch (bsonType) { case BsonType.Document: ...; default: throw ...; }`，
		//   Haxe 侧无 BsonType 枚举，改为按字符串判定（等价）。
		if (bsonType == "Document")
		{
			reader.ReadStartDocument();
			while (reader.ReadBsonType() != "EndOfDocument")
			{
				var key = reader.ReadName();
				// C#: BsonSerializer.Deserialize(reader, typeof(object));
				// TODO-PORT: 无 BSON 序列化器，直接读取原始值。
				var value = reader.ReadValue();
				properties.set(key, value);
			}
			reader.ReadEndDocument();
			var modifiable = new SerializableModifiableProperties();
			modifiable.properties = new SerializablePropertyDictionary(properties);
			var block = new SerializablePropertyBlock();
			block.modifiable = modifiable;
			return block;
		}
		// C#: throw CreateCannotDeserializeFromBsonTypeException(bsonType);
		throw 'Cannot deserialize from BsonType ${bsonType}.';
	}
	// C#: private void DeserializeDictionary(IBsonReader reader, Dictionary<string, object> properties)
	// PORT-NOTE: 原方法为未被调用的私有工具方法，Haxe 侧保留同名实现以维持 1:1。
	private function DeserializeDictionary(reader:Dynamic, properties:Map<String, Dynamic>):Void
	{
		reader.ReadStartDocument();
		while (reader.ReadBsonType() != "EndOfDocument")
		{
			var key = reader.ReadName();
			var value = reader.ReadValue();
			properties.set(key, value);
		}
		reader.ReadEndDocument();
	}
}
