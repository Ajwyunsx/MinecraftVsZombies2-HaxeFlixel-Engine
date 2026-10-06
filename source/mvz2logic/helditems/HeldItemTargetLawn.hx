// Ported from: Assets/Scripts/Logic/HeldItems/IHeldItemTarget.cs (struct HeldItemTargetLawn)
// PORT-NOTE: C# struct 改为普通类（PORTING.md: struct → class）。
package mvz2logic.helditems;

import mvz2logic.level.LawnArea;
import pvzengine.level.LevelEngine;

class HeldItemTargetLawn implements IHeldItemTarget
{
	public function new(level:LevelEngine, area:LawnArea)
	{
		Level = level;
		Area = area;
	}
	public function GetLevel():LevelEngine return Level;
	public var Level:LevelEngine;
	public var Area:LawnArea;
}
