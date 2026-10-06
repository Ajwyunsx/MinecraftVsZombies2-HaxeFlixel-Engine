// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/FinalClear/RedDragonStageBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.bosses.RedDragon;
import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.level.RedDragonClearedBuff;
import mvz2.gamecontent.buffs.level.RedDragonStageBuff;
import mvz2.gamecontent.buffs.level.RedDragonTransitionBuff;
import mvz2.vanilla.level.VanillaLevelStates;
import mvz2logic.level.LogicLevelExt;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageDefinition;

class RedDragonStageBehaviour extends BossStageBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
    }
    override public function PostWave(level:LevelEngine, wave:Int):Void
    {
        super.PostWave(level, wave);
        if (wave <= 10)
            return;
        if (!level.HasBuff(RedDragonStageBuff))
        {
            level.AddBuff(RedDragonStageBuff);
        }
    }
    override public function AfterFinalWaveUpdate(level:LevelEngine):Void
    {
        super.AfterFinalWaveUpdate(level);
        TransitionUpdate(level);
    }
    private function TransitionUpdate(level:LevelEngine):Void
    {
        if (level.EntityExists(function(e) return IsAliveHostileBoss(e) && e.State == RedDragon.STATE_IDLE))
        {
            // 红龙出现
            level.WaveState = VanillaLevelStates.STATE_BOSS_FIGHT;
            return;
        }
        if (!level.HasBuff(RedDragonTransitionBuff))
        {
            level.AddBuff(RedDragonTransitionBuff);
        }
    }
    override public function BossFightWaveUpdate(level:LevelEngine):Void
    {
        super.BossFightWaveUpdate(level);
        RedDragonUpdate(level);
    }
    private function RedDragonUpdate(level:LevelEngine):Void
    {
        // 红龙战斗
        // 如果有Boss存活，不停生成怪物。
        // 如果不存在Boss，或者所有Boss死亡，进入BOSS后阶段。
        if (level.EntityExists(function(e) return IsAliveHostileBoss(e)))
        {
            RunBossWave(level);
            return;
        }

        StartAfterBossState(level, VanillaBossID.redDragon);
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
        if (level.HasBuff(RedDragonClearedBuff))
            return;
        if (level.EntityExists(function(e) return IsAliveHostileBoss(e)))
            return;
        level.AddBuff(RedDragonClearedBuff);
    }
}
