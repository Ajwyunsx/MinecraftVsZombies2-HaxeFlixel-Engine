// Ported from: Assets/Scripts/Engine/Tools/Geometry/Capsule.cs
package tools.geometrical;

import unity.Mathf;
import unity.Vector3;

// PORT-NOTE: C# 的 struct 在 Haxe 中改为引用类型 class（PORTING.md §struct）。
class Capsule implements IConvexShape
{
	public function new(point0:Vector3, point1:Vector3, radius:Float)
	{
		this.point0 = point0;
		this.point1 = point1;
		this.radius = radius;
	}
	public var point0:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public var point1:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public var radius:Float;
	public function GetFarthestPointInDirection(direction:Vector3):Vector3
	{
		if (direction.sqrMagnitude <= Mathf.Epsilon)
			return point0;

		var center = Vector3.Dot(point1 - point0, direction) > 0 ? point1 : point0;
		var normalized = direction.normalized;
		return center + normalized * radius;
	}
	public function GetCenter():Vector3
	{
		return (point0 + point1) * 0.5;
	}
}
