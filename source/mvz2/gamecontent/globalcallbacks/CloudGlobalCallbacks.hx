// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/CloudGlobalCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2.gamecontent.buffs.entities.AboveCloudBuff;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.modding.Mod;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import mvz2.vanilla.entities.WaterInteraction.AirInteraction;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityProps;

@:modGlobalCallbacks
class CloudGlobalCallbacks extends VanillaGlobalCallbacks
{
    public override function Apply(mod:Mod):Void
    {
        mod.AddTrigger(LevelCallbacks.POST_ENTITY_UPDATE, EntityUpdateCallback);
    }
    function EntityUpdateCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        UpdateCloud(entity);
    }
    function UpdateCloud(entity:Entity):Void
    {
        var interaction = entity.GetAirInteraction();
        var aboveCloud = VanillaEntityExt.IsAboveCloud(entity);
        var shouldHaveBuff = aboveCloud;
        if (shouldHaveBuff != entity.HasBuff(AboveCloudBuff))
        {
            if (!shouldHaveBuff && interaction == AirInteraction.FALL_OFF && entity.Position.y < entity.GetGroundY() - 20.0) // 掉下去的不能再回陆地
            {
                return;
            }
            if (shouldHaveBuff)
            {
                entity.AddBuff(AboveCloudBuff);
            }
            else
            {
                entity.RemoveBuffs(AboveCloudBuff);
            }
        }
    }
}
