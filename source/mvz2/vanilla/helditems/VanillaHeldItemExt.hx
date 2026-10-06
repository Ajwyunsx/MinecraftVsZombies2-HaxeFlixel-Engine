// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/VanillaHeldItemExt.cs
package mvz2.vanilla.helditems;

import mvz2.gamecontent.helditems.VanillaHeldTypes;
import mvz2.gamecontent.pickups.BlueprintPickup;
import mvz2logic.blueprints.LogicSeedProps;
import mvz2logic.blueprints.SeedTypes;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.LogicHeldItemExt;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;

// PORT-NOTE: C# 扩展方法 (this IHeldItemData data, LevelEngine level) 改为静态方法，data 作为第一个参数。
class VanillaHeldItemExt
{
    public static function GetSeedEntityID(data:IHeldItemData, level:LevelEngine):Null<NamespaceID>
    {
        var heldType = data.Type;
        var heldDefinition = LogicHeldItemExt.GetDefinition(data, level);
        if (heldDefinition == null)
            return null;
        if (heldType == VanillaHeldTypes.blueprintPickup)
        {
            var entity = LogicHeldItemExt.GetHoldingEntity(data, level);
            if (entity == null)
                return null;
            return BlueprintPickup.GetSeedEntityID(entity);
        }
        else
        {
            var seed = LogicHeldItemExt.GetSeedPack(heldDefinition, level, data);
            if (seed != null && LogicSeedProps.GetSeedTypeOfPack(seed) == SeedTypes.ENTITY)
            {
                return LogicSeedProps.GetSeedEntityIDOfPack(seed);
            }
            return null;
        }
    }

    private function new() {}
}
