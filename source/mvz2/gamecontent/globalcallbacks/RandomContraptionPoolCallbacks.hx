// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/RandomContraptionPoolCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2.gamecontent.placements.VanillaPlacementID;
import mvz2.vanilla.contraptions.VanillaContraptionExt;
import mvz2logic.Global;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.level.LogicAreaTags;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.modding.Mod;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.level.LevelEngine;
import mvz2logic.blueprints.LogicSeedProps;
import mvz2logic.entities.LogicContraptionProps;
import pvzengine.level.EngineAreaProps;
import pvzengine.entities.EngineEntityProps;

@:modGlobalCallbacks
class RandomContraptionPoolCallbacks extends VanillaGlobalCallbacks
{
    public override function Apply(mod:Mod):Void
    {
        mod.AddTrigger(LevelCallbacks.POST_LEVEL_START, PostLevelStartCallback);
    }
    function PostLevelStartCallback(param:LevelCallbackParams, result:CallbackResult):Void
    {
        var level = param.level;
        var pool = GetRandomContraptionPool(level);
        LogicLevelProps.SetRandomContraptionPool(level, pool);
    }
    static function GetRandomContraptionPool(level:LevelEngine):Array<NamespaceID>
    {
        var almanac = Global.Almanac;
        var results:Map<NamespaceID, Bool> = new Map();
        var unlocked = Global.Saves.GetUnlockedContraptions();
        for (contraptionID in unlocked)
        {
            var definition = level.Content.GetEntityDefinition(contraptionID);
            if (definition == null)
                continue;
            // 图鉴里没有的不出
            if (!almanac.IsContraptionInAlmanac(contraptionID))
                continue;
            // 紫卡不出
            // PORT-NOTE: C# 的 definition.IsUpgradeBlueprint()（definition 为 EntityDefinition）来自
            // LogicContraptionProps，Haxe 侧改名为 IsUpgradeBlueprintOfDefinition。
            if (LogicContraptionProps.IsUpgradeBlueprintOfDefinition(definition))
                continue;
            // 白天不出夜间器械
            if (LogicLevelExt.IsDay(level) && LogicContraptionProps.IsNocturnalOfDefinition(definition))
                continue;
            // 无水路不出水生器械
            var areaTags = EngineAreaProps.GetAreaTags(level);
            if (areaTags != null)
            {
                if (Lambda.has(areaTags, LogicAreaTags.noWater) && EngineEntityProps.GetPlacementID(definition) == VanillaPlacementID.aquatic)
                    continue;
            }
            results.set(contraptionID, true);
        }
        // PORT-NOTE: Lambda.array 收 Iterable，Map.keys() 是 Iterator（Haxe 4 下不是 Iterable），改用数组推导。
        return [for (k in results.keys()) k];
    }
}
