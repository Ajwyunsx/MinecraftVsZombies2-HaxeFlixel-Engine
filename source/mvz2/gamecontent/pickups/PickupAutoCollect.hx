// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/Behaviours/PickupBehaviour.cs
package mvz2.gamecontent.pickups;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2logic.level.LogicStageProps;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

// PORT-NOTE: C# 扩展方法（pickup.IsCollected/CanAutoCollect/CanCollect/Collect、pickup.NoCollect/
// GetEnergyValue/GetMoneyValue、level.IsAutoCollect*）在 Haxe 侧以静态方法 + `using` 提供（PORTING.md §扩展方法）。
using mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2.vanilla.pickups.VanillaPickupProps;
using mvz2logic.level.LogicStageProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.pickupAutoCollect)
class PickupAutoCollect extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(pickup:Entity):Void
    {
        super.Update(pickup);
        if (!pickup.IsCollected() && !pickup.NoCollect())
        {
            var level = pickup.Level;
            var willAutoCollect = false;
            if (level.IsCleared)
            {
                willAutoCollect = true;
            }
            else if (level.IsAutoCollectAll())
            {
                willAutoCollect = true;
            }
            else if (pickup.GetEnergyValue() > 0 && level.IsAutoCollectEnergy())
            {
                willAutoCollect = true;
            }
            else if (pickup.GetMoneyValue() > 0 && level.IsAutoCollectMoney())
            {
                willAutoCollect = true;
            }
            else if (pickup.IsEntityOf(VanillaPickupID.starshard) && level.IsAutoCollectStarshard())
            {
                willAutoCollect = true;
            }
            if (willAutoCollect && pickup.CanAutoCollect() && pickup.CanCollect())
            {
                pickup.Collect();
            }
        }
    }
}
