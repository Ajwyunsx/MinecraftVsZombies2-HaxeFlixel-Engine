// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/FinalClear/NightmareStageBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.level.NightmareClearedBuff;
import mvz2.gamecontent.buffs.level.NightmareaperTransitionBuff;
import mvz2.gamecontent.buffs.level.SlendermanTransitionBuff;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2logic.level.LevelPositions;
import mvz2logic.level.LogicLevelExt;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageDefinition;
import unity.Vector3;

class NightmareStageBehaviour extends BossStageBehaviour
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
        if (!level.EntityExists(VanillaEffectID.nightmareWatchingEye))
        {
            var pos = new Vector3((LevelPositions.LEFT_BORDER + LevelPositions.RIGHT_BORDER) * 0.5, 0, LevelPositions.LAWN_HEIGHT * 0.5);
            level.Spawn(VanillaEffectID.nightmareWatchingEye, pos, null);
        }
    }
    override public function AfterFinalWaveUpdate(level:LevelEngine):Void
    {
        super.AfterFinalWaveUpdate(level);
        StartBossTransitionUpdate(level, SlendermanTransitionBuff);
    }
    override public function BossFightWaveUpdate(level:LevelEngine):Void
    {
        super.BossFightWaveUpdate(level);
        var state = BossStageBehaviour.GetBossState(level);
        switch (state)
        {
            case BOSS_STATE_SLENDERMAN:
                SlendermanUpdate(level);
            case BOSS_STATE_NIGHTMAREAPER_TRANSITION:
                NightmareaperTransitionUpdate(level);
            case BOSS_STATE_NIGHTMAREAPER:
                NightmareaperUpdate(level);
        }
    }
    private function SlendermanUpdate(level:LevelEngine):Void
    {
        // 瘦长鬼影战斗
        // 如果有Boss存活，不停生成怪物。
        // 如果不存在Boss，或者所有Boss死亡，进入BOSS后阶段。
        if (level.EntityExists(function(e) return IsAliveHostileBoss(e)))
        {
            RunBossWave(level);
            return;
        }
        // 隐藏UI，关闭输入
        DisableUIAndInput(level);
        LogicLevelExt.StopMusic(level);

        BossStageBehaviour.SetBossState(level, BOSS_STATE_NIGHTMAREAPER_TRANSITION);
        level.AddBuff(NightmareaperTransitionBuff);
    }
    private function NightmareaperTransitionUpdate(level:LevelEngine):Void
    {
        ClearEnemies(level);
        EnterLevelEnemiesClearedState(level);

        StartTransitionUntilBossExists(level, NightmareaperTransitionBuff, function()
        {
            // 梦魇收割者出现
            LogicLevelExt.SetUIAndInputDisabled(level, false);
            BossStageBehaviour.SetBossState(level, BOSS_STATE_NIGHTMAREAPER);
            ExitLevelEnemiesClearedState(level);
        });
    }
    private function NightmareaperUpdate(level:LevelEngine):Void
    {
        // 梦魇收割者战斗
        // 如果不存在Boss，或者所有Boss死亡，进入BOSS后阶段。
        // 如果有Boss存活，不停生成怪物。
        if (level.EntityExists(function(e) return IsAliveHostileBoss(e)))
        {
            RunBossWave(level);
            return;
        }

        StartAfterBossState(level, VanillaBossID.nightmareaper);
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
        if (level.HasBuff(NightmareClearedBuff))
            return;
        if (level.EntityExists(function(e) return IsHostileBoss(e)))
            return;

        level.AddBuff(NightmareClearedBuff);
    }

    public static inline var BOSS_STATE_SLENDERMAN:Int = 0;
    public static inline var BOSS_STATE_NIGHTMAREAPER_TRANSITION:Int = 1;
    public static inline var BOSS_STATE_NIGHTMAREAPER:Int = 2;
}
