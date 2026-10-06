// Ported from: Assets/Scripts/Vanilla/GameContent/Areas/Dream.cs
package mvz2.gamecontent.areas;

import mvz2.gamecontent.areas.VanillaAreaID.VanillaAreaNames;
import mvz2.gamecontent.buffs.level.NightmareLevelBuff;
import mvz2.gamecontent.buffs.level.TaintedSunBuff;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaMusicID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.level.VanillaAreaProps;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import mvz2logic.saves.LogicSaveExt;
import mvz2logic.Global;
import mvz2logic.grids.LogicGridProps;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicStageProps;
import pvzengine.definitions.AreaDefinition;
import pvzengine.level.LevelEngine;
import unity.Color;
import unity.Mathf;
import unity.Vector3;
import mvz2.gamecontent.areas.VanillaAreaModelPresets;

@:autoAreaDefinition(VanillaAreaNames.dream)
class Dream extends AreaDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        SetProperty(VanillaAreaProps.WATER_COLOR, new Color(0, 0.48, 0.89, 1));
        SetProperty(VanillaAreaProps.WATER_COLOR_CENSORED, new Color(0, 0.48, 0.89, 1));
    }
    public override function Setup(level:LevelEngine):Void
    {
        super.Setup(level);
        level.Spawn(VanillaEffectID.miner, new Vector3(600, 0, 40), null);
        UpdateNightmareOrDream(level);
    }
    public override function PostLoad(level:LevelEngine):Void
    {
        super.PostLoad(level);
        UpdateNightmareOrDream(level);
    }
    public override function Update(level:LevelEngine):Void
    {
        super.Update(level);
        var wave = GetPoolWave(level);
        wave = (wave + 0.01) % 1;
        SetPoolWave(level, wave);
    }
    public override function PostHugeWaveEvent(level:LevelEngine):Void
    {
        super.PostHugeWaveEvent(level);
        level.AddBuff(TaintedSunBuff);
        LogicLevelExt.PlaySound(level, VanillaSoundID.reverseVampire);
        LogicLevelExt.PlaySound(level, VanillaSoundID.confuse);
    }
    public override function GetGroundY(level:LevelEngine, x:Float, z:Float):Float
    {
        var column = level.GetColumn(x);
        var lane = level.GetLane(z);
        var grid = level.GetGrid(column, lane);
        if (grid != null && LogicGridProps.IsWater(grid))
        {
            // 水中
            return -1 + Mathf.Sin(((x + z) * 0.01 + GetPoolWave(level)) * 4 * Mathf.PI);
        }
        return super.GetGroundY(level, x, z);
    }
    public static function GetPoolWave(level:LevelEngine):Float
    {
        return level.GetProperty(PROP_POOL_WAVE);
    }
    public static function SetPoolWave(level:LevelEngine, value:Float):Void
    {
        level.SetProperty(PROP_POOL_WAVE, value);
    }

    function UpdateNightmareOrDream(level:LevelEngine):Void
    {
        if (LogicSaveExt.DreamIsNightmare(Global.Saves))
        {
            SetToNightmare(level);
        }
        else
        {
            SetToDream(level);
        }
    }
    public static function SetToDream(level:LevelEngine):Void
    {
        LogicLevelExt.SetAreaModelPreset(level, VanillaAreaModelPresets.defaultPreset);
        if (IsNightmare(level))
        {
            level.RemoveBuffs(NightmareLevelBuff);
        }
        if (LogicStageProps.GetMusicID(level) == VanillaMusicID.nightmareLevel)
        {
            LogicStageProps.SetMusicID(level, VanillaMusicID.dreamLevel);
        }
        if (LogicLevelExt.IsPlayingMusic(level, VanillaMusicID.nightmareLevel))
        {
            LogicLevelExt.SetPlayingMusic(level, VanillaMusicID.dreamLevel);
        }
    }
    public static function SetToNightmare(level:LevelEngine):Void
    {
        LogicLevelExt.SetAreaModelPreset(level, DreamPresets.nightmare);
        if (!IsNightmare(level))
        {
            level.AddBuff(NightmareLevelBuff);
        }
        if (LogicStageProps.GetMusicID(level) == VanillaMusicID.dreamLevel)
        {
            LogicStageProps.SetMusicID(level, VanillaMusicID.nightmareLevel);
        }
        if (LogicLevelExt.IsPlayingMusic(level, VanillaMusicID.dreamLevel))
        {
            LogicLevelExt.SetPlayingMusic(level, VanillaMusicID.nightmareLevel);
        }
    }
    public static function IsNightmare(level:LevelEngine):Bool
    {
        return level.HasBuff(NightmareLevelBuff);
    }
    public static var PROP_POOL_WAVE:VanillaLevelPropertyMeta<Float> = new VanillaLevelPropertyMeta<Float>("PoolWave");
}
