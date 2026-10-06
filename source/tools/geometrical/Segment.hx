// Ported from: Assets/Scripts/Engine/Tools/Geometry/Segment.cs
package tools.geometrical;

import unity.Vector3;

// 线段
// PORT-NOTE: C# 的 struct 在 Haxe 中改为引用类型 class（PORTING.md §struct）。
class Segment implements IConvexShape
{
	public function new(start:Vector3, end:Vector3)
	{
		this.start = start;
		this.end = end;
	}
	public var start:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public var end:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public function GetFarthestPointInDirection(direction:Vector3):Vector3
	{
		var dotStart = Vector3.Dot(start, direction);
		var dotEnd = Vector3.Dot(end, direction);
		return dotStart > dotEnd ? start : end;
	}
	public function GetCenter():Vector3
	{
		return (start + end) * 0.5;
	}
}
