// Ported from: Assets/Scripts/Logic/HeldItems/IHeldItemTarget.cs (struct HeldItemTargetGrid)
// PORT-NOTE: C# struct 改为普通类（PORTING.md: struct → class）。
package mvz2logic.helditems;

import pvzengine.grids.LawnGrid;
import pvzengine.level.LevelEngine;
import unity.Vector2;
import unity.Vector3;

class HeldItemTargetGrid implements IHeldItemTarget
{
	public function new(target:LawnGrid, localPointerPosition:Vector2, screenPosition:Vector3)
	{
		Target = target;
		LocalPointerPosition = localPointerPosition;
		ScreenPosition = screenPosition;
	}
	public function GetLevel():LevelEngine return Target.Level;
	public var Target:LawnGrid;
	public var LocalPointerPosition:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public var ScreenPosition:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
}
