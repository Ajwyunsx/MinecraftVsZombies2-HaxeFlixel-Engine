// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/Starshard/CollectBehaviour_Starshard.cs
package mvz2.gamecontent.pickups;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2.vanilla.pickups.VanillaPickupProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.pickupCollectStarshard)
class CollectBehaviour_Starshard extends CollectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function CanAutoCollect(pickup:Entity):Bool
    {
        return !pickup.NoAutoCollect();
    }
    public override function CanCollect(pickup:Entity):Bool
    {
        if (pickup.Level.GetStarshardCount() >= pickup.Level.GetStarshardSlotCount())
        {
            return false;
        }
        return super.CanCollect(pickup);
    }
    public override function PostCollect(pickup:Entity):Void
    {
        super.PostCollect(pickup);
        pickup.Velocity = Vector3.zero;
        pickup.Level.AddStarshardCount(1);
        pickup.SetGravity(0);
        pickup.PlaySoundIfNotNull(pickup.GetCollectSound());
    }
}
