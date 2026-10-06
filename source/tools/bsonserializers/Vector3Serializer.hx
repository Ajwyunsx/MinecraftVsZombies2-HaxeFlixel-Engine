// Ported from: Assets/Scripts/Engine/Tools/Unity/Serializers/Vector3Serializer.cs
package tools.bsonserializers;

import unity.Vector3;

class Vector3Serializer extends ArraySerializerBase<Vector3>
{
	override function WriteArrayValues(context:Dynamic, args:Dynamic, value:Vector3):Void
	{
		var writer = context.Writer;
		writer.WriteDouble(value.x);
		writer.WriteDouble(value.y);
		writer.WriteDouble(value.z);
	}

	override function ReadArrayValues(context:Dynamic, args:Dynamic):Vector3
	{
		var reader = context.Reader;
		var x:Float = reader.ReadDouble();
		var y:Float = reader.ReadDouble();
		var z:Float = reader.ReadDouble();
		return new Vector3(x, y, z);
	}
}
