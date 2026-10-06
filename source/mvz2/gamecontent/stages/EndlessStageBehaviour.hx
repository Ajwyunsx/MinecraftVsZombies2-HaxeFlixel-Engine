// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/EndlessStageBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.enemies.VanillaSpawnID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.level.VanillaLevelStates;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import mvz2logic.Global;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicStageProps;
import mvz2logic.localization.LogicStrings;
import mvz2logic.stats.LogicStats;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.callbacks.LevelCallbacks.PostWaveParams;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageBehaviour;
import pvzengine.level.StageDefinition;
import tools.EnumerableExt;
import tools.FrameTimer;
import unity.Mathf;

class EndlessStageBehaviour extends StageBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
        stageDef.AddTrigger(LevelCallbacks.POST_WAVE_FINISHED, PostWaveFinishedCallback);
    }
    override public function Start(level:LevelEngine):Void
    {
        super.Start(level);
        if (level.CurrentFlag == 0)
        {
            LogicLevelExt.ShowAdvice(level, LogicStrings.CONTEXT_ADVICE, VanillaStrings.ADVICE_ENDLESS_HINT, 1, 150, []);
        }
    }
    override public function Update(level:LevelEngine):Void
    {
        super.Update(level);
        switch (level.WaveState)
        {
            case VanillaLevelStates.STATE_FINAL_WAVE:
                FinalWaveUpdate(level);
            case VanillaLevelStates.STATE_AFTER_FINAL_WAVE:
                AfterFinalWaveUpdate(level);
        }
    }
    override public function PostWave(level:LevelEngine, wave:Int):Void
    {
        super.PostWave(level, wave);
        if (level.IsFinalWave(wave))
        {
            var roundTimer = GetOrCreateRoundTimer(level);
            roundTimer.ResetTime(1800);
        }
    }
    private function PostWaveFinishedCallback(param:PostWaveParams, result:CallbackResult):Void
    {
        var level = param.level;
        if (!LogicStageProps.IsEndless(level))
            return;
        if (Global.Saves.GetStat(LogicStats.CATEGORY_MAX_ENDLESS_FLAGS, level.StageID) < level.CurrentFlag)
        {
            Global.Saves.SetStat(LogicStats.CATEGORY_MAX_ENDLESS_FLAGS, level.StageID, level.CurrentFlag);
        }
    }
    // #region 更新关卡
    public function FinalWaveUpdate(level:LevelEngine):Void
    {
        var roundTimer = GetOrCreateRoundTimer(level);
        if (roundTimer != null)
            roundTimer.Run();
        if ((roundTimer != null && roundTimer.Expired) || LogicLevelExt.HasNoAliveEnemy(level))
        {
            LogicLevelExt.PostWaveFinished(level, level.CurrentWave);
            level.WaveState = VanillaLevelStates.STATE_AFTER_FINAL_WAVE;
            if (roundTimer != null)
                roundTimer.ResetTime(150);
            LogicLevelExt.PlaySound(level, VanillaSoundID.hugeWave);
            LogicLevelExt.ShowAdvice(level, LogicStrings.CONTEXT_ADVICE, VanillaStrings.ADVICE_MORE_ENEMIES_APPROACHING, 1000, 150, []);
        }
    }
    public function AfterFinalWaveUpdate(level:LevelEngine):Void
    {
        var roundTimer = GetOrCreateRoundTimer(level);
        if (roundTimer == null)
            return;
        if (roundTimer.Frame == 1)
        {
            roundTimer.Run();
            LogicLevelExt.SaveStateData(level);
        }
        if (roundTimer.RunToExpired())
        {
            LogicLevelExt.StopLevel(level);
            LogicStageProps.SetEnemyPool(level, GenerateEnemyPool(level, level.CurrentFlag));
            level.CurrentWave = 0;
            LogicLevelExt.HideAdvice(level);
            LogicLevelExt.BeginLevel(level);
        }
    }
    // #endregion

    public function GenerateEnemyPool(level:LevelEngine, flag:Int):Array<NamespaceID>
    {
        var entries:Array<NamespaceID> = [
            VanillaSpawnID.zombie,
            VanillaSpawnID.leatherCappedZombie,
        ];
        var round = Std.int(flag / 2);
        if (round == 0)
        {
            // 原 C# 此处为空块。
        }
        if (round == 1)
        {
            entries.push(VanillaSpawnID.ironHelmettedZombie);
        }
        else
        {
            var maxEnemyTypeCount = Mathf.MinInt(round + 1, 9);

            if (round >= 5)
            {
                entries.push(VanillaSpawnID.mutantZombie);
                maxEnemyTypeCount--;
            }
            if (round >= 10)
            {
                entries.push(VanillaSpawnID.megaMutantZombie);
                maxEnemyTypeCount--;
            }

            var game = Global.Game;
            var enemies = Global.Saves.GetUnlockedEnemies();

            var areaDef = level.AreaDefinition;
            // PORT-NOTE: C# LINQ 链 (Select → Where) 展开为 Lambda.map + Lambda.filter。
            var validEnemies = Lambda.array(Lambda.map(enemies, e -> VanillaSpawnID.GetFromEntity(e)));
            validEnemies = Lambda.filter(validEnemies, function(spawnID:NamespaceID):Bool
            {
                if (spawnID == VanillaSpawnID.mutantZombie || spawnID == VanillaSpawnID.megaMutantZombie)
                    return false;
                if (Lambda.exists(entries, id -> id == spawnID))
                    return false;
                var spawnDef = game.GetSpawnDefinition(spawnID);
                if (spawnDef == null)
                    return false;
                if (!spawnDef.CanAppearInEndless(level))
                    return false;
                return true;
            });
            validEnemies = EnumerableExt.RandomTake(validEnemies, maxEnemyTypeCount, level.GetRoundRNG());
            for (v in validEnemies)
            {
                entries.push(v);
            }
        }
        return entries;
    }
    public function GetRoundTimer(level:LevelEngine):Null<FrameTimer> return level.GetProperty(PROP_ROUND_TIMER);
    public function SetRoundTimer(level:LevelEngine, value:FrameTimer):Void level.SetProperty(PROP_ROUND_TIMER, value);
    public function GetOrCreateRoundTimer(level:LevelEngine):FrameTimer
    {
        var roundTimer = GetRoundTimer(level);
        if (roundTimer == null)
        {
            roundTimer = new FrameTimer(1800);
            SetRoundTimer(level, roundTimer);
        }
        return roundTimer;
    }
    private static inline var PROP_REGION:String = "endless_stage";
    @:levelPropertyRegistry(PROP_REGION)
    public static var PROP_ROUND_TIMER:VanillaLevelPropertyMeta<FrameTimer> = new VanillaLevelPropertyMeta<FrameTimer>("RoundTimer");
}
