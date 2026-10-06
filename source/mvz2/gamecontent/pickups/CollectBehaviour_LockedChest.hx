// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/LockedChestPickup/CollectBehaviour_LockedChest.cs
package mvz2.gamecontent.pickups;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2.vanilla.pickups.VanillaPickupProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.pickupCollectLockedChest)
class CollectBehaviour_LockedChest extends CollectBehaviour
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
        pickup.Velocity = Vector3.zero;
        var level = pickup.Level;

        level.ResetHeldItem();
        level.StopMusic();
        level.PlaySoundIfNotNull(pickup.GetCollectSound());
        level.PlaySound(VanillaSoundID.finalItem);
        level.Spawn(VanillaEffectID.starParticles, pickup.Position, pickup);

        LockedChestPickup.GetOrInitStateTimer(pickup).ResetSeconds(LockedChestPickup.SECONDS_TO_START_TALK);
    }
}
