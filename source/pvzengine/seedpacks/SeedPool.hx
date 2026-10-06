// Ported from: Assets/Scripts/Engine/Level/SeedPacks/SeedPool.cs
// PORT-NOTE: C# 抛出的 ArgumentException / InvalidOperationException / NullReferenceException 在 Haxe 中
//   以字符串抛出（保留原文），无对应异常类型。
package pvzengine.seedpacks;

import pvzengine.NamespaceID;
import unity.Mathf;

class SeedPool
{
	// #region 属性
	public var TypeCount(get, never):Int;
	// PORT-NOTE: C# `cardMaxCounts.Count` → Haxe Map 不是 Iterable，Lambda.count 不适用，改为显式计数。
	inline function get_TypeCount():Int
	{
		var n = 0;
		for (_ in cardMaxCounts.keys())
			n++;
		return n;
	}
	private var cardMaxCounts:Map<NamespaceID, Int> = new Map();
	// PORT-NOTE: C# 的 protected 字段在 Haxe 中改用 private（Haxe 无 protected；private 对子类可见）。
	private var cardCounts:Map<NamespaceID, Int> = new Map();
	// #endregion 属性

	// #region 构造器
	public function new()
	{
	}
	// #endregion 构造器

	// #region 方法
	public function Contains(id:NamespaceID):Bool return cardMaxCounts.exists(id);

	public function Add(id:NamespaceID, maxCount:Int):Void
	{
		if (Contains(id))
		{
			throw 'Attempting to add a card ${id} that is already in the Card Pool.';
		}
		cardMaxCounts.set(id, maxCount);
		cardCounts.set(id, maxCount);
	}

	public function Remove(id:NamespaceID):Void
	{
		if (!Contains(id))
		{
			throw 'Attempting to remove a non-exitsing card ${id} from the Card Pool.';
		}
		cardMaxCounts.remove(id);
		cardCounts.remove(id);
	}
	public function Clear():Void
	{
		cardMaxCounts.clear();
		cardCounts.clear();
	}

	public function Put(id:NamespaceID, count:Int):Void
	{
		var maxCount = cardMaxCounts.get(id);
		var added = cardCounts.get(id) + count;
		if (added > maxCount)
		{
			throw 'Cards of ${id} in this Card Pool is full.';
		}
		cardCounts.set(id, added);
	}
	public function GetCardPoolSum():Int
	{
		var sum = 0;
		for (key in cardCounts.keys())
		{
			var count = Mathf.MaxInt(1, cardCounts.get(key));
			sum += count;
		}
		return sum;
	}
	public function Draw(cardIndex:Int):NamespaceID
	{
		var sum = 0;
		for (key in cardCounts.keys())
		{
			var count = Mathf.MaxInt(1, cardCounts.get(key));
			sum += count;

			if (sum > cardIndex)
			{
				cardCounts.set(key, cardCounts.get(key) - 1);
				return key;
			}
		}
		throw 'Can\'t draw cards in this Card Pool.';
	}
	public function toString():String
	{
		var str = "";
		for (defRef in cardMaxCounts.keys())
		{
			str += '${defRef}: ${cardCounts.get(defRef)}/${cardMaxCounts.get(defRef)};';
		}
		return str;
	}
	// #endregion 方法
}
