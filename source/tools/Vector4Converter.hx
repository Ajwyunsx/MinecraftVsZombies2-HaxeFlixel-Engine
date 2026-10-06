// Ported from: Assets/Scripts/Engine/Tools/Unity/JsonConverters/Vector4Converter.cs
package tools;

import unity.Vector4;

// PORT-NOTE: 见 ColorConverter.hx——不再继承 Newtonsoft.Json 的 JsonConverter<T>，参数类型改为 Dynamic。
class Vector4Converter
{
	public function new() {}

	public function WriteJson(writer:Dynamic, value:Vector4, serializer:Dynamic):Void
	{
		writer.WriteStartArray();
		writer.WriteValue(value.x);
		writer.WriteValue(value.y);
		writer.WriteValue(value.z);
		writer.WriteValue(value.w);
		writer.WriteEndArray();
	}

	public function ReadJson(reader:Dynamic, objectType:Dynamic, existingValue:Dynamic, hasExistingValue:Bool, serializer:Dynamic):Vector4
	{
		var value:Array<Float> = serializer.Deserialize(reader);
		if (value == null)
			return Vector4.zero;
		return new Vector4(value[0], value[1], value[2], value[3]);
	}
}
