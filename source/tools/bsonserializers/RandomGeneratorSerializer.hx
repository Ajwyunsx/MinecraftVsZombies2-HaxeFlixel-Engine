// Ported from: Assets/Scripts/Engine/Tools/RNG/RandomGeneratorSerializer.cs
package tools.bsonserializers;

import tools.RandomGenerator;
import tools.SerializableRNG;

class RandomGeneratorSerializer extends ArraySerializerBase<RandomGenerator>
{
	override function WriteArrayValues(context:Dynamic, args:Dynamic, value:RandomGenerator):Void
	{
		var writer = context.Writer;
		var serializable = value.ToSerializable();
		writer.WriteInt32(serializable.x);
		writer.WriteInt32(serializable.y);
		writer.WriteInt32(serializable.z);
		writer.WriteInt32(serializable.w);
	}

	override function ReadArrayValues(context:Dynamic, args:Dynamic):RandomGenerator
	{
		var reader = context.Reader;
		var x:Int = reader.ReadInt32();
		var y:Int = reader.ReadInt32();
		var z:Int = reader.ReadInt32();
		var w:Int = reader.ReadInt32();
		return RandomGenerator.FromSerializable(new SerializableRNG(x, y, z, w));
	}
}
