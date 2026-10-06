// Ported from: Assets/Scripts/Logic/Inputs/InputHelper.cs (struct PointerPositionParams)
// PORT-NOTE: C# struct 改为普通类（PORTING.md: struct → class）。
package mvz2logic.inputs;

import unity.Vector2;

class PointerPositionParams
{
	public function new()
	{
	}

	public var type:Int;
	public var button:Int;
	public var position:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
}
