// Ported from: Assets/Scripts/Engine/Tools/Unity/PositionTranslator.cs
// PORT-NOTE: C# 文件名为 PositionTranslator.cs，其中定义的类名为 PositionTransition。
// 既有上层调用点（mvz2/ui/level/MovingBlueprint.hx）写的是 `import tools.PositionTransition;`，
// 且 Haxe 要求「模块名 == 主类型名」，故本文件命名为 PositionTransition.hx。
package tools;

import unity.Vector3;

@:executeInEditMode
class PositionTransition extends PositionTransitor
{
	public function new()
	{
		super();
	}

	public function SetStopDistance(stopDistance:Float):Void
	{
		_stopDistance = stopDistance;
	}
	override function Transit(start:Vector3, end:Vector3, time:Float):Vector3
	{
		var stoppedPosition = Vector3.MoveTowards(end, start, _stopDistance);
		return Vector3.Lerp(start, stoppedPosition, time);
	}
	@:serializeField
	var _stopDistance:Float = 0;
}
