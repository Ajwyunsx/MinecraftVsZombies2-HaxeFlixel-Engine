// Ported from: Assets/Scripts/Vanilla/GameContent/Carts/CartBehaviour.cs
package mvz2.gamecontent.carts;

import mvz2.vanilla.carts.ICartBehaviour;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

// PORT-NOTE: C# abstract class → Haxe class（PORTING.md §abstract）。
class CartBehaviour extends EntityBehaviourDefinition implements ICartBehaviour
{
    function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public function PostTrigger(entity:Entity):Void
    {
    }
    public function PostCrush(cart:Entity, enemy:Entity):Void
    {
    }
}
