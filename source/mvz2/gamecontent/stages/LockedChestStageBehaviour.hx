// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/FinalClear/LockedChestStageBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.pickups.LockedChestPickup;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.gamecontent.progressbars.VanillaProgressBarID;
import mvz2.vanilla.level.VanillaLevelStates;
import pvzengine.entities.EntityTypes;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LevelPositions;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageDefinition;
import unity.Mathf;
import unity.Vector3;

class LockedChestStageBehaviour extends BossStageBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
    }
    override public function PostWave(level:LevelEngine, wave:Int):Void
    {
        super.PostWave(level, wave);
        if (wave <= 10 || wave >= level.GetTotalWaveCount())
            return;
        if (!level.EntityExists(VanillaEffectID.soulStorm))
        {
            var pos = level.GetLawnCenter();
            pos.x = 0;
            level.Spawn(VanillaEffectID.soulStorm, pos, null);
        }
    }
    override public function FinalWaveUpdate(level:LevelEngine):Void
    {
        super.FinalWaveUpdate(level);
        var lastEnemy = LogicLevelExt.GetFirstAliveEnemy(level);
        if (lastEnemy != null)
        {
            LogicLevelProps.SetLastEnemyPosition(level, lastEnemy.Position);
        }
    }
    override public function AfterFinalWaveUpdate(level:LevelEngine):Void
    {
        super.AfterFinalWaveUpdate(level);
        for (storm in level.FindEntities(VanillaEffectID.soulStorm))
        {
            if (storm.Timeout < 0)
            {
                storm.Timeout = 30;
            }
        }
        TransitionUpdate(level);
    }
    private function TransitionUpdate(level:LevelEngine):Void
    {
        if (level.EntityExists(function(e) return IsAliveHostileBoss(e)))
        {
            ExitLevelEnemiesClearedState(level);
            // Boss出现
            level.WaveState = VanillaLevelStates.STATE_BOSS_FIGHT;
            LogicLevelExt.SetProgressBarToBoss(level, VanillaProgressBarID.lockedChest);
            return;
        }

        EnterLevelEnemiesClearedState(level);
        if (!level.EntityExists(function(e) return e.IsEntityOf(VanillaPickupID.lockedChestPickup)))
        {
            var lastEnemyPosition = LogicLevelProps.GetLastEnemyPosition(level);
            var position:Vector3;
            if (lastEnemyPosition.x <= LevelPositions.GetBorderX(false))
            {
                var x = level.GetEnemySpawnX();
                var z = level.GetEntityLaneZ(Mathf.CeilToInt(level.GetMaxLaneCount() * 0.5));
                var y = level.GetGroundY(x, z);
                position = new Vector3(x, y, z);
            }
            else
            {
                position = lastEnemyPosition;
            }
            LockedChestPickup.Produce(level, position);
        }
    }
    override public function BossFightWaveUpdate(level:LevelEngine):Void
    {
        super.BossFightWaveUpdate(level);
        // Boss战斗
        // 如果有Boss存活，不停生成怪物。
        // 如果不存在Boss，或者所有Boss死亡，进入BOSS后阶段。
        if (level.EntityExists(function(e) return IsAliveHostileBoss(e)))
        {
            RunBossWave(level);
            return;
        }

        level.WaveState = VanillaLevelStates.STATE_AFTER_BOSS;
        LogicLevelExt.StopMusic(level);
        if (!LogicLevelExt.IsFirstAdventure(level))
        {
            // 生成通关掉落物。
            var boss = level.FindFirstEntity(VanillaBossID.lockedChest);
            SpawnClearPickup(level, boss);
        }
    }
    override public function AfterBossWaveUpdate(level:LevelEngine):Void
    {
        super.AfterBossWaveUpdate(level);
        ClearEnemies(level);
        EnterLevelEnemiesClearedState(level);

        if (!LogicLevelExt.IsFirstAdventure(level))
            return;
        if (level.IsCleared)
            return;

        // 存在未死亡的敌方Boss时，则重新进入boss战。
        if (level.EntityExists(function(e) return e.Type == EntityTypes.BOSS && LogicEntityExt.IsHostileEntity(e) && !e.IsDead))
        {
            ExitLevelEnemiesClearedState(level);
            level.WaveState = VanillaLevelStates.STATE_BOSS_FIGHT;
            return;
        }

        // 有已经死亡，但是仍存在的BOSS时不结束。
        if (level.EntityExists(function(e) return e.Type == EntityTypes.BOSS && LogicEntityExt.IsHostileEntity(e) && e.IsDead))
            return;

        // 有上锁的箱子的掉落物也不结束。
        if (level.EntityExists(VanillaPickupID.lockedChestPickup))
            return;
        // 隐藏UI，关闭输入
        LogicLevelExt.ResetHeldItem(level);
        LogicLevelExt.SetUIAndInputDisabled(level, true);
        level.Clear();
    }
}
