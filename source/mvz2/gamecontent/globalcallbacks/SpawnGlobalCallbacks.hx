// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/SpawnGlobalCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2.vanilla.level.VanillaLevelStates;
import mvz2logic.callbacks.LogicLevelCallbacks;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.modding.Mod;
import pvzengine.callbacks.CallbackResult;
import unity.Mathf;
import mvz2logic.level.LogicLevelExt;

@:modGlobalCallbacks
class SpawnGlobalCallbacks extends VanillaGlobalCallbacks
{
    public override function Apply(mod:Mod):Void
    {
        mod.AddTrigger(LogicLevelCallbacks.CALCULATE_SPAWN_POINTS, CalculateSpawnPointsCallback);
    }
    function CalculateSpawnPointsCallback(param:CalculateSpawnPointParams, result:CallbackResult):Void
    {
        var level = param.level;
        var wave = param.wave;
        var flags = param.flags;
        var output = param.param;

        var isBossFight = level.WaveState == VanillaLevelStates.STATE_BOSS_FIGHT || level.WaveState == VanillaLevelStates.STATE_BOSS_FIGHT_2;
        if (isBossFight)
        {
            var totalWave = level.GetTotalFlags() * level.GetWavesPerFlag();
            output.basePoints = Std.int(Mathf.FloorToInt(totalWave * 0.8) / 2) + 1;
            output.multiplier = LogicLevelProps.GetBossSpawnPointMultiplier(level);
        }
        else
        {
            var totalWave = LogicLevelExt.GetLevelTotalWaves(level, wave, flags);
            output.basePoints = Std.int(Mathf.FloorToInt(totalWave * 0.8) / 2) + 1;
            if (level.IsHugeWave(wave) && (level.WaveState == VanillaLevelStates.STATE_STARTED || level.WaveState == VanillaLevelStates.STATE_FINAL_WAVE))
            {
                output.multiplier *= 2.5;
            }
        }
    }
}
