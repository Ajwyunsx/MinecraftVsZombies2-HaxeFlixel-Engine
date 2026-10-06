// Ported from: Assets/Scripts/Engine/Tools/Unity/Serializers/ColorSerializer.cs
package tools.bsonserializers;

import unity.Color;
import unity.ColorUtility;

/**
 * PORT-NOTE: 原类继承 `MongoDB.Bson.Serialization.Serializers.StructSerializerBase<Color>`。
 * Haxe 侧没有 MongoDB.Bson 运行时，故不再继承，上下文参数改为 `Dynamic`，方法名与逻辑保持不变。
 */
class ColorSerializer
{
	public function new() {}

	public function Serialize(context:Dynamic, args:Dynamic, value:Color):Void
	{
		var writer = context.Writer;
		var code = ColorUtility.ToHtmlStringRGBA(value);
		writer.WriteString('#${code}');
	}

	public function Deserialize(context:Dynamic, args:Dynamic):Color
	{
		var reader = context.Reader;
		var code:String = reader.ReadString();
		var color = {value: Color.clear};
		if (ColorUtility.TryParseHtmlString(code, color))
		{
			return color.value;
		}
		return Color.clear;
	}
}
