// Ported from: Assets/Scripts/Engine/Tools/Unity/JsonConverters/ColorConverter.cs
package tools;

import unity.Color;

/**
 * PORT-NOTE: 原类继承 `Newtonsoft.Json.JsonConverter<Color>`。Haxe 侧没有 Newtonsoft.Json 运行时
 * （source/newtonsoft 仅有极简 shim），故不再继承，`JsonWriter`/`JsonReader`/`JsonSerializer` 参数
 * 改为 `Dynamic`，`ReadJson` 的 `objectType/existingValue/hasExistingValue` 保留为多态签名。
 */
class ColorConverter
{
	public function new() {}

	public function WriteJson(writer:Dynamic, value:Color, serializer:Dynamic):Void
	{
		writer.WriteStartArray();
		writer.WriteValue(value.r);
		writer.WriteValue(value.g);
		writer.WriteValue(value.b);
		writer.WriteValue(value.a);
		writer.WriteEndArray();
	}

	public function ReadJson(reader:Dynamic, objectType:Dynamic, existingValue:Dynamic, hasExistingValue:Bool, serializer:Dynamic):Color
	{
		var value:Array<Float> = serializer.Deserialize(reader);
		if (value == null)
			return Color.clear;
		return new Color(value[0], value[1], value[2], value[3]);
	}
}
