// Ported from: Assets/Scripts/Engine/Tools/Math/Transitions.cs
package tools.mathematics;

import unity.Mathf;

class Transitions
{
	// #region 过渡渐变
	public static function EaseIn(x:Float):Float
	{
		x = Mathf.Clamp01(x);
		return Mathf.Pow(x, 2);
	}
	public static function EaseOut(x:Float):Float
	{
		x = Mathf.Clamp01(x);
		return 1 - Mathf.Pow(x - 1, 2);
	}
	public static function EaseInAndOut(x:Float):Float
	{
		x = Mathf.Clamp01(x);
		if (x < 0.5)
		{
			return EaseIn(2 * x) * 0.5;
		}
		else
		{
			return EaseOut((2 * x - 1)) * 0.5 + 0.5;
		}
	}
	// #endregion
}
