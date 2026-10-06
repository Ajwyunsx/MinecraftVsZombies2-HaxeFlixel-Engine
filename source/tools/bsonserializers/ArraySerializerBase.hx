// Ported from: Assets/Scripts/Engine/Tools/BsonSerializers/ArraySerializerBase.cs
package tools.bsonserializers;

/**
 * PORT-NOTE: 原类继承 `MongoDB.Bson.Serialization.Serializers.SerializerBase<TValue>`，
 * 并依赖 `BsonSerializationContext` / `BsonDeserializationContext` / `BsonSerializationArgs` /
 * `IBsonReader` / `IBsonWriter` / `DiscriminatedWrapperSerializer<T>` / `ScalarDiscriminatorConvention`。
 * Haxe + lime/openfl 没有 MongoDB.Bson 运行时（source/mongodb 仅有极简 shim），因此：
 *   * 上下文与读写器参数类型改为 `Dynamic`，方法名与调用次序保持不变；
 *   * `DiscriminatedWrapperSerializer` / `_discriminatorConvention` 无对应实现，
 *     文档（Document）分支按 TODO-PORT 直接抛「无法从该 BsonType 反序列化」。
 */
class ArraySerializerBase<TValue>
{
	public function new() {}

	public function Serialize(context:Dynamic, args:Dynamic, value:TValue):Void
	{
		var writer = context.Writer;
		writer.WriteStartArray();
		WriteArrayValues(context, args, value);
		writer.WriteEndArray();
	}

	public function Deserialize(context:Dynamic, args:Dynamic):TValue
	{
		var reader = context.Reader;

		var bsonType = reader.GetCurrentBsonType();
		switch (bsonType)
		{
			case "Null":
				reader.ReadNull();
				return null;

			case "Array":
				reader.ReadStartArray();
				var value:TValue = ReadArrayValues(context, args);
				reader.ReadEndArray();
				return value;

			case "Document":
				// TODO-PORT: 原实现用 DiscriminatedWrapperSerializer<TValue> + ScalarDiscriminatorConvention("_t")
				// 处理多态包装文档；Haxe 侧无 BSON 序列化框架，无法还原，统一按不支持处理。
				throw "Cannot deserialize from BsonType Document.";

			default:
				throw 'Cannot deserialize from BsonType ${bsonType}.';
		}
	}
	function WriteArrayValues(context:Dynamic, args:Dynamic, value:TValue):Void
	{
		throw "abstract";
	}
	function ReadArrayValues(context:Dynamic, args:Dynamic):TValue
	{
		throw "abstract";
	}
}
