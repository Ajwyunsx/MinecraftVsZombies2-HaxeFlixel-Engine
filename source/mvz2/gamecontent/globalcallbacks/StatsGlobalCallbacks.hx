// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/StatsGlobalCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.stats.VanillaStats;
import mvz2logic.Global;
import mvz2logic.callbacks.LogicLevelCallbacks;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.modding.Mod;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.entities.EntityTypes;
import mvz2logic.level.LogicStageProps;

@:modGlobalCallbacks
class StatsGlobalCallbacks extends VanillaGlobalCallbacks
{
    public override function Apply(mod:Mod):Void
    {
        mod.AddTrigger(LogicLevelCallbacks.POST_USE_ENTITY_BLUEPRINT, PostUseEntityBlueprintCallback);
        mod.AddTrigger(VanillaLevelCallbacks.POST_CONTRAPTION_DESTROY, PostContraptionDestroyCallback);
        mod.AddTrigger(VanillaLevelCallbacks.POST_CONTRAPTION_EVOKE, PostContraptionEvokeCallback);

        mod.AddTrigger(LevelCallbacks.POST_ENEMY_SPAWNED, PostEnemySpawnedCallback);
        mod.AddTrigger(VanillaLevelCallbacks.POST_ENEMY_NEUTRALIZE, PostEnemyNeutralizeCallback);
        mod.AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostEnemyDeathCallback, 0, EntityTypes.ENEMY);
        mod.AddTrigger(LevelCallbacks.POST_GAME_OVER, PostGameOverCallback);
    }
    function PostUseEntityBlueprintCallback(param:PostUseEntityBlueprintParams, callbackResult:CallbackResult):Void
    {
        var output = param.placeOutput;
        var entity = output.entity;
        if (entity == null)
            return;
        var seed = param.blueprint;
        var definition = param.definition;
        var heldData = param.heldData;
        var level = entity.Level;
        if (LogicStageProps.IsIZombie(level))
        {
            if (entity.Type == EntityTypes.ENEMY)
            {
                Global.Saves.AddStat(VanillaStats.CATEGORY_IZ_ENEMY_PLACE, entity.GetDefinitionID(), 1);
            }
        }
        else
        {
            if (entity.Type == EntityTypes.PLANT)
            {
                Global.Saves.AddStat(VanillaStats.CATEGORY_CONTRAPTION_PLACE, entity.GetDefinitionID(), 1);
            }
        }
    }
    function PostContraptionDestroyCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        if (LogicStageProps.IsIZombie(entity.Level))
        {
            Global.Saves.AddStat(VanillaStats.CATEGORY_IZ_CONTRAPTION_DESTROY, entity.GetDefinitionID(), 1);
        }
        else
        {
            Global.Saves.AddStat(VanillaStats.CATEGORY_CONTRAPTION_DESTROY, entity.GetDefinitionID(), 1);
        }
    }
    function PostContraptionEvokeCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        Global.Saves.AddStat(VanillaStats.CATEGORY_CONTRAPTION_EVOKE, entity.GetDefinitionID(), 1);
    }
    function PostEnemySpawnedCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        if (!LogicStageProps.IsIZombie(entity.Level))
        {
            Global.Saves.AddStat(VanillaStats.CATEGORY_ENEMY_SPAWN, entity.GetDefinitionID(), 1);
        }
    }
    function PostEnemyNeutralizeCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        if (!LogicStageProps.IsIZombie(entity.Level))
        {
            if (LogicEntityExt.IsFriendlyEntity(entity))
                return;
            Global.Saves.AddStat(VanillaStats.CATEGORY_ENEMY_NEUTRALIZE, entity.GetDefinitionID(), 1);
        }
    }
    function PostEnemyDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        if (LogicStageProps.IsIZombie(entity.Level))
        {
            Global.Saves.AddStat(VanillaStats.CATEGORY_IZ_ENEMY_DEATH, entity.GetDefinitionID(), 1);
        }
    }
    function PostGameOverCallback(param:PostGameOverParams, result:CallbackResult):Void
    {
        var killer = param.killer;
        var level = param.level;
        if (LogicStageProps.IsIZombie(level))
        {
            Global.Saves.AddStat(VanillaStats.CATEGORY_IZ_GAME_OVER, level.StageID, 1);
        }
        else
        {
            if (killer != null)
            {
                Global.Saves.AddStat(VanillaStats.CATEGORY_ENEMY_GAME_OVER, killer.GetDefinitionID(), 1);
            }
        }
    }
}
