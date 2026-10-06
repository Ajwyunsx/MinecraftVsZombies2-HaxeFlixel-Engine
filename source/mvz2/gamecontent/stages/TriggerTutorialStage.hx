// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/TriggerTutorialStage.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.buffs.level.TutorialTriggerDisableBuff;
import mvz2.gamecontent.buffs.seedpacks.TutorialDisableBuff;
import mvz2.gamecontent.contraptions.IgnitableBehaviour;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.talk.VanillaTalkID;
import mvz2.vanilla.audios.VanillaMusicID;
import mvz2.vanilla.helditems.VanillaHeldItemExt;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.Global;
import mvz2logic.helditems.LogicHeldTypes;
import mvz2logic.level.LogicHeldItemProps;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageDefinition;
import tools.FrameTimer;

@:autoStageDefinition(VanillaStageNames.triggerTutorial)
class TriggerTutorialStage extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override public function OnStart(level:LevelEngine):Void
    {
        super.OnStart(level);
        SetTutorialTimer(level, new FrameTimer(90));
        level.SetSeedSlotCount(1);
        LogicLevelExt.FillSeedPacks(level, [VanillaContraptionID.tnt]);
        LogicLevelExt.SetStarshardActive(level, false);
        LogicLevelExt.SetTriggerActive(level, true);
        LogicLevelExt.SetBlueprintsActive(level, true);
        LogicLevelExt.SetPickaxeActive(level, false);
        level.SetEnergy(900);
        StartState(level, STATE_PLACE_TNT);
    }
    override public function OnUpdate(level:LevelEngine):Void
    {
        super.OnUpdate(level);
        UpdateState(level);
        VanillaLevelExt.CheckGameOver(level);
    }
    private function StartTimer(level:LevelEngine, timeout:Int):Void
    {
        var timer = GetTutorialTimer(level);
        if (timer != null)
            timer.ResetTime(timeout);
    }
    private function RunTimer(level:LevelEngine):Void
    {
        var timer = GetTutorialTimer(level);
        if (timer != null && timer.RunToExpired())
        {
            OnTimerStop(level);
        }
    }
    private function StartState(level:LevelEngine, state:Int):Void
    {
        SetTutorialState(level, state);
        var textKey = tutorialStrings[state];
        // PORT-NOTE: C# `string.Format(CONTEXT_STATE, state)` → StringTools.replace。
        var context = StringTools.replace(CONTEXT_STATE, "{0}", Std.string(state));
        LogicLevelExt.ShowAdvice(level, context, textKey, 1000, -1, []);
        switch (state)
        {
            case STATE_PLACE_TNT:
                {
                    level.AddBuff(TutorialTriggerDisableBuff);
                    var tntSeedPack = level.GetSeedPack(VanillaContraptionID.tnt);
                    if (tntSeedPack != null)
                    {
                        LogicLevelExt.SetHintArrowPointToBlueprint(level, tntSeedPack.GetIndex());
                        tntSeedPack.FullRecharge();
                    }
                }
            case STATE_CLICK_TRIGGER:
                {
                    level.RemoveBuffs(TutorialTriggerDisableBuff);
                    var tntSeedPack = level.GetSeedPack(VanillaContraptionID.tnt);
                    if (tntSeedPack != null)
                        tntSeedPack.AddBuff(TutorialDisableBuff);
                    LogicLevelExt.SetHintArrowPointToTrigger(level);
                }
            case STATE_TRIGGER_TNT:
                {
                    LogicLevelExt.HideHintArrow(level);
                }
            case STATE_TNT_TRIGGERED:
                {
                    level.AddBuff(TutorialTriggerDisableBuff);
                    StartTimer(level, 150);
                }
            case STATE_CLICK_TRIGGER_SWAP:
                {
                    level.RemoveBuffs(TutorialTriggerDisableBuff);
                    LogicLevelExt.SetHintArrowPointToTrigger(level);
                }
            case STATE_CLICK_TNT_SWAP:
                {
                    var tntSeedPack = level.GetSeedPack(VanillaContraptionID.tnt);
                    if (tntSeedPack != null)
                    {
                        tntSeedPack.FullRecharge();
                        tntSeedPack.RemoveBuffs(TutorialDisableBuff);
                        LogicLevelExt.SetHintArrowPointToBlueprint(level, tntSeedPack.GetIndex());
                    }
                }
            case STATE_PLACE_TNT_SWAP:
                {
                    LogicLevelExt.HideHintArrow(level);
                }
            case STATE_TNT_PLACED_SWAP:
                {
                    StartTimer(level, 150);
                }

            case STATE_INSTANT_TRIGGER_1, STATE_INSTANT_TRIGGER_2, STATE_FINAL:
                {
                    StartTimer(level, 150);
                }
        }
    }
    private function UpdateState(level:LevelEngine):Void
    {
        var state = GetTutorialState(level);
        switch (state)
        {
            case STATE_PLACE_TNT:
                {
                    var heldEntityID = VanillaLevelExt.GetHeldSeedEntityID(level);
                    if (heldEntityID == VanillaContraptionID.tnt)
                    {
                        LogicLevelExt.HideHintArrow(level);
                    }
                    if (level.EntityExists(VanillaContraptionID.tnt))
                    {
                        StartState(level, STATE_CLICK_TRIGGER);
                    }
                }
            case STATE_CLICK_TRIGGER:
                {
                    var heldEntityType = LogicLevelExt.GetHeldItemType(level);
                    if (heldEntityType == LogicHeldTypes.trigger)
                    {
                        StartState(level, STATE_TRIGGER_TNT);
                    }
                    else if (level.EntityExists(function(e:Entity) return e.GetDefinitionID() == VanillaContraptionID.tnt && IgnitableBehaviour.IsIgnited(e)) || !level.EntityExists(VanillaContraptionID.tnt))
                    {
                        StartState(level, STATE_TNT_TRIGGERED);
                    }
                }
            case STATE_TRIGGER_TNT:
                {
                    if (level.EntityExists(function(e:Entity) return e.GetDefinitionID() == VanillaContraptionID.tnt && IgnitableBehaviour.IsIgnited(e)) || !level.EntityExists(VanillaContraptionID.tnt))
                    {
                        StartState(level, STATE_TNT_TRIGGERED);
                    }
                }
            case STATE_TNT_TRIGGERED:
                {
                    RunTimer(level);
                }


            case STATE_CLICK_TRIGGER_SWAP:
                {
                    var heldEntityType = LogicLevelExt.GetHeldItemType(level);
                    if (heldEntityType == LogicHeldTypes.trigger)
                    {
                        StartState(level, STATE_CLICK_TNT_SWAP);
                    }
                }
            case STATE_CLICK_TNT_SWAP:
                {
                    var heldItemData = LogicLevelExt.GetHeldItemData(level);
                    if (heldItemData != null && VanillaHeldItemExt.GetSeedEntityID(heldItemData, level) == VanillaContraptionID.tnt && LogicHeldItemProps.IsInstantTrigger(heldItemData))
                    {
                        // 下一状态
                        StartState(level, STATE_PLACE_TNT_SWAP);
                        return;
                    }
                    var heldEntityType = LogicLevelExt.GetHeldItemType(level);
                    if (heldEntityType != LogicHeldTypes.trigger)
                    {
                        // 返回之前的状态。
                        StartState(level, STATE_CLICK_TRIGGER_SWAP);
                    }
                }
            case STATE_PLACE_TNT_SWAP:
                {
                    if (level.EntityExists(function(e:Entity) return e.GetDefinitionID() == VanillaContraptionID.tnt && IgnitableBehaviour.IsIgnited(e)))
                    {
                        // 下一状态
                        StartState(level, STATE_TNT_PLACED_SWAP);
                    }
                    else
                    {
                        var heldData = LogicLevelExt.GetHeldItemData(level);
                        if (heldData == null || VanillaHeldItemExt.GetSeedEntityID(heldData, level) != VanillaContraptionID.tnt || !LogicHeldItemProps.IsInstantTrigger(heldData))
                        {
                            // 返回之前的状态。
                            StartState(level, STATE_CLICK_TRIGGER_SWAP);
                        }
                    }
                }
            case STATE_TNT_PLACED_SWAP:
                {
                    RunTimer(level);
                }


            case STATE_INSTANT_TRIGGER_1, STATE_INSTANT_TRIGGER_2, STATE_FINAL:
                {
                    RunTimer(level);
                }
        }
    }
    private function OnTimerStop(level:LevelEngine):Void
    {
        var state = GetTutorialState(level);
        switch (state)
        {
            case STATE_TNT_TRIGGERED:
                StartState(level, STATE_CLICK_TRIGGER_SWAP);
            case STATE_TNT_PLACED_SWAP:
                StartState(level, STATE_INSTANT_TRIGGER_1);
            case STATE_INSTANT_TRIGGER_1:
                StartState(level, STATE_INSTANT_TRIGGER_2);
            case STATE_INSTANT_TRIGGER_2:
                StartState(level, STATE_FINAL);
            case STATE_FINAL:
                LogicLevelExt.StopLevel(level);
                LogicLevelExt.PlayMusic(level, VanillaMusicID.mainmenu);
                LogicLevelExt.HideAdvice(level);
                level.SetEnergy(level.GetStartEnergy());
                level.ClearSeedPacks();
                level.ChangeStage(VanillaStageID.halloween7);
                LogicLevelExt.SetBlueprintsActive(level, true);
                LogicLevelExt.SetPickaxeActive(level, true);
                LogicLevelExt.SetStarshardActive(level, true);
                LogicLevelExt.SetTriggerActive(level, true);
                Global.Saves.Unlock(VanillaUnlockID.trigger);
                Global.Saves.SaveToFile(); // 解锁触发器后保存游戏。
                LogicLevelExt.SimpleStartTalk(level, VanillaTalkID.halloween7, 0, 2, null, null, function()
                {
                    LogicLevelExt.BeginLevel(level);
                });
        }
    }
    public static function GetTutorialTimer(level:LevelEngine):Null<FrameTimer> return level.GetProperty(PROP_TUTORIAL_TIMER);
    public static function SetTutorialTimer(level:LevelEngine, value:FrameTimer):Void level.SetProperty(PROP_TUTORIAL_TIMER, value);
    public static function GetTutorialState(level:LevelEngine):Int return level.GetProperty(PROP_STATE);
    public static function SetTutorialState(level:LevelEngine, value:Int):Void level.SetProperty(PROP_STATE, value);
    private static var ID:NamespaceID = VanillaStageID.triggerTutorial;

    public static var tutorialStrings:Array<String> = [
        STRING_STATE_0,
        STRING_STATE_1,
        STRING_STATE_2,
        STRING_STATE_3,
        STRING_STATE_4,
        STRING_STATE_5,
        STRING_STATE_6,
        STRING_STATE_7,
        STRING_STATE_8,
        STRING_STATE_9,
        STRING_STATE_10
    ];
    public static inline var STATE_PLACE_TNT:Int = 0;
    public static inline var STATE_CLICK_TRIGGER:Int = 1;
    public static inline var STATE_TRIGGER_TNT:Int = 2;
    public static inline var STATE_TNT_TRIGGERED:Int = 3;
    public static inline var STATE_CLICK_TRIGGER_SWAP:Int = 4;
    public static inline var STATE_CLICK_TNT_SWAP:Int = 5;
    public static inline var STATE_PLACE_TNT_SWAP:Int = 6;
    public static inline var STATE_TNT_PLACED_SWAP:Int = 7;
    public static inline var STATE_INSTANT_TRIGGER_1:Int = 8;
    public static inline var STATE_INSTANT_TRIGGER_2:Int = 9;
    public static inline var STATE_FINAL:Int = 10;

    public static inline var CONTEXT_STATE_PREFIX:String = "advice.trigger_tutorial.";
    public static inline var CONTEXT_STATE:String = CONTEXT_STATE_PREFIX + "{0}";

    @:translateMsg("教程关指引", "advice.trigger_tutorial.0")
    public static inline var STRING_STATE_0:String = "放置TNT！";
    @:translateMsg("教程关指引", "advice.trigger_tutorial.1")
    public static inline var STRING_STATE_1:String = "点击选中触发器！";
    @:translateMsg("教程关指引", "advice.trigger_tutorial.2")
    public static inline var STRING_STATE_2:String = "点击以触发TNT！";
    @:translateMsg("教程关指引", "advice.trigger_tutorial.3")
    public static inline var STRING_STATE_3:String = "干得漂亮！";
    @:translateMsg("教程关指引", "advice.trigger_tutorial.4")
    public static inline var STRING_STATE_4:String = "选中触发器！";
    @:translateMsg("教程关指引", "advice.trigger_tutorial.5")
    public static inline var STRING_STATE_5:String = "点击TNT蓝图！";
    @:translateMsg("教程关指引", "advice.trigger_tutorial.6")
    public static inline var STRING_STATE_6:String = "放置TNT，它会立即被触发！";
    @:translateMsg("教程关指引", "advice.trigger_tutorial.7")
    public static inline var STRING_STATE_7:String = "干得好！";
    @:translateMsg("教程关指引", "advice.trigger_tutorial.8")
    public static inline var STRING_STATE_8:String = "立即触发只限于一次性消耗类型的器械。";
    @:translateMsg("教程关指引", "advice.trigger_tutorial.9")
    public static inline var STRING_STATE_9:String = "如果你想交换这两个动作的效果，你可以在设置中更改。";
    @:translateMsg("教程关指引", "advice.trigger_tutorial.10")
    public static inline var STRING_STATE_10:String = "祝你好运！";

    public static var PROP_STATE:VanillaLevelPropertyMeta<Int> = new VanillaLevelPropertyMeta<Int>("state");
    public static var PROP_TUTORIAL_TIMER:VanillaLevelPropertyMeta<FrameTimer> = new VanillaLevelPropertyMeta<FrameTimer>("tutorialTimer");
}
