// Ported from: Assets/Scripts/Logic/HeldItems/IBlueprintHeldItemBehaviour.cs
package mvz2logic.helditems;

import pvzengine.level.LevelEngine;
import pvzengine.seedpacks.SeedPack;

interface IBlueprintHeldItemBehaviour
{
	function GetSeedPack(level:LevelEngine, data:IHeldItemData):Null<SeedPack>;
}
