// Ported from: Assets/Scripts/Engine/Tools/LinqHelper.cs
package tools;

/**
 * C# 中本类是 LINQ 风格扩展方法集合（`IEnumerable<T>` → Haxe `Array<T>`）。
 * PORT-NOTE: Haxe 无方法重载，凡 C# 中以 int / float 两种权重类型重载的成员，
 * 与既有调用点保持一致的做法是：参数声明为 `Array<Dynamic>`（Haxe 允许 Array<Int>/Array<Float>
 * 统一到 Array<Dynamic>），在运行期按元素类型分流；单权重取值函数版本另起名字（WeightedRandomInt）。
 */
class LinqHelper
{
	// C#: public static T Random<T>(this IEnumerable<T> list, RandomGenerator rng)
	public static function Random<T>(items:Array<T>, rng:RandomGenerator):T
	{
		var index:Int = rng.Next(0, items.length);
		return items[index];
	}
	// C#: public static IEnumerable<T> RandomTake<T>(this IEnumerable<T> list, int count, RandomGenerator rng)
	// PORT-NOTE: 返回 Array<T>（Haxe 中 IEnumerable<T> → Array<T>）。
	public static function RandomTake<T>(items:Array<T>, count:Int, ?rng:RandomGenerator = null):Array<T>
	{
		var results:Array<T> = [];
		var pool:Array<T> = items.copy();
		for (i in 0...count)
		{
			var poolCount = pool.length;
			if (poolCount <= 0)
				break;
			var index:Int = rng.Next(0, poolCount);
			var element = pool[index];
			results.push(element);
			pool.remove(element);
		}
		return results;
	}
	// C#: public static T WeightedRandom<T>(this IEnumerable<T> list, Func<T, int> weightGetter, RandomGenerator rng)
	// PORT-NOTE: C# 重载名同为 WeightedRandom，此处按权重取值函数类型改名为 WeightedRandomInt。
	public static function WeightedRandomInt<T>(items:Array<T>, weightGetter:T->Int, rng:RandomGenerator):T
	{
		var count = items.length;
		if (count <= 0)
			throw "The list to get weighted random element is empty.";
		var weights:Array<Int> = [for (item in items) weightGetter(item)];
		var totalWeight = 0;
		for (w in weights)
			totalWeight += w;
		var value:Float = rng.Next(0, totalWeight);
		for (i in 0...count)
		{
			value -= weights[i];
			if (value <= 0)
			{
				return items[i];
			}
		}
		throw "The list to get weighted random element ran out.";
	}
	// C#: public static T WeightedRandom<T>(this IEnumerable<T> list, Func<T, float> weightGetter, RandomGenerator rng)
	public static function WeightedRandom<T>(items:Array<T>, weightGetter:T->Float, rng:RandomGenerator):T
	{
		var count = items.length;
		if (count <= 0)
			throw "The list to get weighted random element is empty.";
		var weights:Array<Float> = [for (item in items) weightGetter(item)];
		var index = rng.WeightedRandom(weights);
		return items[index];
	}
	// C#: public static IEnumerable<T> WeightedRandomTake<T>(this IEnumerable<T> list, IList<int> weights, int count, RandomGenerator rng)
	//     public static IEnumerable<T> WeightedRandomTake<T>(this IEnumerable<T> list, IList<float> weights, int count, RandomGenerator rng)
	// PORT-NOTE: 两个重载合并；既有调用点既传 Array<Int> 也传 Array<Float>，运行期分流。
	public static function WeightedRandomTake<T>(items:Array<T>, weights:Array<Dynamic>, count:Int, rng:RandomGenerator):Array<T>
	{
		var results:Array<T> = [];

		var pool:Array<T> = items.copy();
		var weightPool:Array<Float> =
			if (anyInt(weights)) [for (w in weights) (cast(w, Int) : Float)]
			else [for (w in weights) cast(w, Float)];
		for (i in 0...count)
		{
			if (pool.length <= 0 || weights.length <= 0)
				break;
			var index = rng.WeightedRandom(weightPool);
			var element = pool[index];

			results.push(element);

			pool.splice(index, 1);
			weightPool.splice(index, 1);
		}
		return results;
	}
	// C#: public static IEnumerable<T> Randomize<T>(this IEnumerable<T> list, RandomGenerator rng)
	public static function Randomize<T>(items:Array<T>, rng:RandomGenerator):Array<T>
	{
		return RandomTake(items, items.length, rng);
	}
	// C#: public static void Shuffle<T>(this T[] array, RandomGenerator rng)
	public static function Shuffle<T>(array:Array<T>, rng:RandomGenerator):Void
	{
		if (array.length <= 1)
			return;

		var i = array.length - 1;
		while (i > 0)
		{
			var j:Int = rng.Next(i + 1);
			var tmp = array[i];
			array[i] = array[j];
			array[j] = tmp;
			i--;
		}
	}
	// C#: public static IEnumerable<T> TakeWhileLast<T>(this IEnumerable<T> list, Func<T, bool> predicate)
	public static function TakeWhileLast<T>(items:Array<T>, predicate:T->Bool):Array<T>
	{
		var reversed = items.copy();
		reversed.reverse();
		var result:Array<T> = [];
		for (item in reversed)
		{
			if (!predicate(item))
				break;
			result.push(item);
		}
		result.reverse();
		return result;
	}

	// #region 极端值
	// C#: public static IEnumerable<float> GetMostOnes(this IEnumerable<float> targets)
	public static function GetMostOnesOfFloats(targets:Array<Float>):Array<Float>
	{
		return GetExtremeOnes(targets, v -> v, (current, max) -> current > max, Math.NEGATIVE_INFINITY);
	}
	// C#: public static IEnumerable<float> GetLeastOnes(this IEnumerable<float> targets)
	public static function GetLeastOnesOfFloats(targets:Array<Float>):Array<Float>
	{
		return GetExtremeOnes(targets, v -> v, (current, max) -> current < max, Math.POSITIVE_INFINITY);
	}
	// C#: public static IEnumerable<T> GetMostOnes<T>(this IEnumerable<T> targets, Func<T, float> selector)
	public static function GetMostOnes<T>(targets:Array<T>, selector:T->Float):Array<T>
	{
		return GetExtremeOnes(targets, selector, (current, max) -> current > max, Math.NEGATIVE_INFINITY);
	}
	// C#: public static IEnumerable<T> GetLeastOnes<T>(this IEnumerable<T> targets, Func<T, float> selector)
	public static function GetLeastOnes<T>(targets:Array<T>, selector:T->Float):Array<T>
	{
		return GetExtremeOnes(targets, selector, (current, max) -> current < max, Math.POSITIVE_INFINITY);
	}
	private static function GetExtremeOnes<T>(targets:Array<T>, selector:T->Float, comparer:Float->Float->Bool, initialValue:Float):Array<T>
	{
		var bestItems:Array<T> = [];
		var extremeValue = initialValue;

		for (item in targets)
		{
			var value = selector(item);
			if (comparer(value, extremeValue))
			{
				extremeValue = value;
				bestItems.resize(0);
				bestItems.push(item);
			}
			else if (value == extremeValue)
			{
				bestItems.push(item);
			}
		}

		return bestItems;
	}
	// #endregion

	private static function anyInt(values:Array<Dynamic>):Bool
	{
		for (v in values)
		{
			if (!Std.isOfType(v, Int))
				return false;
		}
		return true;
	}
}
