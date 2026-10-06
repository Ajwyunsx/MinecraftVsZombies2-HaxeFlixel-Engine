// Ported from: Assets/Scripts/Engine/Tools/Math/MathTool.cs
package tools.mathematics;

import unity.Debug;
import unity.Mathf;

class MathTool
{
	public static function CycleOffset(value:Int, offset:Int, count:Int):Int
	{
		value += offset;
		if (value < 0)
		{
			value = value % count + count;
		}
		if (value >= count)
		{
			value = value % count;
		}
		return value;
	}

	// #region 抛物线
	/**
	 * 以抛物线形式进行Lerp。
	 * @param a 起始值。
	 * @param b 结束值。
	 * @param highestHeight 最大值。
	 * @param t 插值。
	 * @param isInner 结束值是否在上升阶段。
	 * @return 最终值。
	 */
	public static function LerpParabolla(a:Float, b:Float, highestHeight:Float, t:Float, ?isInner:Bool = false):Float
	{
		return GetParabollaY(0, 1, a, b, highestHeight, t, isInner);
	}

	/**
	 * 获取经过两个点的抛物线，并返回x值为variable时的y值。
	 * @param startX 点1的x值
	 * @param endX 点2的x值
	 * @param startY 点1的y值
	 * @param endY 点2的y值
	 * @param highestHeight 最大高度。
	 * @param variable 当前x值。
	 * @param isInner 点2是否在点1与对称轴之间。
	 * @return 抛物线在x值为variable时的y值。
	 */
	public static function GetParabollaY(startX:Float, endX:Float, startY:Float, endY:Float, highestHeight:Float, variable:Float, ?isInner:Bool = false):Float
	{
		var y = endY - startY;
		var x = endX - startX;

		// 当x = 0时，有无数个结果，故返回0
		if (x == 0)
		{
			//Debug.LogError("抛物线两点x轴距离为0。");
			return 0;
		}

		var k = highestHeight;

		if (k > 0)
		{
			if (y > k)
			{
				Debug.LogError("最大高度过小，无法达到y值。");
				return 0;
			}
		}
		else if (k < 0)
		{
			if (y < k)
			{
				Debug.LogError("最大高度过大，无法达到y值。");
				return 0;
			}
		}
		else
		{
			Debug.LogError("最大高度为0，无法进行运算。");
			return 0;
		}

		var h:Float;

		if (y == 0)
		{
			h = x / 2;
		}
		else
		{
			h = (k * x - Mathf.Sqrt(k * x * x * (k - y)) * (isInner ? -1 : 1)) / y;
		}

		var a = -k / h / h;
		return a * Mathf.Pow((variable - startX) - h, 2) + k + startY;
	}
	// #endregion

	// #region 数值比较
	// C#: public static void GetLessOne<TObj, TKey>(this IComparer comparer, TObj obj, ref TObj currentObj, TKey key, ref TKey currentKey)
	// PORT-NOTE: C# 的 `IComparer`（System.Collections.IComparer.Compare(object, object)）在 Haxe 中
	// 用等价的函数类型 `(a:Dynamic, b:Dynamic) -> Int` 表达；`ref` 参数改为引用对象 `{value:T}`。
	public static function GetLessOne<TObj, TKey>(comparer:Dynamic->Dynamic->Int, obj:TObj, currentObjRef:{value:TObj}, key:TKey, currentKeyRef:{value:TKey}):Void
	{
		if (key == null)
			return;
		if (currentKeyRef.value == null || currentObjRef.value == null || comparer(currentKeyRef.value, key) >= 0)
		{
			currentObjRef.value = obj;
			currentKeyRef.value = key;
		}
	}
	public static function GetGreaterOne<TObj, TKey>(comparer:Dynamic->Dynamic->Int, obj:TObj, currentObjRef:{value:TObj}, key:TKey, currentKeyRef:{value:TKey}):Void
	{
		if (key == null)
			return;
		if (currentKeyRef.value == null || currentObjRef.value == null || comparer(currentKeyRef.value, key) <= 0)
		{
			currentObjRef.value = obj;
			currentKeyRef.value = key;
		}
	}
	// #endregion
}
