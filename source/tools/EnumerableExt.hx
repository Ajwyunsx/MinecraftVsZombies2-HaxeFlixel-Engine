// Ported from: Tools enumerable extension methods used by MVZ2 (external Tools assembly)
// PORT-NOTE: the original Tools assembly defines these as LINQ-style extension methods;
// here they are plain static helpers, called explicitly at the ported call sites.
package tools;

import pvzengine.RandomGenerator;

class EnumerableExt
{
    public static function Random<T>(items:Array<T>, rng:RandomGenerator):T
    {
        if (items == null || items.length == 0)
            return null;
        return items[rng.Next(0, items.length)];
    }

    public static function OrderBy<T, K>(items:Array<T>, key:T->K):Array<T>
    {
        var copy = items.copy();
        copy.sort(function(a, b) return Reflect.compare(key(a), key(b)));
        return copy;
    }

    public static function OrderByDescending<T, K>(items:Array<T>, key:T->K):Array<T>
    {
        var copy = items.copy();
        copy.sort(function(a, b) return Reflect.compare(key(b), key(a)));
        return copy;
    }

    public static function First<T>(items:Array<T>):T
    {
        return items == null || items.length == 0 ? null : items[0];
    }

    public static function FirstOrDefault<T>(items:Array<T>):T
    {
        return items == null || items.length == 0 ? null : items[0];
    }

    // Ported from: Tools.LinqHelper.RandomTake<T>(this IEnumerable<T>, int, RandomGenerator)
    public static function RandomTake<T>(items:Array<T>, count:Int, rng:RandomGenerator):Array<T>
    {
        if (items == null || items.length == 0)
            return [];
        var pool = items.copy();
        // PORT-NOTE: C# 用 LINQ OrderBy(rng.Next()) 随机排序后取前 count 个，此处用 Fisher-Yates 等价实现。
        for (i in 0...pool.length)
        {
            var j = rng.Next(i, pool.length);
            var tmp = pool[i];
            pool[i] = pool[j];
            pool[j] = tmp;
        }
        return pool.slice(0, pool.length < count ? pool.length : count);
    }

    // Ported from: Tools.LinqHelper.WeightedRandomTake<T>(this IEnumerable<T>, IList<int>, int, RandomGenerator)
    public static function WeightedRandomTake<T>(items:Array<T>, weights:Array<Int>, count:Int, rng:RandomGenerator):Array<T>
    {
        var result:Array<T> = [];
        if (items == null || items.length == 0)
            return result;
        var pool:Array<T> = items.copy();
        var weightPool:Array<Int> = weights.copy();
        var take = Std.int(Math.min(count, pool.length));
        for (_ in 0...take)
        {
            var total = 0;
            for (w in weightPool)
                total += w;
            if (total <= 0)
                break;
            var roll = rng.Next(0, total);
            var index = 0;
            var acc = 0;
            for (i in 0...weightPool.length)
            {
                acc += weightPool[i];
                if (roll < acc)
                {
                    index = i;
                    break;
                }
            }
            result.push(pool[index]);
            pool.splice(index, 1);
            weightPool.splice(index, 1);
        }
        return result;
    }

    // Ported from: Tools.LinqHelper.Randomize<T>(this IEnumerable<T>, RandomGenerator)
    public static function Randomize<T>(items:Array<T>, rng:RandomGenerator):Array<T>
    {
        return RandomTake(items, items.length, rng);
    }

    // C#: Take<T>(this IEnumerable<T> items, int count)
    public static function Take<T>(items:Array<T>, count:Int):Array<T>
    {
        if (items == null || count <= 0)
            return [];
        return items.slice(0, count);
    }

    // Ported from: Tools.LinqHelper.Shuffle<T>(this T[], RandomGenerator)
    public static function Shuffle<T>(items:Array<T>, rng:RandomGenerator):Void
    {
        for (i in 0...items.length)
        {
            var j = rng.Next(i, items.length);
            var tmp = items[i];
            items[i] = items[j];
            items[j] = tmp;
        }
    }
}
