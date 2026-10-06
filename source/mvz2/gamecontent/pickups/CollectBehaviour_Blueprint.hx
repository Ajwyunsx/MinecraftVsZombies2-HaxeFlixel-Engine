// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/BlueprintPickup/CollectBehaviour_Blueprint.cs
package mvz2.gamecontent.pickups;

import mvz2.gamecontent.helditems.VanillaHeldTypes;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2logic.helditems.HeldItemBuilder;
import mvz2logic.level.LogicHeldItemProps;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;
using mvz2.vanilla.pickups.VanillaPickupProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.pickupCollectBlueprint)
class CollectBehaviour_Blueprint extends CollectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function CanCollect(pickup:Entity):Bool
    {
        return true;
    }
    public override function PostCollect(pickup:Entity):Void
    {
        super.PostCollect(pickup);
        var builder = new HeldItemBuilder(VanillaHeldTypes.breakoutBoard);
        builder.SetEntityID(pickup.ID);
        pickup.Level.SetHeldItem(builder);
        pickup.PlaySoundIfNotNull(pickup.GetCollectSound());
    }
}
