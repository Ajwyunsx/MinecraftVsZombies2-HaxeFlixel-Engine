// Ported from: Assets/Scripts/Logic/HeldItems/IHeldItemTarget.cs (struct HeldItemTargetBlueprint)
// PORT-NOTE: C# struct 改为普通类（PORTING.md: struct → class）。
package mvz2logic.helditems;

import pvzengine.level.LevelEngine;
import pvzengine.seedpacks.SeedPack;

class HeldItemTargetBlueprint implements IHeldItemTarget
{
	public function new(level:LevelEngine, index:Int, conveyor:Bool)
	{
		Level = level;
		Index = index;
		IsConveyor = conveyor;
	}
	public function GetSeedPack():Null<SeedPack>
	{
		if (IsConveyor)
		{
			return Level.GetConveyorSeedPackAt(Index);
		}
		return Level.GetSeedPackAt(Index);
	}
	public function GetLevel():LevelEngine return Level;
	public var Level:LevelEngine;
	public var Index:Int;
	public var IsConveyor:Bool;
}
