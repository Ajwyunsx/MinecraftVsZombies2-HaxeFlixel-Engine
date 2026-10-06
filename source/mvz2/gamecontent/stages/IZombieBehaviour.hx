// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/IZombie/IZombieBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.effects.GemEffect;
import mvz2.gamecontent.effects.IZObserver;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.pickups.ClearPickup;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.izombie.IZombieMap;
import mvz2.vanilla.level.VanillaLevelStates;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import mvz2logic.Global;
import mvz2logic.entities.LogicEnemyProps;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.EntityTypes;
import mvz2logic.games.LogicGameDefinitionsExt;
import mvz2logic.izombie.IZombieLayoutDefinition;
import mvz2logic.level.GameOverTypes;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.level.LogicStageProps;
import mvz2logic.localization.LogicStrings;
import mvz2logic.stats.LogicStats;
using mvz2logic.difficulties.LogicDifficultyProps;
import pvzengine.NamespaceID;
import pvzengine.SeedPack;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageBehaviour;
import pvzengine.level.StageDefinition;
import tools.FrameTimer;
import unity.Color;
import unity.Mathf;
import unity.Vector3;

// abstract
class IZombieBehaviour extends StageBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
    }
    override public function Setup(level:LevelEngine):Void
    {
        super.Setup(level);
        var layoutID = GetNewLayout(level.CurrentFlag, level.GetRoundRNG());
        SetCurrentLayout(level, layoutID);
        var layout = LogicGameDefinitionsExt.GetIZombieLayoutDefinition(level.Content, layoutID);
        if (layout != null)
        {
            GenerateMap(level, layout);
        }
        SetRoundTimer(level, new FrameTimer(ROUND_COOLDOWN));
    }
    override public function Start(level:LevelEngine):Void
    {
        super.Start(level);
        level.SetEnergy(level.GetStartEnergy());
        level.SetSeedSlotCount(10);
        LogicLevelExt.SetStarshardActive(level, false);
        if (!AllowPickaxe)
        {
            LogicLevelExt.SetPickaxeActive(level, false);
        }
        LogicLevelExt.SetTriggerActive(level, false);
        level.WaveState = STATE_NORMAL;

        var layoutID = GetCurrentLayout(level);
        if (layoutID == null)
            return;
        var layout = LogicGameDefinitionsExt.GetIZombieLayoutDefinition(level.Content, layoutID);
        if (layout == null)
            return;
        ReplaceBlueprints(level, layout);
    }
    override public function Update(level:LevelEngine):Void
    {
        super.Update(level);
        if (level.WaveState == STATE_NORMAL)
        {
            CheckGameOver(level);

            // PORT-NOTE: C# LINQ .All(e => IZObserver.IsPass(e)) 展开为显式循环（空集合时为 true）。
            var allPass = true;
            for (e in level.FindEntities(VanillaEffectID.izObserver))
            {
                if (!IZObserver.IsPass(e))
                {
                    allPass = false;
                    break;
                }
            }
            if (allPass)
            {
                level.CurrentFlag++;

                // 写入统计。
                if (LogicStageProps.IsEndless(level))
                {
                    if (Global.Saves.GetStat(LogicStats.CATEGORY_MAX_ENDLESS_FLAGS, level.StageID) < level.CurrentFlag)
                    {
                        Global.Saves.SetStat(LogicStats.CATEGORY_MAX_ENDLESS_FLAGS, level.StageID, level.CurrentFlag);
                    }
                }

                var maxRound = GetMaxRounds();
                var currentRound = level.CurrentFlag;

                if (maxRound <= 0 || maxRound > currentRound)
                {
                    level.WaveState = STATE_NEXT_ROUND;
                    if (maxRound <= 0)
                    {
                        LogicLevelExt.ShowAdvicePluralUsingKey(level, LogicStrings.CONTEXT_ADVICE, VanillaStrings.ADVICE_IZ_STREAK, currentRound, 0, 150, [Std.string(currentRound)]);
                    }
                    else
                    {
                        var remained = maxRound - currentRound;
                        LogicLevelExt.ShowAdvicePluralUsingKey(level, LogicStrings.CONTEXT_ADVICE, VanillaStrings.ADVICE_IZ_ROUNDS_LEFT, remained, 0, 150, [Std.string(remained)]);
                    }
                    var roundTimer = GetRoundTimer(level);
                    if (roundTimer != null)
                        roundTimer.Reset();

                    LogicLevelExt.UpdateLevelName(level);

                    var diamondInterval = 3;
                    if (level.CurrentFlag % diamondInterval == 0)
                    {
                        var money = 250;
                        var difficulty = level.Difficulty;
                        var difficultyMeta = level.Content.GetDifficultyDefinition(difficulty);
                        if (difficultyMeta != null)
                        {
                            money = difficultyMeta.GetPuzzleMoney();
                        }
                        var x = level.GetLawnCenterX();
                        var z = level.GetLawnCenterZ();
                        var y = level.GetGroundY(x, z);
                        GemEffect.SpawnGemEffects(level, money, new Vector3(x, y, z), null);
                    }
                }
                else
                {
                    level.WaveState = STATE_FINISHED;
                    var x = level.GetEntityColumnX(Mathf.FloorToInt(level.GetMaxColumnCount() * 0.5));
                    var z = level.GetEntityLaneZ(Mathf.FloorToInt(level.GetMaxLaneCount() * 0.5));
                    var y = level.GetGroundY(x, z);
                    var position = new Vector3(x, y, z);
                    ClearPickup.Produce(level, position);
                }
            }
        }
        else if (level.WaveState == STATE_NEXT_ROUND)
        {
            var roundTimer = GetRoundTimer(level);
            if (roundTimer != null)
            {
                roundTimer.Run();
                if (roundTimer.Expired)
                {
                    NextRound(level);
                }
            }
        }
    }
    public function GetMaxRounds():Int return 1;
    // abstract
    public function ReplaceBlueprints(level:LevelEngine, layout:IZombieLayoutDefinition):Void
    {
        throw "abstract";
    }
    // abstract
    public function GetNewLayout(round:Int, rng:tools.RandomGenerator):NamespaceID
    {
        throw "abstract";
    }
    public function NextRound(level:LevelEngine):Void
    {
        var layoutID = GetNewLayout(level.CurrentFlag, level.GetRoundRNG());
        NextRoundWithLayout(level, layoutID);
    }
    // PORT-NOTE: C# NextRound(LevelEngine, NamespaceID) 重载改名为 NextRoundWithLayout（Haxe 不支持重载）。
    public function NextRoundWithLayout(level:LevelEngine, layoutID:NamespaceID):Void
    {
        for (ent in level.GetEntities())
        {
            ent.Remove();
        }
        var scene = Global.Scene;
        scene.SetScreenCoverColor(Color.white);
        scene.FadeScreenCoverColor(new Color(1, 1, 1, 0), 0.25);
        LogicLevelExt.PlaySound(level, VanillaSoundID.hugeWave);
        SetCurrentLayout(level, layoutID);
        var layout = LogicGameDefinitionsExt.GetIZombieLayoutDefinition(level.Content, layoutID);
        if (layout != null)
        {
            GenerateMap(level, layout);
            ReplaceBlueprints(level, layout);
        }
        level.WaveState = STATE_NORMAL;
    }
    private function GenerateMap(level:LevelEngine, layout:IZombieLayoutDefinition):Void
    {
        var map = new IZombieMap(level, layout.Columns, level.GetMaxLaneCount(), level.CurrentFlag);
        if (layout != null)
        {
            layout.Fill(map, level.GetSpawnRNG());
        }
        map.Apply();

        for (lane in 0...map.Lanes)
        {
            var x = level.GetColumnX(map.Columns);
            var z = level.GetLaneCenterZ(lane);
            var y = level.GetGroundY(x, z);
            var pos = new Vector3(x, y, z);
            level.Spawn(VanillaEffectID.redline, pos, null);

            var observerX = level.GetColumnX(0) - level.GetGridWidth() * 0.5;
            var observerY = level.GetGroundY(observerX, z);
            var observerPos = new Vector3(observerX, y, z);
            level.Spawn(VanillaEffectID.izObserver, observerPos, null);
        }
    }
    private function CheckGameOver(level:LevelEngine):Void
    {
        var cannotAfford = false;
        if (level.GetSeedPackCount() <= 0)
        {
            cannotAfford = true;
        }
        else
        {
            // PORT-NOTE: C# LINQ OfType<SeedPack>().Select(s => s.GetCost()).Min() 展开为显式循环。
            var minSeedPackEnergy = 0;
            var hasSeedPack = false;
            for (seedPack in level.GetAllSeedPacks())
            {
                if (!Std.isOfType(seedPack, SeedPack))
                    continue;
                var cost = (cast seedPack : SeedPack).GetCost();
                if (!hasSeedPack || cost < minSeedPackEnergy)
                {
                    minSeedPackEnergy = cost;
                    hasSeedPack = true;
                }
            }
            if (level.Energy < minSeedPackEnergy)
            {
                cannotAfford = true;
            }
        }
        if (cannotAfford)
        {
            // 上帝模式
            if (LogicLevelProps.IsGodMode(level))
                return;
            // 存在有效怪物
            if (level.EntityExists(function(e) return e.Type == EntityTypes.ENEMY && LogicEntityExt.IsHostileEntity(e) && !LogicEnemyProps.IsNotActiveEnemy(e)))
                return;
            // 存在能量掉落物
            if (level.EntityExists(function(e) return e.Type == EntityTypes.PICKUP && VanillaPickupProps.GetEnergyValue(e) > 0))
                return;
            // 可以使用铁镐并且存在熔炉
            if (LogicLevelProps.CanUsePickaxe(level) && level.EntityExists(VanillaContraptionID.furnace))
                return;
            level.GameOver(GameOverTypes.INSTANT, null, VanillaStrings.DEATH_MESSAGE_IZ_LOSE_ALL_ENEMIES);
        }
    }
    public function GetCurrentLayout(level:LevelEngine):Null<NamespaceID> return level.GetProperty(PROP_CURRENT_LAYOUT);
    public function SetCurrentLayout(level:LevelEngine, value:NamespaceID):Void level.SetProperty(PROP_CURRENT_LAYOUT, value);
    public function GetRoundTimer(level:LevelEngine):Null<FrameTimer> return level.GetProperty(PROP_ROUND_TIMER);
    public function SetRoundTimer(level:LevelEngine, value:FrameTimer):Void level.SetProperty(PROP_ROUND_TIMER, value);

    // #region 属性字段
    private static inline var PROP_REGION:String = "i_zombie_stage";
    public static inline var ROUND_COOLDOWN:Int = 150;
    @:levelPropertyRegistry(PROP_REGION)
    public static var PROP_ROUND_TIMER:VanillaLevelPropertyMeta<FrameTimer> = new VanillaLevelPropertyMeta<FrameTimer>("RoundTimer");
    @:levelPropertyRegistry(PROP_REGION)
    public static var PROP_CURRENT_LAYOUT:VanillaLevelPropertyMeta<NamespaceID> = new VanillaLevelPropertyMeta<NamespaceID>("CurrentLayout");
    public static inline var STATE_NORMAL:Int = VanillaLevelStates.STATE_IZ_NORMAL;
    public static inline var STATE_NEXT_ROUND:Int = VanillaLevelStates.STATE_IZ_NEXT;
    public static inline var STATE_FINISHED:Int = VanillaLevelStates.STATE_IZ_FINISHED;
    public var AllowPickaxe(get, never):Bool;
    public function get_AllowPickaxe():Bool return false;
    // #endregion
}
