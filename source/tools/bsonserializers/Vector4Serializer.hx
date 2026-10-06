// Ported from: Assets/Scripts/Engine/Tools/Unity/Serializers/Vector4Serializer.cs
package tools.bsonserializers;

import unity.Vector4;

class Vector4Serializer extends ArraySerializerBase<Vector4>
{
	override function WriteArrayValues(context:Dynamic, args:Dynamic, value:Vector4):Void
	{
		var writer = context.Writer;
		writer.WriteDouble(value.x);
		writer.WriteDouble(value.y);
		writer.WriteDouble(value.z);
		writer.WriteDouble(value.w);
	}

	override function ReadArrayValues(context:Dynamic, args:Dynamic):Vector4
	{
		var reader = context.Reader;
		var x:Float = reader.ReadDouble();
		var y:Float = reader.ReadDouble();
		var z:Float = reader.ReadDouble();
		var w:Float = reader.ReadDouble();
		return new Vector4(x, y, z, w);
	}
}
