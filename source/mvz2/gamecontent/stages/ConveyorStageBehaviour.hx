// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/ConveyorStageBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicStageProps;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageBehaviour;
import pvzengine.level.StageDefinition;
import tools.FrameTimer;
import unity.Mathf;

class ConveyorStageBehaviour extends StageBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
    }
    override public function Start(level:LevelEngine):Void
    {
        LogicLevelExt.SetConveyorMode(level, true);
        var waveTimer = new FrameTimer(CONVEYOR_INTERVAL);
        SetConveyorTimer(level, waveTimer);
    }
    override public function Update(level:LevelEngine):Void
    {
        if (level.IsCleared)
            return;
        var conveyorTimer = GetConveyorTimer(level);
        var speed = GetConveyorSpeed(level);
        if (conveyorTimer != null && conveyorTimer.RunToExpired(speed))
        {
            LogicLevelExt.ConveyRandomSeedPack(level);
            conveyorTimer.Reset();
        }
    }

    public static function GetConveyorSpeed(level:LevelEngine):Float
    {
        var speed = LogicStageProps.GetConveySpeed(level);
        // 当前蓝图越多越慢。
        var seedCount = level.GetConveyorSeedPackCount();
        if (seedCount > SLOW_BLUEPRINT_COUNT_START)
        {
            var multiplier = 1 - Mathf.Pow(seedCount - SLOW_BLUEPRINT_COUNT_START, 2) / Mathf.Pow(SLOW_BLUEPRINT_COUNT_END - SLOW_BLUEPRINT_COUNT_START, 2);
            multiplier = Mathf.Max(multiplier, MIN_CONVEYOR_SPEED_MULTIPLIER);
            speed *= multiplier;
        }
        return speed;
    }

    // #region 关卡属性
    public function GetConveyorTimer(level:LevelEngine):Null<FrameTimer> return level.GetProperty(PROP_CONVEYOR_TIMER);
    public function SetConveyorTimer(level:LevelEngine, value:FrameTimer):Void level.SetProperty(PROP_CONVEYOR_TIMER, value);
    // #endregion

    // #region 属性字段
    public static inline var SLOW_BLUEPRINT_COUNT_START:Int = 4;
    public static inline var SLOW_BLUEPRINT_COUNT_END:Int = 10;
    public static inline var MIN_CONVEYOR_SPEED_MULTIPLIER:Float = 0.4;
    public static inline var PROP_REGION:String = "conveyor";
    @:levelPropertyRegistry(PROP_REGION)
    public static var PROP_CONVEYOR_TIMER:VanillaLevelPropertyMeta<FrameTimer> = new VanillaLevelPropertyMeta<FrameTimer>("ConveyorTimer");
    public static inline var CONVEYOR_INTERVAL:Int = 120;
    // #endregion
}
