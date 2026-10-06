// Ported from: Assets/Scripts/Engine/Tools/Geometry/RoundRect.cs
package tools.geometrical;

import unity.Vector2;

// PORT-NOTE: C# 的 struct 在 Haxe 中改为引用类型 class（PORTING.md §struct）。
class RoundRect
{
	public function new(center:Vector2, size:Vector2, radius:Float)
	{
		this.center = center;
		this.size = size;
		this.radius = radius;
	}
	public var center:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public var size:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public var radius:Float;
}
