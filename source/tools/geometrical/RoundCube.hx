// Ported from: Assets/Scripts/Engine/Tools/Geometry/RoundCube.cs
package tools.geometrical;

import unity.Vector3;

// PORT-NOTE: C# 的 struct 在 Haxe 中改为引用类型 class（PORTING.md §struct）。
class RoundCube
{
	public function new(center:Vector3, size:Vector3, radius:Float)
	{
		this.center = center;
		this.size = size;
		this.radius = radius;
	}
	public var center:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public var size:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public var radius:Float;
}
