// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/StarshardTutorialStage.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.buffs.enemies.StarshardCarrierBuff;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.enemies.VanillaSpawnID;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.gamecontent.talk.VanillaTalkID;
import mvz2.vanilla.audios.VanillaMusicID;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.Global;
import pvzengine.entities.EntityTypes;
import mvz2logic.helditems.LogicHeldTypes;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageDefinition;
import tools.FrameTimer;

@:autoStageDefinition(VanillaStageNames.starshardTutorial)
class StarshardTutorialStage extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override public function OnStart(level:LevelEngine):Void
    {
        super.OnStart(level);
        SetTutorialTimer(level, new FrameTimer(90));
        level.SetSeedSlotCount(0);
        LogicLevelExt.FillSeedPacks(level, new Array<NamespaceID>());
        LogicLevelProps.SetStarshardCount(level, 1);
        LogicLevelExt.SetStarshardActive(level, true);
        LogicLevelExt.SetBlueprintsActive(level, false);
        LogicLevelExt.SetPickaxeActive(level, false);
        StartState(level, STATE_CLICK_STARSHARD);
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
            case STATE_CLICK_STARSHARD:
                {
                    LogicLevelExt.SpawnEnemyByID(level, VanillaSpawnID.zombie, 2);
                    LogicLevelExt.SetHintArrowPointToStarshard(level);
                }
            case STATE_EVOKE_DISPENSER:
                LogicLevelExt.HideHintArrow(level);
            case STATE_DISPENSER_EVOKED:
                LogicLevelExt.HideHintArrow(level);
                StartTimer(level, 150);
            case STATE_GREEN_ENEMY:
                {
                    var enemy = LogicLevelExt.SpawnEnemyByID(level, VanillaSpawnID.zombie, 2);
                    if (enemy != null)
                    {
                        enemy.AddBuff(StarshardCarrierBuff);
                    }
                }
            case STATE_KILL_HELMET_ZOMBIE:
                {
                    LogicLevelExt.SpawnEnemyByID(level, VanillaSpawnID.ironHelmettedZombie, 2);
                }
        }
    }
    private function UpdateState(level:LevelEngine):Void
    {
        var state = GetTutorialState(level);
        switch (state)
        {
            case STATE_CLICK_STARSHARD:
                {
                    var heldEntityType = LogicLevelExt.GetHeldItemType(level);
                    if (heldEntityType == LogicHeldTypes.starshard)
                    {
                        StartState(level, STATE_EVOKE_DISPENSER);
                    }
                    else if (level.EntityExists(function(e) return e.IsEvoked()))
                    {
                        StartState(level, STATE_DISPENSER_EVOKED);
                    }
                }
            case STATE_EVOKE_DISPENSER:
                {
                    if (level.EntityExists(function(e) return e.IsEvoked()))
                    {
                        StartState(level, STATE_DISPENSER_EVOKED);
                    }
                }
            case STATE_DISPENSER_EVOKED:
                RunTimer(level);
            case STATE_GREEN_ENEMY:
                {
                    if (level.EntityExists(VanillaPickupID.starshard))
                    {
                        StartState(level, STATE_COLLECT_STARSHARD);
                    }
                }
            case STATE_COLLECT_STARSHARD:
                {
                    for (starshard in level.FindEntities(VanillaPickupID.starshard))
                    {
                        starshard.SetProperty(VanillaPickupProps.IMPORTANT, true);
                    }
                    if (LogicLevelProps.GetStarshardCount(level) > 0)
                    {
                        StartState(level, STATE_KILL_HELMET_ZOMBIE);
                    }
                }
            case STATE_KILL_HELMET_ZOMBIE:
                if (level.GetEntities(EntityTypes.ENEMY).length <= 0)
                {
                    for (particle in level.FindEntities(VanillaEffectID.smoke))
                    {
                        particle.Remove();
                    }
                    LogicLevelExt.StopLevel(level);
                    LogicLevelExt.PlayMusic(level, VanillaMusicID.mainmenu);
                    LogicLevelExt.HideAdvice(level);
                    level.SetEnergy(level.GetStartEnergy());
                    level.ClearSeedPacks();
                    level.ChangeStage(VanillaStageID.halloween2);
                    LogicLevelExt.SetBlueprintsActive(level, true);
                    LogicLevelExt.SetPickaxeActive(level, true);
                    LogicLevelExt.SetStarshardActive(level, true);
                    Global.Saves.Unlock(VanillaUnlockID.starshard);
                    Global.Saves.SaveToFile(); // 解锁星之碎片后保存游戏。
                    LogicLevelExt.SimpleStartTalk(level, VanillaTalkID.starshardTutorial, 1, 2, null, null, function()
                    {
                        LogicLevelExt.BeginLevel(level);
                    });
                }
        }
    }
    private function OnTimerStop(level:LevelEngine):Void
    {
        var state = GetTutorialState(level);
        switch (state)
        {
            case STATE_DISPENSER_EVOKED:
                StartState(level, STATE_GREEN_ENEMY);
        }
    }
    public static function GetTutorialTimer(level:LevelEngine):Null<FrameTimer> return level.GetProperty(PROP_TUTORIAL_TIMER);
    public static function SetTutorialTimer(level:LevelEngine, value:FrameTimer):Void level.SetProperty(PROP_TUTORIAL_TIMER, value);
    public static function GetTutorialState(level:LevelEngine):Int return level.GetProperty(PROP_STATE);
    public static function SetTutorialState(level:LevelEngine, value:Int):Void level.SetProperty(PROP_STATE, value);
    private static var ID:NamespaceID = VanillaStageID.starshardTutorial;

    public static var tutorialStrings:Array<String> = [
        STRING_STATE_0,
        STRING_STATE_1,
        STRING_STATE_2,
        STRING_STATE_3,
        STRING_STATE_4,
        STRING_STATE_5,
    ];
    public static inline var STATE_CLICK_STARSHARD:Int = 0;
    public static inline var STATE_EVOKE_DISPENSER:Int = 1;
    public static inline var STATE_DISPENSER_EVOKED:Int = 2;
    public static inline var STATE_GREEN_ENEMY:Int = 3;
    public static inline var STATE_COLLECT_STARSHARD:Int = 4;
    public static inline var STATE_KILL_HELMET_ZOMBIE:Int = 5;

    public static inline var CONTEXT_STATE_PREFIX:String = "advice.starshard_tutorial.";
    public static inline var CONTEXT_STATE:String = CONTEXT_STATE_PREFIX + "{0}";

    @:translateMsg("教程关指引", "advice.starshard_tutorial.0")
    public static inline var STRING_STATE_0:String = "点击星之碎片槽选中星之碎片！";
    @:translateMsg("教程关指引", "advice.starshard_tutorial.1")
    public static inline var STRING_STATE_1:String = "点击发射器！";
    @:translateMsg("教程关指引", "advice.starshard_tutorial.2")
    public static inline var STRING_STATE_2:String = "干得漂亮！";
    @:translateMsg("教程关指引", "advice.starshard_tutorial.3")
    public static inline var STRING_STATE_3:String = "绿色的怪物会携带星之碎片！";
    @:translateMsg("教程关指引", "advice.starshard_tutorial.4")
    public static inline var STRING_STATE_4:String = "点击收集星之碎片！";
    @:translateMsg("教程关指引", "advice.starshard_tutorial.5")
    public static inline var STRING_STATE_5:String = "现在干掉铁盔僵尸！";

    public static var PROP_STATE:VanillaLevelPropertyMeta<Int> = new VanillaLevelPropertyMeta<Int>("state");
    public static var PROP_TUTORIAL_TIMER:VanillaLevelPropertyMeta<FrameTimer> = new VanillaLevelPropertyMeta<FrameTimer>("tutorialTimer");
}
