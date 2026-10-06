// Ported from: Assets/Scripts/Vanilla/Frameworks/Carts/ICartBehaviour.cs
package mvz2.vanilla.carts;

import pvzengine.entities.Entity;

interface ICartBehaviour
{
    function PostTrigger(entity:Entity):Void;
    function PostCrush(entity:Entity, enemy:Entity):Void;
}
