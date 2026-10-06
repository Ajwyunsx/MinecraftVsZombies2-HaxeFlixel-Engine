// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/AchievementsGlobalCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.Global;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.modding.Mod;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.entities.EntityTypes;
import mvz2logic.level.LogicStageProps;

@:modGlobalCallbacks
class AchievementsGlobalCallbacks extends VanillaGlobalCallbacks
{
    public override function Apply(mod:Mod):Void
    {
        mod.AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostContraptionDeathCallback, 0, EntityTypes.PLANT);
        mod.AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostEnemyDeathCallback, 0, EntityTypes.ENEMY);
        mod.AddTrigger(VanillaLevelCallbacks.POST_OBSIDIAN_FIRST_AID, PostAnvilObsidianFirstAidCallback, 0, VanillaContraptionID.anvil);
    }
    function PostContraptionDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var info = param.deathInfo;
        var source = info.Source;
        if (source == null)
            return;
        if (LogicEntityExt.IsHostileEntity(entity) && !LogicStageProps.IsIZombie(entity.Level))
        {
            var level = entity.Level;
            var killedByFriendlyEnemy = source.IsEntitySpawnedByEntity(level, (s, def) ->
            {
                if (!LogicEntityExt.IsFriendlyFaction(level, s.Faction))
                    return false;
                return def.Type == EntityTypes.ENEMY;
            });
            if (killedByFriendlyEnemy)
            {
                Global.Saves.Unlock(VanillaUnlockID.mesmerisedMatchup);
                Global.Saves.SaveToFile(); // 完成成就后保存游戏。
            }
        }
    }
    function PostEnemyDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var info = param.deathInfo;
        if (entity.IsEntityOf(VanillaEnemyID.skeleton) && info.Effects.HasEffect(VanillaDamageEffects.FALL_DAMAGE) && !LogicStageProps.IsIZombie(entity.Level))
        {
            Global.Saves.Unlock(VanillaUnlockID.bonebreaker);
            Global.Saves.SaveToFile(); // 完成成就后保存游戏。
        }

        var source = info.Source;
        if (source != null)
        {
            if (LogicEntityExt.IsFriendlyEntity(entity) && !LogicStageProps.IsIZombie(entity.Level))
            {
                var level = entity.Level;
                var killedByHostileContraption = source.IsEntitySpawnedByEntity(level, (s, def) -> def.Type == EntityTypes.PLANT && LogicEntityExt.IsHostileFaction(level, s.Faction));
                if (killedByHostileContraption)
                {
                    Global.Saves.Unlock(VanillaUnlockID.mesmerisedMatchup);
                    Global.Saves.SaveToFile(); // 完成成就后保存游戏。
                }
            }
        }
    }
    function PostAnvilObsidianFirstAidCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        Global.Saves.Unlock(VanillaUnlockID.reforged);
        Global.Saves.SaveToFile(); // 完成成就后保存游戏。
    }
}
