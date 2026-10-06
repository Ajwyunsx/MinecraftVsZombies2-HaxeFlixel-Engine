// Ported from: Assets/Scripts/Engine/Tools/Unity/Serializers/Vector2Serializer.cs
package tools.bsonserializers;

import unity.Vector2;

class Vector2Serializer extends ArraySerializerBase<Vector2>
{
	override function WriteArrayValues(context:Dynamic, args:Dynamic, value:Vector2):Void
	{
		var writer = context.Writer;
		writer.WriteDouble(value.x);
		writer.WriteDouble(value.y);
	}

	override function ReadArrayValues(context:Dynamic, args:Dynamic):Vector2
	{
		var reader = context.Reader;
		var x:Float = reader.ReadDouble();
		var y:Float = reader.ReadDouble();
		return new Vector2(x, y);
	}
}
