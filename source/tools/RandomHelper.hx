// Ported from: Assets/Scripts/Engine/Tools/RNG/RandomHelper.cs
package tools;

/**
 * C# 中本类是 `RandomGenerator` 的扩展方法集合。
 * PORT-NOTE: Haxe 无方法重载，`WeightedRandom(IEnumerable<int>)` 与 `WeightedRandom(IEnumerable<float>)`
 * 分别改名为 `WeightedRandomInt` / `WeightedRandomFloat`。
 * 由于既有调用点直接以实例方法形式调用（且未 `using tools.RandomHelper;`），
 * `NextPercent` 与 `WeightedRandom` 同时在 `RandomGenerator` 上以实例方法提供（见 RandomGenerator.hx）。
 */
class RandomHelper
{
	public static function NextPercent(rng:RandomGenerator, percent:Float, ?precision:Float = 100000):Bool
	{
		return rng.Next(100 * precision) < percent * precision;
	}
	public static function WeightedRandomInt(rng:RandomGenerator, weights:Array<Int>):Int
	{
		var count = weights == null ? 0 : weights.length;
		if (count <= 0)
			return -1;
		var totalWeight = 0;
		for (w in weights)
			totalWeight += w;
		var value:Float = rng.Next(0, totalWeight);
		for (i in 0...count)
		{
			value -= weights[i];
			if (value < 0)
			{
				return i;
			}
		}
		return -1;
	}
	public static function WeightedRandomFloat(rng:RandomGenerator, weights:Array<Float>):Int
	{
		var count = weights == null ? 0 : weights.length;
		if (count <= 0)
			return -1;
		var totalWeight = 0.0;
		for (w in weights)
			totalWeight += w;
		var value:Float = rng.Next(0, totalWeight);
		for (i in 0...count)
		{
			value -= weights[i];
			if (value < 0)
			{
				return i;
			}
		}
		return -1;
	}
	public static function GetRandomOfMostOnes<T>(rng:RandomGenerator, values:Array<T>, selector:T->Float):T
	{
		return LinqHelper.Random(LinqHelper.GetMostOnes(values, selector), rng);
	}
	public static function GetRandomOfLeastOnes<T>(rng:RandomGenerator, values:Array<T>, selector:T->Float):T
	{
		return LinqHelper.Random(LinqHelper.GetLeastOnes(values, selector), rng);
	}
}
