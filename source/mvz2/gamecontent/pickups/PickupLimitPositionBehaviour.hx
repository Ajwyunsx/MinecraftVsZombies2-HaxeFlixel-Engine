// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/Behaviours/PickupLimitPositionBehaviour.cs
package mvz2.gamecontent.pickups;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2logic.level.LevelPositions;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Mathf;
using mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2.vanilla.pickups.VanillaPickupProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.pickupLimitPosition)
class PickupLimitPositionBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(pickup:Entity):Void
    {
        super.Update(pickup);
        if (!pickup.IsCollected() && !pickup.NoLimitInScreen())
        {
            var pos = pickup.Position;
            pos.x = Mathf.Clamp(pos.x, LevelPositions.GetPickupBorderX(false), LevelPositions.GetPickupBorderX(true));
            pos.z = Mathf.Clamp(pos.z, LevelPositions.GetPickupBorderZ(false), LevelPositions.GetPickupBorderZ(true));
            pickup.Position = pos;
        }
    }
}
