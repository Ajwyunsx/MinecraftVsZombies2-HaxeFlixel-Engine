// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/WaveStageBehaviour.cs
// PORT-NOTE: C# Tools 扩展方法 `timer.RunToExpiredAndNotNull()` 统一展开为
// `timer != null && timer.RunToExpired()`（FrameTimer 已在 tools 包移植）。
package mvz2.gamecontent.stages;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.level.VanillaLevelStates;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import mvz2logic.callbacks.LogicLevelCallbacks;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LevelPositions;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.level.LogicStageProps;
import pvzengine.callbacks.LevelCallbackParams;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageBehaviour;
import pvzengine.level.StageDefinition;
import tools.FrameTimer;
import tools.Ticks;
import tools.TimerHelper;
import unity.Mathf;

class WaveStageBehaviour extends StageBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
    }
    public function RunWaveTimer(level:LevelEngine):Void
    {
        CheckWaveAdvancement(level);

        var waveTimer = GetWaveTimer(level);
        if (waveTimer != null && waveTimer.RunToExpired())
        {
            NextWaveOrHugeWave(level);
        }
    }
    public function RunBossWave(level:LevelEngine):Void
    {
        CheckWaveAdvancement(level);

        var waveTimer = GetWaveTimer(level);
        if (waveTimer != null && waveTimer.RunToExpired())
        {
            SetWaveMaxHealth(level, 0);
            waveTimer.ResetSeconds(LogicStageProps.GetWaveMaxSeconds(level));
            level.RunWave();
        }
    }
    // #region 回调
    override public function PrepareForBattle(level:LevelEngine):Void
    {
        level.AreaDefinition.PrepareForBattle(level);
        if (!LogicLevelProps.HasNoCarts(level) && level.CurrentFlag <= 0)
        {
            VanillaLevelExt.RefreshCarts(level);
            var cartRef = level.GetCartReference();
            if (cartRef != null)
                VanillaLevelExt.SpawnCarts(level, cartRef, LevelPositions.CART_START_X, 20);
        }
    }
    override public function Start(level:LevelEngine):Void
    {
        var seconds = level.CurrentFlag > 0 ? level.GetContinutedFirstWaveTime() : level.GetFirstWaveTime();
        var waveTimer = TimerHelper.NewSecondTimer(seconds);
        SetWaveTimer(level, waveTimer);
        level.WaveState = STATE_NOT_STARTED;
    }
    override public function Update(level:LevelEngine):Void
    {
        switch (level.WaveState)
        {
            case STATE_NOT_STARTED:
                NotStartedUpdate(level);
            case STATE_STARTED:
                StartedUpdate(level);
            case STATE_HUGE_WAVE_APPROACHING:
                HugeWaveApproachingUpdate(level);
            case STATE_FINAL_WAVE:
                FinalWaveUpdate(level);
        }
        UpdateHighWaveWeight(level);
        VanillaLevelExt.CheckGameOver(level);
    }
    override public function PostHugeWaveEvent(level:LevelEngine):Void
    {
        super.PostHugeWaveEvent(level);
        if (LogicLevelProps.IgnoreHugeWaveEvent(level))
            return;
        level.AreaDefinition.PostHugeWaveEvent(level);
    }
    override public function PostFinalWaveEvent(level:LevelEngine):Void
    {
        // PORT-NOTE: 原 C# 此处调用的是 base.PostHugeWaveEvent(level)（疑似笔误），此处保持 1:1 不修改。
        super.PostHugeWaveEvent(level);
        level.AreaDefinition.PostFinalWaveEvent(level);
    }
    override public function PostEnemySpawned(entity:Entity):Void
    {
        var armor = VanillaEntityExt.GetMainArmor(entity);
        AddWaveMaxHealth(entity.Level, entity.GetMaxHealth() + (armor != null ? armor.GetMaxHealth() : 0));
    }
    // #endregion

    // #region 波次
    function CheckWaveAdvancement(level:LevelEngine):Void
    {
        var waveTimer = GetWaveTimer(level);
        if (waveTimer == null)
            return;
        // 每15帧检测一次，还剩一秒钟结束则不检测。
        if (!waveTimer.PassedInterval(15) || waveTimer.Frame <= 30)
            return;

        // 已经不存在存活的敌人了，直接加速。
        if (LogicLevelExt.HasNoAliveEnemy(level))
        {
            waveTimer.Frame = 30;
            return;
        }

        // 下一波是一大波，除非已经没有存活的敌人了，否则不会加速。
        if (level.IsHugeWave(level.CurrentWave + 1))
            return;

        // 还没到加速时间。
        if (waveTimer.Frame >= waveTimer.MaxFrame - Ticks.FromSeconds(LogicStageProps.GetWaveAdvanceSeconds(level)))
            return;

        // 敌人的血量没有低于阈值，不加速。
        if (!CheckEnemiesRemainedHealth(level))
            return;

        // 加速。
        waveTimer.Frame = 30;
    }
    function NextWaveOrHugeWave(level:LevelEngine):Void
    {
        if (level.IsHugeWave(level.CurrentWave + 1))
        {
            TriggerHugeWaveApproaching(level);
            return;
        }
        NextWave(level);
    }
    function TriggerHugeWaveApproaching(level:LevelEngine):Void
    {
        level.WaveState = STATE_HUGE_WAVE_APPROACHING;
        var waveTimer = GetWaveTimer(level);
        if (waveTimer != null)
            waveTimer.ResetTime(180);
        level.Triggers.RunCallback(LogicLevelCallbacks.POST_HUGE_WAVE_APPROACH, new LevelCallbackParams(level));
        UpdateHighWaveState(level);
    }
    function NextWave(level:LevelEngine):Void
    {
        var waveTimer = GetWaveTimer(level);
        if (waveTimer != null)
            waveTimer.ResetSeconds(LogicStageProps.GetWaveMaxSeconds(level));
        SetWaveMaxHealth(level, 0);
        LogicLevelExt.NextWave(level);
        if (level.IsFinalWave(level.CurrentWave))
        {
            level.WaveState = VanillaLevelStates.STATE_FINAL_WAVE;
            if (HasFinalWave)
            {
                SetFinalWaveEventTimer(level, new FrameTimer(60));
                level.Triggers.RunCallback(LogicLevelCallbacks.POST_FINAL_WAVE, new LevelCallbackParams(level));
            }
        }
        UpdateHighWaveState(level);
    }
    // #endregion

    // #region 更新关卡
    public function NotStartedUpdate(level:LevelEngine):Void
    {
        var waveTimer = GetWaveTimer(level);
        if (waveTimer != null && waveTimer.RunToExpired())
        {
            LogicLevelExt.PlaySound(level, VanillaSoundID.awooga);
            level.WaveState = STATE_STARTED;
            level.LevelProgressVisible = true;
            NextWaveOrHugeWave(level);
        }
    }
    public function StartedUpdate(level:LevelEngine):Void
    {
        RunWaveTimer(level);
    }
    public function HugeWaveApproachingUpdate(level:LevelEngine):Void
    {
        var waveTimer = GetWaveTimer(level);
        if (waveTimer != null && waveTimer.RunToExpired())
        {
            LogicLevelExt.PlaySound(level, VanillaSoundID.siren);
            level.WaveState = STATE_STARTED;
            NextWave(level);
            if (SpawnFlagZombie)
            {
                VanillaLevelExt.SpawnFlagZombie(level);
            }
            level.RunHugeWaveEvent();
        }
    }
    public function FinalWaveUpdate(level:LevelEngine):Void
    {
        if (HasFinalWave)
        {
            var finalWaveTimer = GetFinalWaveEventTimer(level);
            if (finalWaveTimer != null)
            {
                finalWaveTimer.Run();
                if (finalWaveTimer.Expired)
                {
                    level.RunFinalWaveEvent();
                }
            }
            if (IsHighWave(level))
            {
                if (LogicLevelExt.HasNoAliveEnemy(level))
                {
                    SetHighWave(level, false);
                }
            }
        }
    }
    // #endregion

    // #region 敌人血量
    public function CheckEnemiesRemainedHealth(level:LevelEngine):Bool
    {
        var enemies = level.FindEntities(function(e) return LogicEntityExt.IsAliveEnemy(e));
        var health:Float = 0;
        for (e in enemies)
        {
            var armor = VanillaEntityExt.GetMainArmor(e);
            health += e.Health + (armor != null ? armor.Health : 0);
        }
        return health <= LogicStageProps.GetWaveAdvanceHealthPercent(level) * GetWaveMaxHealth(level);
    }
    // #endregion

    private static function UpdateHighWaveState(level:LevelEngine):Void
    {
        var highWave = VanillaLevelExt.IsDuringHugeWave(level) || level.GetEntityCount(function(e) return LogicEntityExt.IsAliveEnemy(e)) >= 10;
        SetHighWave(level, highWave);
    }
    private static function UpdateHighWaveWeight(level:LevelEngine):Void
    {
        var weightSpeed = IsHighWave(level) ? 1.0 : -1.0;
        var weight = LogicLevelExt.GetSubtrackWeight(level);
        weight = Mathf.Clamp01(weight + weightSpeed * SUBTRACK_WEIGHT_SPEED);
        LogicLevelExt.SetSubtrackWeight(level, weight);
    }

    // #region 关卡属性
    public static function GetWaveTimer(level:LevelEngine):Null<FrameTimer> return level.GetProperty(PROP_WAVE_TIMER);
    public static function SetWaveTimer(level:LevelEngine, value:FrameTimer):Void level.SetProperty(PROP_WAVE_TIMER, value);

    public static function GetFinalWaveEventTimer(level:LevelEngine):Null<FrameTimer> return level.GetProperty(PROP_FINAL_WAVE_EVENT_TIMER);
    public static function SetFinalWaveEventTimer(level:LevelEngine, value:FrameTimer):Void level.SetProperty(PROP_FINAL_WAVE_EVENT_TIMER, value);

    public static function GetWaveMaxHealth(level:LevelEngine):Float return level.GetProperty(PROP_WAVE_MAX_HEALTH);
    public static function SetWaveMaxHealth(level:LevelEngine, value:Float):Void level.SetProperty(PROP_WAVE_MAX_HEALTH, value);
    public static function AddWaveMaxHealth(level:LevelEngine, value:Float):Void SetWaveMaxHealth(level, GetWaveMaxHealth(level) + value);

    public static function SetHighWave(level:LevelEngine, value:Bool):Void level.SetProperty(PROP_HIGH_WAVE, value);
    public static function IsHighWave(level:LevelEngine):Bool return level.GetProperty(PROP_HIGH_WAVE);
    // #endregion

    // #region 属性字段
    private static inline var PROP_REGION:String = "wave_stage";
    public var SpawnFlagZombie:Bool = true;
    public var HasFinalWave:Bool = true;
    @:levelPropertyRegistry(PROP_REGION)
    public static var PROP_WAVE_TIMER:VanillaLevelPropertyMeta<FrameTimer> = new VanillaLevelPropertyMeta<FrameTimer>("WaveTimer");
    @:levelPropertyRegistry(PROP_REGION)
    public static var PROP_WAVE_MAX_HEALTH:VanillaLevelPropertyMeta<Float> = new VanillaLevelPropertyMeta<Float>("WaveMaxHealth");
    @:levelPropertyRegistry(PROP_REGION)
    public static var PROP_FINAL_WAVE_EVENT_TIMER:VanillaLevelPropertyMeta<FrameTimer> = new VanillaLevelPropertyMeta<FrameTimer>("FinalWaveEventTimer");
    @:levelPropertyRegistry(PROP_REGION)
    public static var PROP_HIGH_WAVE:VanillaLevelPropertyMeta<Bool> = new VanillaLevelPropertyMeta<Bool>("HighWave");
    public static inline var SUBTRACK_WEIGHT_SPEED:Float = 1 / 90.0;
    public static inline var STATE_NOT_STARTED:Int = VanillaLevelStates.STATE_NOT_STARTED;
    public static inline var STATE_STARTED:Int = VanillaLevelStates.STATE_STARTED;
    public static inline var STATE_HUGE_WAVE_APPROACHING:Int = VanillaLevelStates.STATE_HUGE_WAVE_APPROACHING;
    public static inline var STATE_FINAL_WAVE:Int = VanillaLevelStates.STATE_FINAL_WAVE;
    public static inline var STATE_AFTER_FINAL_WAVE:Int = VanillaLevelStates.STATE_AFTER_FINAL_WAVE;
    public static inline var STATE_BOSS_FIGHT:Int = VanillaLevelStates.STATE_BOSS_FIGHT;
    public static inline var STATE_BOSS_FIGHT_2:Int = VanillaLevelStates.STATE_BOSS_FIGHT_2;
    public static inline var STATE_AFTER_BOSS:Int = VanillaLevelStates.STATE_AFTER_BOSS;
    // #endregion
}
