// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/CartToMoneyGlobalCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2.vanilla.carts.VanillaCartExt;
import mvz2.vanilla.carts.VanillaCartProps;
import mvz2logic.modding.Mod;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.entities.EntityTypes;
import tools.FrameTimer;

@:modGlobalCallbacks
class CartToMoneyGlobalCallbacks extends VanillaGlobalCallbacks
{
    public override function Apply(mod:Mod):Void
    {
        mod.AddTrigger(LevelCallbacks.POST_LEVEL_CLEAR, PostLevelClearCallback);
    }
    function PostLevelClearCallback(param:LevelCallbackParams, result:CallbackResult):Void
    {
        var level = param.level;
        for (cart in level.GetEntities(EntityTypes.CART))
        {
            if (VanillaCartExt.IsCartTriggered(cart))
                continue;
            VanillaCartProps.SetTurnToMoneyTimer(cart, new FrameTimer(30 + 15 * (level.GetMaxLaneCount() - cart.GetLane())));
        }
    }
}
