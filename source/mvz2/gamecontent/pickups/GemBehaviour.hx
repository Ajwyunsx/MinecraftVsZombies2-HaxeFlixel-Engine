// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/Gems/GemBehaviour.cs
package mvz2.gamecontent.pickups;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.pickups.VanillaPickupExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.pickups.VanillaPickupExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.gem)
class GemBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(pickup:Entity):Void
    {
        super.Update(pickup);
        pickup.SetAnimationBool("Rotating", !pickup.IsCollected() && pickup.IsOnGround);
    }
}
