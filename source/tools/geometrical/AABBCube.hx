// Ported from: Assets/Scripts/Engine/Tools/Geometry/AABBCube.cs
package tools.geometrical;

import unity.Bounds;
import unity.Vector3;

// 立方体（轴对齐）
// PORT-NOTE: C# 的 struct 在 Haxe 中改为引用类型 class（PORTING.md §struct）。
class AABBCube implements IConvexShape
{
	public function new(bounds:Bounds)
	{
		this.bounds = bounds;
	}
	public var bounds:Bounds = new Bounds(); // PORT-NOTE: C# Bounds 为 struct，default 为零包围盒；显式初始化避免 abstract-over-class 的 null 解引用
	public function GetFarthestPointInDirection(direction:Vector3):Vector3
	{
		var bmin = bounds.min;
		var bmax = bounds.max;
		return new Vector3(
			direction.x > 0 ? bmax.x : bmin.x,
			direction.y > 0 ? bmax.y : bmin.y,
			direction.z > 0 ? bmax.z : bmin.z
		);
	}
	public function GetCenter():Vector3
	{
		return bounds.center;
	}
}
