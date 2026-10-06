// Ported from: Assets/Scripts/Engine/Tools/Unity/Serializers/Vector2IntSerializer.cs
package tools.bsonserializers;

import unity.Vector2Int;

class Vector2IntSerializer extends ArraySerializerBase<Vector2Int>
{
	override function WriteArrayValues(context:Dynamic, args:Dynamic, value:Vector2Int):Void
	{
		var writer = context.Writer;
		writer.WriteInt32(value.x);
		writer.WriteInt32(value.y);
	}

	override function ReadArrayValues(context:Dynamic, args:Dynamic):Vector2Int
	{
		var reader = context.Reader;
		var x:Int = reader.ReadInt32();
		var y:Int = reader.ReadInt32();
		return new Vector2Int(x, y);
	}
}
