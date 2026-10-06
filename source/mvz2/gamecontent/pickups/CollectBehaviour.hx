// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/Collectible/CollectBehaviour.cs
package mvz2.gamecontent.pickups;

import mvz2.vanilla.pickups.ICollectBehaviour;
import mvz2.vanilla.pickups.VanillaPickupProps;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.pickups.VanillaPickupProps;

// abstract
class CollectBehaviour extends EntityBehaviourDefinition implements ICollectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public function CanAutoCollect(pickup:Entity):Bool
    {
        return !pickup.NoAutoCollect() && pickup.IsOnGround;
    }
    public function CanCollect(pickup:Entity):Bool
    {
        return true;
    }
    public function PostCollect(pickup:Entity):Void
    {
    }
}
