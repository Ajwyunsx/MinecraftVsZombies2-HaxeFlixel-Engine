// Ported from: Assets/Scripts/Vanilla/Frameworks/Carts/VanillaCartProps.cs
package mvz2.vanilla.carts;

import pvzengine.NamespaceID;
import pvzengine.PropertyMeta;
import pvzengine.PropertyRegions;
import pvzengine.entities.Entity;
import tools.FrameTimer;

@:propertyRegistryRegion(PropertyRegions.entity)
class VanillaCartProps
{
    public static var CART_TRIGGER_SOUND:PropertyMeta<NamespaceID> = new PropertyMeta<NamespaceID>("cartTriggerSound");
    public static var TURN_TO_MONEY_TIMER:PropertyMeta<FrameTimer> = new PropertyMeta<FrameTimer>("turnToMoneyTimer");
    public static function SetTurnToMoneyTimer(cart:Entity, timer:FrameTimer):Void cart.SetProperty(TURN_TO_MONEY_TIMER, timer);
    public static function GetTurnToMoneyTimer(cart:Entity):Null<FrameTimer> return cart.GetProperty(TURN_TO_MONEY_TIMER);
    public static function SetCartTriggerSound(entity:Entity, value:NamespaceID):Void entity.SetProperty(CART_TRIGGER_SOUND, value);
    public static function GetCartTriggerSound(entity:Entity):Null<NamespaceID> return entity.GetProperty(CART_TRIGGER_SOUND);
}
