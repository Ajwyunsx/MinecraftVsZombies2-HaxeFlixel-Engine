// Ported from: Assets/Scripts/Engine/Tools/RNG/RandomGenerator.cs
package tools;

/**
 * C# 的 `RandomGenerator` 使用 XORShift128 生成器。
 * Haxe 无方法重载，C# 的 5 个 `Next` 重载合并为 `Next(?min, ?max)`：
 * 实参全部为整数时走 `NextIntRange`（返回 Int），任一为浮点时走 `NextFloatRange`（返回 Float），
 * 与 C# 的重载决议规则（按静态类型选择）在本代码库的调用点下一致。
 */
class RandomGenerator
{
	public function new(seed:Int)
	{
		if (seed == 0)
			seed = -1;
		generator = new XORShift128();
		generator.InitSeed(seed);
	}

	// C#: private RandomGenerator(int x, int y, int z, int w)
	// PORT-NOTE: Haxe 无重载构造函数，原私有构造函数改为静态工厂 fromState。
	public static function fromState(x:Int, y:Int, z:Int, w:Int):RandomGenerator
	{
		var result = new RandomGenerator(0);
		result.generator = new XORShift128();
		result.generator.InitState(x, y, z, w);
		return result;
	}

	// C#: public int Next()
	public function NextInt():Int
	{
		return generator.NextInt();
	}
	// C#: public float NextFloat()
	public function NextFloat():Float
	{
		return generator.NextFloat();
	}

	// C#: public int Next() / public int Next(int max) / public float Next(float max)
	//     public int Next(int min, int max) / public float Next(float min, float max)
	public function Next(?min:Dynamic = null, ?max:Dynamic = null):Dynamic
	{
		if (max == null)
		{
			if (min == null)
			{
				// C#: Next() → generator.NextInt()
				return generator.NextInt();
			}
			// C#: Next(max) → Next(0, max)
			max = min;
			min = 0;
		}
		var minIsInt = Std.isOfType(min, Int);
		var maxIsInt = Std.isOfType(max, Int);
		if (minIsInt && maxIsInt)
			return generator.NextIntRange(cast(min, Int), cast(max, Int));
		return generator.NextFloatRange(cast(min, Float), cast(max, Float));
	}

	public function ToSerializable():SerializableRNG
	{
		// C#: return new SerializableRNG(generator);
		return SerializableRNG.fromGenerator(generator);
	}

	public static function FromSerializable(seri:SerializableRNG):RandomGenerator
	{
		return fromState(seri.x, seri.y, seri.z, seri.w);
	}

	// ------------------------------------------------------------------ 兼容成员
	// PORT-NOTE: 以下两个方法在 C# 中位于 Tools.RandomHelper 的扩展方法
	// （`rng.NextPercent(...)` / `rng.WeightedRandom(...)`）。既有上层调用点以实例方法形式调用
	// 且未 `using tools.RandomHelper;`，故在此内联为实例方法（参数语义保持不变）。

	// C#: public static bool NextPercent(this RandomGenerator rng, float percent, float precision = 100000)
	public function NextPercent(percent:Float, ?precision:Float = 100000):Bool
	{
		return Next(0, 100 * precision) < percent * precision;
	}

	// C#: public static int WeightedRandom(this RandomGenerator rng, IEnumerable<int> weights)
	//     public static int WeightedRandom(this RandomGenerator rng, IEnumerable<float> weights)
	// PORT-NOTE: Haxe 无重载，两个重载按权重元素的实际类型在运行期分流。
	public function WeightedRandom(weights:Array<Dynamic>):Int
	{
		var count = weights == null ? 0 : weights.length;
		if (count <= 0)
			return -1;
		var allInt = true;
		for (w in weights)
		{
			if (!Std.isOfType(w, Int))
			{
				allInt = false;
				break;
			}
		}
		if (allInt)
		{
			var totalWeight = 0;
			for (w in weights)
				totalWeight += cast(w, Int);
			var value:Float = Next(0, totalWeight);
			for (i in 0...count)
			{
				value -= cast(weights[i], Int);
				if (value < 0)
					return i;
			}
			return -1;
		}
		else
		{
			var totalWeight = 0.0;
			for (w in weights)
				totalWeight += cast(w, Float);
			var value:Float = Next(0, totalWeight);
			for (i in 0...count)
			{
				value -= cast(weights[i], Float);
				if (value < 0)
					return i;
			}
			return -1;
		}
	}

	private var generator:XORShift128;
}
