// Ported from: Assets/Scripts/Logic/Level/LogicLevelExt.cs (class LevelSpawnPointParams)
// PORT-NOTE: C# 中 LevelSpawnPointParams 与 LogicLevelExt 同文件（namespace 级独立类）。
// 按 PORTING.md 本可作为 LogicLevelExt 模块的子类型，但 LogicLevelExt 与 LogicLevelCallbacks
// 互相引用对方的子类型（LogicLevelCallbacks.CalculateSpawnPointParams.param 依赖本类），
// Haxe 无法解析这种循环子类型引用，故拆分为独立模块以断开循环。
package mvz2logic.level;

import unity.Mathf;

class LevelSpawnPointParams
{
	public var basePoints:Float;
	public var addition:Float;
	public var multiplier:Float;
	public var power:Float;
	public var maxPoints:Float;

	public function new()
	{
	}

	public function Calculate():Float
	{
		return Mathf.Ceil(Mathf.Min(Mathf.Pow(basePoints, power) * multiplier + addition, maxPoints));
	}
}
