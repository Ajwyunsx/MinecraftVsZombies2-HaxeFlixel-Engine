// Ported from: Assets/Scripts/Vanilla/GameContent/Carts/VanillaCartExt.cs
package mvz2.vanilla.carts;

import mvz2.gamecontent.carts.CartCommonBehaviour;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import unity.Vector3;

// PORT-NOTE: C# 扩展方法 → 以 Entity 为首参的静态方法（PORTING.md §扩展方法）。
class VanillaCartExt
{
    public static function CanCartCrush(cart:Entity, target:Entity):Bool
    {
        if (cart == null)
            return false;
        var bounds = cart.GetBounds();
        return target.Type != EntityTypes.BOSS && LogicEntityExt.IsVulnerableEntity(target) &&
            cart.IsHostile(target) &&
            target.ExistsAndAlive() &&
            cart.GetLane() == target.GetLane() &&
            target.Position.x >= bounds.min.x &&
            target.Position.x <= bounds.max.x;
    }
    public static function IsCartTriggered(entity:Entity):Bool
    {
        return entity.State == STATE_TRIGGERED;
    }
    public static function TriggerCart(entity:Entity):Void
    {
        entity.State = STATE_TRIGGERED;
        entity.Velocity = Vector3.right * 10;
        LogicEntityExt.PlaySoundIfNotNull(entity, VanillaCartProps.GetCartTriggerSound(entity));
        LogicEntityProps.SetCanUpdateBeforeGameStart(entity, false);
        for (behaviour in entity.Definition.GetBehaviours())
        {
            var cartBehaviour:ICartBehaviour = Std.isOfType(behaviour, ICartBehaviour) ? (cast behaviour : ICartBehaviour) : null;
            if (cartBehaviour != null)
                cartBehaviour.PostTrigger(entity);
        }
    }
    // PORT-NOTE: C# 扩展方法 → 以 Entity 为首参的静态方法（PORTING.md §扩展方法）。
    public static function ChargeUpCartTrigger(entity:Entity):Void
    {
        CartCommonBehaviour.ChargeUpTrigger(entity);
    }
    public static inline var STATE_TRIGGERED:Int = VanillaCartStates.TRIGGERED;
}
