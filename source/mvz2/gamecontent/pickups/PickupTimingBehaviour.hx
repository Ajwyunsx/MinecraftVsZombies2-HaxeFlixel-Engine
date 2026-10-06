// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/Behaviours/PickupTimingBehaviour.cs
package mvz2.gamecontent.pickups;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.pickups.VanillaPickupExt;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2logic.level.LogicLevelExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2.vanilla.pickups.VanillaPickupProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.pickupTiming)
class PickupTimingBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Timeout = entity.GetMaxTimeout();
    }
    public override function Update(pickup:Entity):Void
    {
        super.Update(pickup);
        if (!pickup.IsCollected())
        {
            var level = pickup.Level;
            if (!pickup.IsImportantPickup() && pickup.Timeout >= 0)
            {
                if (!level.IsHoldingEntity(pickup))
                {
                    pickup.Timeout--;
                    if (pickup.Timeout <= 0)
                    {
                        pickup.Remove();
                    }
                }
            }
        }
        else
        {
            pickup.AddPickupCollectedTime(1);
        }
    }
}
