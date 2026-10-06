// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/FinalClear/WitherStageBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.level.WitherClearedBuff;
import mvz2.gamecontent.buffs.level.WitherTransitionBuff;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2logic.level.LevelPositions;
import mvz2logic.level.LogicLevelExt;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageDefinition;
import unity.Vector3;

class WitherStageBehaviour extends BossStageBehaviour
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
        if (!level.EntityExists(VanillaEffectID.castleTwilight))
        {
            var pos = new Vector3((LevelPositions.LEFT_BORDER + LevelPositions.RIGHT_BORDER) * 0.5, 0, LevelPositions.LAWN_HEIGHT * 0.5);
            level.Spawn(VanillaEffectID.castleTwilight, pos, null);
        }
    }
    override public function AfterFinalWaveUpdate(level:LevelEngine):Void
    {
        super.AfterFinalWaveUpdate(level);
        StartBossTransitionUpdate(level, WitherTransitionBuff);
    }
    override public function BossFightWaveUpdate(level:LevelEngine):Void
    {
        super.BossFightWaveUpdate(level);
        WitherFightUpdate(level);
    }

    private function WitherFightUpdate(level:LevelEngine):Void
    {
        // 凋灵战斗
        // 如果不存在Boss，或者所有Boss死亡，进入BOSS后阶段。
        // 如果有Boss存活，不停生成怪物。
        if (level.EntityExists(function(e) return IsAliveHostileBoss(e)))
        {
            RunBossWave(level);
            return;
        }

        StartAfterBossState(level, VanillaBossID.wither);
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
        if (level.HasBuff(WitherClearedBuff))
            return;
        if (level.EntityExists(function(e) return IsHostileBoss(e)))
            return;
        level.AddBuff(WitherClearedBuff);
    }
}
