// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/TutorialStage.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.buffs.level.TutorialPickaxeDisableBuff;
import mvz2.gamecontent.buffs.seedpacks.TutorialDisableBuff;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.enemies.VanillaSpawnID;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.gamecontent.talk.VanillaTalkID;
import mvz2.vanilla.audios.VanillaMusicID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.pickups.VanillaPickupExt;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import pvzengine.entities.EntityTypes;
import mvz2logic.helditems.LogicHeldTypes;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicStageProps;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageDefinition;
import tools.EnumerableExt;
import tools.FrameTimer;
import tools.RandomGenerator;
using mvz2logic.blueprints.LogicSeedProps;

@:autoStageDefinition(VanillaStageNames.tutorial)
class TutorialStage extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override public function OnStart(level:LevelEngine):Void
    {
        super.OnStart(level);
        SetTutorialTimer(level, new FrameTimer(90));
        SetTutorialRNG(level, level.CreateRNG());
        level.SetEnergy(150);
        level.SetSeedSlotCount(4);
        LogicLevelExt.FillSeedPacks(level, [
            VanillaContraptionID.dispenser,
            VanillaContraptionID.furnace,
            VanillaContraptionID.obsidian,
            VanillaContraptionID.mineTNT,
        ]);
        StartState(level, STATE_CLICK_DISPENSER);
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
    private function GetLaneWithoutDispensers(level:LevelEngine):Int
    {
        var dispensers = level.FindEntities(VanillaContraptionID.dispenser);
        var lanes:Array<Int> = [];
        var maxLane = level.GetMaxLaneCount();
        var tutorialRNG = GetTutorialRNG(level);
        for (i in 0...maxLane)
        {
            // C#: dispensers.All(d => d.GetLane() != i)
            var allWithout = true;
            for (d in dispensers)
            {
                if (d.GetLane() == i)
                    allWithout = false;
            }
            if (allWithout)
            {
                lanes.push(i);
            }
        }
        var lane:Int;
        if (lanes.length <= 0)
        {
            lane = tutorialRNG != null ? tutorialRNG.Next(0, maxLane) : 0;
        }
        else
        {
            lane = tutorialRNG != null ? EnumerableExt.Random(lanes, tutorialRNG) : EnumerableExt.FirstOrDefault(lanes);
        }
        return lane;
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
            case STATE_CLICK_DISPENSER:
                {
                    var dispenserSeedPack = level.GetSeedPack(VanillaContraptionID.dispenser);
                    var furnaceSeedPack = level.GetSeedPack(VanillaContraptionID.furnace);
                    if (furnaceSeedPack != null)
                        furnaceSeedPack.AddBuff(TutorialDisableBuff);
                    var obsidianSeedPack = level.GetSeedPack(VanillaContraptionID.obsidian);
                    if (obsidianSeedPack != null)
                        obsidianSeedPack.AddBuff(TutorialDisableBuff);
                    var mineTNTSeedPack = level.GetSeedPack(VanillaContraptionID.mineTNT);
                    if (mineTNTSeedPack != null)
                        mineTNTSeedPack.AddBuff(TutorialDisableBuff);
                    level.AddBuff(TutorialPickaxeDisableBuff);
                    LogicStageProps.SetNoEnergy(level, true);
                    if (dispenserSeedPack != null)
                    {
                        dispenserSeedPack.SetTwinkling(true);
                        LogicLevelExt.SetHintArrowPointToBlueprint(level, dispenserSeedPack.GetIndex());
                    }
                }
            case STATE_PLACE_DISPENSER:
                {
                    var dispenserSeedPack = level.GetSeedPack(VanillaContraptionID.dispenser);
                    if (dispenserSeedPack != null)
                        dispenserSeedPack.SetTwinkling(false);
                    LogicLevelExt.HideHintArrow(level);
                }
            case STATE_DISPENSER_PLACED:
                LogicStageProps.SetNoEnergy(level, false);
            case STATE_COLLECT_REDSTONE:
                {
                    var redstones = level.FindEntities(function(e) return e.IsEntityOf(VanillaPickupID.redstone));
                    var redstone = EnumerableExt.FirstOrDefault(redstones);
                    if (redstone != null)
                    {
                        LogicLevelExt.SetHintArrowPointToEntity(level, redstone);
                    }
                }
            case STATE_COLLECT_TO_PLACE_DISPENSER:
                LogicLevelExt.HideHintArrow(level);
            case STATE_PLACE_DISPENSER_TO_KILL_ZOMBIE:
                {
                    var lane = GetLaneWithoutDispensers(level);
                    LogicLevelExt.SpawnEnemyByID(level, VanillaSpawnID.zombie, lane);
                }
            case STATE_ZOMBIE_KILLED, STATE_FURNACE_PLACED, STATE_FURNACE_PLACED_2, STATE_HELMET_ZOMBIE_BLOWEN_UP:
                StartTimer(level, 90);
            case STATE_PLACE_FURNACE:
                {
                    var furnace = level.GetSeedPack(VanillaContraptionID.furnace);
                    if (furnace != null)
                    {
                        furnace.RemoveBuffs(TutorialDisableBuff);
                        furnace.SetTwinkling(true);
                        LogicLevelExt.SetHintArrowPointToBlueprint(level, furnace.GetIndex());
                    }
                }
            case STATE_PLACE_OBSIDIAN:
                {
                    var obsidian = level.GetSeedPack(VanillaContraptionID.obsidian);
                    if (obsidian != null)
                    {
                        obsidian.RemoveBuffs(TutorialDisableBuff);
                        obsidian.SetTwinkling(true);
                        LogicLevelExt.SetHintArrowPointToBlueprint(level, obsidian.GetIndex());
                    }

                    var maxLane = level.GetMaxLaneCount();
                    var dispensers = level.FindEntities(VanillaContraptionID.dispenser);
                    var lane:Int;
                    if (dispensers.length <= 0)
                    {
                        var tutorialRNG = GetTutorialRNG(level);
                        lane = tutorialRNG != null ? tutorialRNG.Next(0, maxLane) : 0;
                    }
                    else
                    {
                        lane = dispensers[0].GetLane();
                    }
                    var zombie = LogicLevelExt.SpawnEnemyByID(level, VanillaSpawnID.ironHelmettedZombie, lane);
                    if (zombie != null)
                    {
                        var armor = VanillaEntityExt.GetMainArmor(zombie);
                        if (armor != null)
                        {
                            armor.Health = armor.GetMaxHealth() * 0.5;
                        }
                    }
                }
            case STATE_HELMET_ZOMBIE_KILLED:
                {
                    var obsidian = level.GetSeedPack(VanillaContraptionID.obsidian);
                    if (obsidian != null)
                    {
                        obsidian.SetTwinkling(false);
                    }
                    StartTimer(level, 90);
                }
            case STATE_CLICK_MINE_TNT:
                {
                    var mineTNT = level.GetSeedPack(VanillaContraptionID.mineTNT);
                    if (mineTNT != null)
                    {
                        mineTNT.RemoveBuffs(TutorialDisableBuff);
                        mineTNT.SetTwinkling(true);
                        LogicLevelExt.SetHintArrowPointToBlueprint(level, mineTNT.GetIndex());
                    }
                }
            case STATE_BLOWS_UP_HELMET_ZOMBIE:
                {
                    var mineTNT = level.GetSeedPack(VanillaContraptionID.mineTNT);
                    if (mineTNT != null)
                        mineTNT.SetTwinkling(false);
                    LogicLevelExt.HideHintArrow(level);
                    var lane = GetLaneWithoutDispensers(level);
                    LogicLevelExt.SpawnEnemyByID(level, VanillaSpawnID.ironHelmettedZombie, lane);
                }
            case STATE_HOLD_PICKAXE:
                {
                    level.RemoveBuffs(TutorialPickaxeDisableBuff);
                    LogicStageProps.SetNoEnergy(level, true);
                    LogicLevelExt.SetHintArrowPointToPickaxe(level);
                }
            case STATE_DIG_CONTRAPTIONS:
                {
                    LogicLevelExt.HideHintArrow(level);
                }
        }
    }
    private function UpdateState(level:LevelEngine):Void
    {
        var state = GetTutorialState(level);
        switch (state)
        {
            case STATE_CLICK_DISPENSER:
                {
                    var heldEntityID = VanillaLevelExt.GetHeldSeedEntityID(level);
                    if (heldEntityID == VanillaContraptionID.dispenser)
                    {
                        StartState(level, STATE_PLACE_DISPENSER);
                    }
                }
            case STATE_PLACE_DISPENSER:
                if (level.EntityExists(VanillaContraptionID.dispenser))
                {
                    StartState(level, STATE_DISPENSER_PLACED);
                }
            case STATE_DISPENSER_PLACED:
                if (level.EntityExists(VanillaPickupID.redstone))
                {
                    StartState(level, STATE_COLLECT_REDSTONE);
                }
            case STATE_COLLECT_REDSTONE:
                if (level.EntityExists(function(e) return e.IsEntityOf(VanillaPickupID.redstone) && VanillaPickupExt.IsCollected(e)))
                {
                    StartState(level, STATE_COLLECT_TO_PLACE_DISPENSER);
                }
            case STATE_COLLECT_TO_PLACE_DISPENSER:
                if (level.Energy >= 100)
                {
                    StartState(level, STATE_PLACE_DISPENSER_TO_KILL_ZOMBIE);
                }
            case STATE_PLACE_DISPENSER_TO_KILL_ZOMBIE:
                if (level.GetEntities(EntityTypes.ENEMY).length <= 0)
                {
                    StartState(level, STATE_ZOMBIE_KILLED);
                }
            case STATE_ZOMBIE_KILLED, STATE_FURNACE_PLACED, STATE_FURNACE_PLACED_2, STATE_HELMET_ZOMBIE_KILLED, STATE_HELMET_ZOMBIE_BLOWEN_UP:
                RunTimer(level);
            case STATE_PLACE_FURNACE:
                {
                    var heldEntityID = VanillaLevelExt.GetHeldSeedEntityID(level);
                    if (heldEntityID == VanillaContraptionID.furnace)
                    {
                        var furnaceSeedPack = level.GetSeedPack(VanillaContraptionID.furnace);
                        if (furnaceSeedPack != null)
                            furnaceSeedPack.SetTwinkling(false);
                        LogicLevelExt.HideHintArrow(level);
                    }
                    if (level.EntityExists(VanillaContraptionID.furnace))
                    {
                        StartState(level, STATE_FURNACE_PLACED);
                    }
                }
            case STATE_PLACE_3_FURNACES:
                if (level.FindEntities(VanillaContraptionID.furnace).length >= 3 && level.Energy >= 50)
                {
                    StartState(level, STATE_PLACE_OBSIDIAN);
                }
            case STATE_PLACE_OBSIDIAN:
                {
                    var heldEntityID = VanillaLevelExt.GetHeldSeedEntityID(level);
                    if (heldEntityID == VanillaContraptionID.obsidian)
                    {
                        var obsidianSeedPack = level.GetSeedPack(VanillaContraptionID.obsidian);
                        if (obsidianSeedPack != null)
                            obsidianSeedPack.SetTwinkling(false);
                        LogicLevelExt.HideHintArrow(level);
                    }
                    if (level.GetEntities(EntityTypes.ENEMY).length <= 0)
                    {
                        StartState(level, STATE_HELMET_ZOMBIE_KILLED);
                    }
                }
            case STATE_CLICK_MINE_TNT:
                {
                    var heldEntityID = VanillaLevelExt.GetHeldSeedEntityID(level);
                    if (heldEntityID == VanillaContraptionID.mineTNT)
                    {
                        StartState(level, STATE_BLOWS_UP_HELMET_ZOMBIE);
                    }
                }
            case STATE_BLOWS_UP_HELMET_ZOMBIE:
                if (level.GetEntities(EntityTypes.ENEMY).length <= 0)
                {
                    StartState(level, STATE_HELMET_ZOMBIE_BLOWEN_UP);
                }
            case STATE_HOLD_PICKAXE:
                {
                    for (pickup in level.GetEntities(EntityTypes.PICKUP))
                    {
                        pickup.Timeout = Std.int(Math.min(pickup.Timeout, 30));
                    }
                    if (LogicLevelExt.GetHeldItemType(level) == LogicHeldTypes.pickaxe)
                    {
                        StartState(level, STATE_DIG_CONTRAPTIONS);
                    }
                }
            case STATE_DIG_CONTRAPTIONS:
                {
                    for (pickup in level.GetEntities(EntityTypes.PICKUP))
                    {
                        pickup.Timeout = Std.int(Math.min(pickup.Timeout, 30));
                    }
                    if (level.GetEntities(EntityTypes.PLANT).length <= 0)
                    {
                        for (particle in level.FindEntities(VanillaEffectID.fragment))
                        {
                            particle.Remove();
                        }
                        LogicLevelExt.StopLevel(level);
                        LogicLevelExt.PlayMusic(level, VanillaMusicID.mainmenu);
                        LogicLevelExt.HideAdvice(level);
                        level.SetEnergy(level.GetStartEnergy());
                        level.ResetAllRechargeProgress();
                        level.ClearSeedPacks();
                        LogicStageProps.SetNoEnergy(level, false);
                        level.ChangeStage(VanillaStageID.prologue);
                        for (i in 0...level.GetSeedSlotCount())
                        {
                            var seedPack = level.GetSeedPackAt(i);
                            if (seedPack != null)
                            {
                                seedPack.SetTwinkling(false);
                            }
                        }
                        LogicLevelExt.SimpleStartTalk(level, VanillaTalkID.tutorial, 3, 2, null, null, function()
                        {
                            LogicLevelExt.BeginLevel(level);
                        });
                    }
                }
        }
    }
    private function OnTimerStop(level:LevelEngine):Void
    {
        var state = GetTutorialState(level);
        switch (state)
        {
            case STATE_ZOMBIE_KILLED:
                StartState(level, STATE_PLACE_FURNACE);
            case STATE_FURNACE_PLACED:
                StartState(level, STATE_FURNACE_PLACED_2);
            case STATE_FURNACE_PLACED_2:
                StartState(level, STATE_PLACE_3_FURNACES);
            case STATE_HELMET_ZOMBIE_KILLED:
                StartState(level, STATE_CLICK_MINE_TNT);
            case STATE_HELMET_ZOMBIE_BLOWEN_UP:
                StartState(level, STATE_HOLD_PICKAXE);
        }
    }

    public static function GetTutorialTimer(level:LevelEngine):Null<FrameTimer> return level.GetProperty(PROP_TUTORIAL_TIMER);
    public static function SetTutorialTimer(level:LevelEngine, value:FrameTimer):Void level.SetProperty(PROP_TUTORIAL_TIMER, value);
    public static function GetTutorialRNG(level:LevelEngine):Null<RandomGenerator> return level.GetProperty(PROP_TUTORIAL_RNG);
    public static function SetTutorialRNG(level:LevelEngine, value:RandomGenerator):Void level.SetProperty(PROP_TUTORIAL_RNG, value);
    public static function GetTutorialState(level:LevelEngine):Int return level.GetProperty(PROP_STATE);
    public static function SetTutorialState(level:LevelEngine, value:Int):Void level.SetProperty(PROP_STATE, value);


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
        STRING_STATE_10,
        STRING_STATE_11,
        STRING_STATE_12,
        STRING_STATE_13,
        STRING_STATE_14,
        STRING_STATE_15,
        STRING_STATE_16,
        STRING_STATE_17,
    ];
    public static inline var STATE_CLICK_DISPENSER:Int = 0;
    public static inline var STATE_PLACE_DISPENSER:Int = 1;
    public static inline var STATE_DISPENSER_PLACED:Int = 2;
    public static inline var STATE_COLLECT_REDSTONE:Int = 3;
    public static inline var STATE_COLLECT_TO_PLACE_DISPENSER:Int = 4;
    public static inline var STATE_PLACE_DISPENSER_TO_KILL_ZOMBIE:Int = 5;
    public static inline var STATE_ZOMBIE_KILLED:Int = 6;
    public static inline var STATE_PLACE_FURNACE:Int = 7;
    public static inline var STATE_FURNACE_PLACED:Int = 8;
    public static inline var STATE_FURNACE_PLACED_2:Int = 9;
    public static inline var STATE_PLACE_3_FURNACES:Int = 10;
    public static inline var STATE_PLACE_OBSIDIAN:Int = 11;
    public static inline var STATE_HELMET_ZOMBIE_KILLED:Int = 12;
    public static inline var STATE_CLICK_MINE_TNT:Int = 13;
    public static inline var STATE_BLOWS_UP_HELMET_ZOMBIE:Int = 14;
    public static inline var STATE_HELMET_ZOMBIE_BLOWEN_UP:Int = 15;
    public static inline var STATE_HOLD_PICKAXE:Int = 16;
    public static inline var STATE_DIG_CONTRAPTIONS:Int = 17;

    public static inline var CONTEXT_STATE_PREFIX:String = "advice.tutorial.";
    public static inline var CONTEXT_STATE:String = CONTEXT_STATE_PREFIX + "{0}";

    @:translateMsg("教程关指引", "advice.tutorial.0")
    public static inline var STRING_STATE_0:String = "点击器械卡牌选中器械！";
    @:translateMsg("教程关指引", "advice.tutorial.1")
    public static inline var STRING_STATE_1:String = "点击草坪放置器械！";
    @:translateMsg("教程关指引", "advice.tutorial.2")
    public static inline var STRING_STATE_2:String = "干得漂亮！";
    @:translateMsg("教程关指引", "advice.tutorial.3")
    public static inline var STRING_STATE_3:String = "点击红石收集能量！";
    @:translateMsg("教程关指引", "advice.tutorial.4")
    public static inline var STRING_STATE_4:String = "收集足够的能量来放置器械！";
    @:translateMsg("教程关指引", "advice.tutorial.5")
    public static inline var STRING_STATE_5:String = "用发射器干掉僵尸！";
    @:translateMsg("教程关指引", "advice.tutorial.6")
    public static inline var STRING_STATE_6:String = "干得漂亮！";
    @:translateMsg("教程关指引", "advice.tutorial.7")
    public static inline var STRING_STATE_7:String = "选择熔炉并放置！";
    @:translateMsg("教程关指引", "advice.tutorial.8")
    public static inline var STRING_STATE_8:String = "熔炉能为你提供额外的红石！";
    @:translateMsg("教程关指引", "advice.tutorial.9")
    public static inline var STRING_STATE_9:String = "熔炉越多，你放器械的速度就越快！";
    @:translateMsg("教程关指引", "advice.tutorial.10")
    public static inline var STRING_STATE_10:String = "请至少放下三个熔炉！";
    @:translateMsg("教程关指引", "advice.tutorial.11")
    public static inline var STRING_STATE_11:String = "用黑曜石来挡住僵尸的进攻！";
    @:translateMsg("教程关指引", "advice.tutorial.12")
    public static inline var STRING_STATE_12:String = "干得漂亮！";
    @:translateMsg("教程关指引", "advice.tutorial.13")
    public static inline var STRING_STATE_13:String = "地雷TNT在一段时间的填装后能炸飞敌人！";
    @:translateMsg("教程关指引", "advice.tutorial.14")
    public static inline var STRING_STATE_14:String = "用地雷TNT炸死铁盔僵尸！";
    @:translateMsg("教程关指引", "advice.tutorial.15")
    public static inline var STRING_STATE_15:String = "干得漂亮！";
    @:translateMsg("教程关指引", "advice.tutorial.16")
    public static inline var STRING_STATE_16:String = "最后，镐子能够挖掉你所放下的器械！";
    @:translateMsg("教程关指引", "advice.tutorial.17")
    public static inline var STRING_STATE_17:String = "试着挖掉所有器械！";

    public static var PROP_STATE:VanillaLevelPropertyMeta<Int> = new VanillaLevelPropertyMeta<Int>("state");
    public static var PROP_TUTORIAL_RNG:VanillaLevelPropertyMeta<RandomGenerator> = new VanillaLevelPropertyMeta<RandomGenerator>("tutorialRNG");
    public static var PROP_TUTORIAL_TIMER:VanillaLevelPropertyMeta<FrameTimer> = new VanillaLevelPropertyMeta<FrameTimer>("tutorialTimer");
}
