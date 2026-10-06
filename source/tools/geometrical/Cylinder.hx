// Ported from: Assets/Scripts/Engine/Tools/Geometry/Cylinder.cs
package tools.geometrical;

import unity.Vector3;

// PORT-NOTE: C# 的 struct 在 Haxe 中改为引用类型 class（PORTING.md §struct）。
class Cylinder
{
	public function new(axis:Axis, center:Vector3, length:Float, radius:Float)
	{
		this.axis = axis;
		this.center = center;
		this.length = length;
		this.radius = radius;
	}
	public var axis:Axis;
	public var center:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public var length:Float;
	public var radius:Float;
}
