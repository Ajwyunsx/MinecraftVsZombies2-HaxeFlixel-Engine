// Ported from: Assets/Scripts/Engine/Level/Ticks.cs
// PORT-NOTE: C# 的 SmoothDamp 有 float / Vector2 / Vector3 三个重载，Haxe 不支持重载：
//   float 版本保留原名，Vector2 / Vector3 版本按移植层既有命名（tools/Ticks.hx 的 SmoothDampVector）分别为
//   SmoothDampVector2 / SmoothDampVector。
package pvzengine;

import unity.Mathf;
import unity.Vector2;
import unity.Vector3;

class Ticks
{
	private static var tps:Int = 30;
	public static inline var defaultTPS:Int = 30;
	public static function SetTPS(tps:Int):Void
	{
		Ticks.tps = tps;
	}
	public static function GetTPS():Int return tps;
	public static function FromTargetTPS(value:Float, targetTPS:Int = defaultTPS):Float
	{
		var multiplier = targetTPS / tps;
		return value * multiplier;
	}
	public static function FromSeconds(seconds:Float):Int
	{
		return Mathf.FloorToInt(seconds * tps);
	}
	public static function ToSeconds(ticks:Int):Float
	{
		return ticks / tps;
	}
	public static function FromPerSecond(perSecond:Float):Float
	{
		return perSecond / tps;
	}
	public static function ToPerSecond(perTick:Float):Float
	{
		return perTick * tps;
	}
	public static function SmoothDamp(current:Float, target:Float, damp:Float, targetTPS:Int = defaultTPS):Float
	{
		var newDamp = 1 - Mathf.Pow(1 - damp, targetTPS / tps);
		current += (target - current) * newDamp;
		return current;
	}
	public static function SmoothDampVector2(current:Vector2, target:Vector2, damp:Float, targetTPS:Int = defaultTPS):Vector2
	{
		var newDamp = 1 - Mathf.Pow(1 - damp, targetTPS / tps);
		current += (target - current) * newDamp;
		return current;
	}
	public static function SmoothDampVector(current:Vector3, target:Vector3, damp:Float, targetTPS:Int = defaultTPS):Vector3
	{
		var newDamp = 1 - Mathf.Pow(1 - damp, targetTPS / tps);
		current += (target - current) * newDamp;
		return current;
	}
}
