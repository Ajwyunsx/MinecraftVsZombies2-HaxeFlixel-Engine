// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/FinalClear/GiantStageBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.bosses.TheGiant;
import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.level.TheGiantClearedBuff;
import mvz2.gamecontent.buffs.level.TheGiantTransitionBuff;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaMusicID;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LevelPositions;
import mvz2logic.level.LogicLevelExt;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageDefinition;
import unity.Vector3;

class GiantStageBehaviour extends BossStageBehaviour
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
        if (!level.EntityExists(VanillaEffectID.spiritUniverse))
        {
            var pos = new Vector3((LevelPositions.LEFT_BORDER + LevelPositions.RIGHT_BORDER) * 0.5, 0, LevelPositions.LAWN_HEIGHT * 0.5);
            level.Spawn(VanillaEffectID.spiritUniverse, pos, null);
        }
    }
    override public function AfterFinalWaveUpdate(level:LevelEngine):Void
    {
        super.AfterFinalWaveUpdate(level);
        StartBossTransitionUpdate(level, TheGiantTransitionBuff);
    }
    override public function BossFightWaveUpdate(level:LevelEngine):Void
    {
        super.BossFightWaveUpdate(level);
        var state = BossStageBehaviour.GetBossState(level);
        switch (state)
        {
            case BOSS_STATE_PHASE1_2:
                TheGiantUpdate(level);
            case BOSS_STATE_PHASE3_TRANSITION:
                TheGiantPhase3TransitionUpdate(level);
            case BOSS_STATE_PHASE3:
                TheGiantPhase3Update(level);
        }
    }
    private function TheGiantUpdate(level:LevelEngine):Void
    {
        // 巨人1、2阶段战斗
        // 如果不存在Boss，或者所有Boss死亡，进入BOSS后阶段。
        // 如果有Boss存活，不停生成怪物。
        var phase2Boss = level.EntityExists(function(e) return e.IsEntityOf(VanillaBossID.theGiant) && LogicEntityExt.IsHostileEntity(e) && !e.IsDead && TheGiant.GetPhase(e) == TheGiant.PHASE_2);

        WaveStageBehaviour.SetHighWave(level, phase2Boss);
        if (level.EntityExists(function(e) return IsAliveHostileBoss(e)))
        {
            RunBossWave(level);
            return;
        }

        LogicLevelExt.StopMusic(level);

        BossStageBehaviour.SetBossState(level, BOSS_STATE_PHASE3_TRANSITION);
    }
    private function TheGiantPhase3TransitionUpdate(level:LevelEngine):Void
    {
        ClearEnemies(level);
        EnterLevelEnemiesClearedState(level);
        if (level.EntityExists(function(e) return e.IsEntityOf(VanillaBossID.theGiant) && LogicEntityExt.IsHostileEntity(e) && !e.IsDead && TheGiant.GetPhase(e) == TheGiant.PHASE_3))
        {
            // 巨人3阶段出现
            LogicLevelExt.PlayMusic(level, VanillaMusicID.mausoleumBoss2);
            BossStageBehaviour.SetBossState(level, BOSS_STATE_PHASE3);
            ExitLevelEnemiesClearedState(level);
            return;
        }
    }
    private function TheGiantPhase3Update(level:LevelEngine):Void
    {
        if (level.EntityExists(function(e) return IsAliveHostileBoss(e)))
        {
            RunBossWave(level);
            return;
        }

        StartAfterBossState(level, VanillaBossID.theGiant);
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
        if (level.HasBuff(TheGiantClearedBuff))
            return;
        if (level.EntityExists(function(e) return IsAliveHostileBoss(e)))
            return;
        level.AddBuff(TheGiantClearedBuff);
    }

    public static inline var BOSS_STATE_PHASE1_2:Int = 0;
    public static inline var BOSS_STATE_PHASE3_TRANSITION:Int = 1;
    public static inline var BOSS_STATE_PHASE3:Int = 2;
}
