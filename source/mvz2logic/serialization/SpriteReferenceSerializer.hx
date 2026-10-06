// Ported from: Assets/Scripts/Logic/Serialization/SpriteReferenceSerializer.cs
// PORT-NOTE: 原类继承 Tools.BsonSerializers.WrappedSerializerBase<SpriteReference>（依赖 MongoDB.Bson，
// Haxe 无对应库）。此处保留原有的序列化/反序列化语义，改为不依赖第三方库的普通方法：
//   SerializeValue(value) -> 直接写出字符串或 null
//   DeserializeClassValue(text) -> 用 SpriteReference.TryParse 解析
// 调用方（SerializeHelper / MVZ2 存档代码）在移植中改用这两个方法。
package mvz2logic.serialization;

import mvz2logic.resources.SpriteReference;
import tools.Ref;

class SpriteReferenceSerializer // C#: extends WrappedSerializerBase<SpriteReference>
{
	public function new(defaultNsp:String)
	{
		this.defaultNsp = defaultNsp;
	}
	// C#: protected override void SerializeValue(BsonSerializationContext context, BsonSerializationArgs args, SpriteReference value)
	public function SerializeValue(value:SpriteReference):String
	{
		if (value == null)
		{
			return "null";
		}
		else
		{
			return value.toString();
		}
	}

	// C#: protected override SpriteReference DeserializeClassValue(BsonDeserializationContext context, BsonDeserializationArgs args)
	// TODO-PORT: C# 会读取 BSON 类型并抛出 CreateCannotDeserializeFromBsonTypeException；Haxe 中只保留字符串解析分支。
	public function DeserializeClassValue(text:String):Null<SpriteReference>
	{
		var parsed:Ref<SpriteReference> = Ref.to(null);
		if (SpriteReference.TryParse(text, defaultNsp, parsed))
		{
			return parsed.value;
		}
		return null;
	}
	private var defaultNsp:String;
}
