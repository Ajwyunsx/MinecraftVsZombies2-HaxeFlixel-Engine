// Ported from: Assets/Scripts/Engine/Tools/Unity/JsonConverters/Vector2Converter.cs
package tools;

import unity.Vector2;

// PORT-NOTE: 见 ColorConverter.hx——不再继承 Newtonsoft.Json 的 JsonConverter<T>，参数类型改为 Dynamic。
class Vector2Converter
{
	public function new() {}

	public function WriteJson(writer:Dynamic, value:Vector2, serializer:Dynamic):Void
	{
		writer.WriteStartArray();
		writer.WriteValue(value.x);
		writer.WriteValue(value.y);
		writer.WriteEndArray();
	}

	public function ReadJson(reader:Dynamic, objectType:Dynamic, existingValue:Dynamic, hasExistingValue:Bool, serializer:Dynamic):Vector2
	{
		var value:Array<Float> = serializer.Deserialize(reader);
		if (value == null)
			return Vector2.zero;
		return new Vector2(value[0], value[1]);
	}
}
