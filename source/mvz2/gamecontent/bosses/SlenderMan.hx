// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/SlenderMan.cs
package mvz2.gamecontent.bosses;

import Lambda;
import mukioi18n.TranslateMsgAttribute;
import mvz2.gamecontent.buffs.enemies.FlyBuff;
import mvz2.gamecontent.buffs.enemies.NightmareComeTrueBuff;
import mvz2.gamecontent.buffs.level.NightmareDecrepifyBuff;
import mvz2.gamecontent.buffs.seedpacks.SlenderManMindSwapBuff;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.effects.NightmarePortal;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.Global;
import mvz2logic.blueprints.LogicBlueprintID;
import mvz2logic.blueprints.SeedTypes;
import pvzengine.entities.EntityTypes;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.grids.LogicGridExt;
import mvz2logic.level.LogicLevelExt;
import tools.Transitions;
import pvzengine.NamespaceID;
import pvzengine.RandomGenerator;
import pvzengine.buffs.Buff;
import pvzengine.damages.DamageOutput;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.entities.EntitySourceReference;
import pvzengine.level.LevelEngine;
import tools.EnumerableExt;
import tools.FrameTimer;
import unity.Mathf;
import unity.Vector2Int;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.helditems.VanillaHeldItemExt;
using mvz2logic.blueprints.LogicSeedProps;
using mvz2logic.entities.LogicEntityExt;
import mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;

@:autoEntityBehaviourDefinition(VanillaBossNames.slenderman)
class SlenderMan extends BossBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    // #region 回调
    override public function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetMoveTimer(entity, new FrameTimer(250));
        SetPortalTimer(entity, new FrameTimer(300));
        SetMindSwapTimer(entity, new FrameTimer(200));

        SetMoveRNG(entity, new RandomGenerator(entity.RNG.Next()));
        SetPortalRNG(entity, new RandomGenerator(entity.RNG.Next()));
        SetMindSwapRNG(entity, new RandomGenerator(entity.RNG.Next()));
        SetFateOptionRNG(entity, new RandomGenerator(entity.RNG.Next()));
        SetEventRNG(entity, new RandomGenerator(entity.RNG.Next()));

        var flyBuff = entity.AddBuff(FlyBuff);
        flyBuff.SetProperty(FlyBuff.PROP_FLY_SPEED, 0.2);
        flyBuff.SetProperty(FlyBuff.PROP_FLY_SPEED_FACTOR, 0.5);
        flyBuff.SetProperty(FlyBuff.PROP_TARGET_HEIGHT, 80);
    }
    override public function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (entity.IsDead)
            return;
        MoveUpdate(entity);
        PortalUpdate(entity);
        MindSwapUpdate(entity);
    }
    override public function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        if (entity.IsDead)
        {
            entity.Timeout--;
            if (entity.Timeout <= 0)
            {
                entity.Remove();
            }
        }
        else
        {
            var readyTimes = GetReadyFateTimes(entity);
            if (readyTimes > 0)
            {
                ChooseFate(entity);
                readyTimes--;
                SetReadyFateTimes(entity, readyTimes);
            }
        }
        entity.SetAnimationBool("IsDead", entity.IsDead);
    }
    override public function PostTakeDamage(damage:DamageOutput):Void
    {
        super.PostTakeDamage(damage);
        var boss = damage.Entity;
        if (boss.IsDead)
            return;
        var maxFateTimes = GetMaxFateTimes(boss.Level);
        var stageHP = boss.GetMaxHealth() / (maxFateTimes + 2);
        var newStage = Mathf.FloorToInt(maxFateTimes + 2 - boss.Health / stageHP);
        var selectedFateTimes = GetSelectedFateTimes(boss);
        if (newStage > selectedFateTimes && newStage >= 0)
        {
            SetSelectedFateTimes(boss, newStage);
            var readyTimes = GetReadyFateTimes(boss);
            SetReadyFateTimes(boss, readyTimes + newStage - selectedFateTimes);
        }
    }
    override public function PostDeath(entity:Entity, deathInfo:DeathInfo):Void
    {
        super.PostDeath(entity, deathInfo);
        entity.PlaySound(VanillaSoundID.slendermanDeath);

        var particles = entity.Spawn(VanillaEffectID.darkMatterParticles, entity.GetCenter());
        if (particles != null)
        {
            particles.SetParent(entity);
        }

        entity.SetAnimationBool("IsDead", true);
        entity.Timeout = 180;
    }
    // #endregion

    // #region Move
    private function MoveUpdate(entity:Entity):Void
    {
        var timer = GetMoveTimer(entity);
        if (timer.RunToExpiredAndNotNull())
        {
            timer.Reset();
            StartMove(entity);
        }
        var motionTime = GetMoveTimeout(entity);
        if (motionTime <= 0)
            return;
        var lastPercent = Mathf.Clamp01(1 - motionTime / MAX_MOVE_TIMEOUT);
        var lastMovePercent = Transitions.EaseInAndOut(lastPercent);

        motionTime--;

        SetMoveTimeout(entity, motionTime);

        var percent = Mathf.Clamp01(1 - motionTime / MAX_MOVE_TIMEOUT);
        var movePercent = Transitions.EaseInAndOut(percent);
        var displacement = GetMoveDisplacement(entity);

        var addedPercent = movePercent - lastMovePercent;
        entity.Position += displacement * addedPercent;

        // End Moving.
        if (motionTime <= 0)
        {
            motionTime = 0;
            SetMoveDisplacement(entity, Vector3.zero);
        }
    }
    private function StartMove(entity:Entity):Void
    {
        SetMoveTimeout(entity, MAX_MOVE_TIMEOUT);
        var endLane = 0;
        var endColumn = 0;
        var level = entity.Level;
        var moveRNG = GetMoveRNG(entity);
        if (moveRNG != null)
        {
            do
            {
                endLane = moveRNG.Next(0, level.GetMaxLaneCount());
                endColumn = moveRNG.Next(0, level.GetMaxColumnCount());
            }
            while (endLane == entity.GetLane() && endColumn == entity.GetColumn());
        }

        var endX = level.GetEntityColumnX(endColumn);
        var endZ = level.GetEntityLaneZ(endLane);
        SetMoveDisplacement(entity, new Vector3(endX - entity.Position.x, 0, endZ - entity.Position.z));
    }
    // #endregion

    // #region Portal
    private function PortalUpdate(entity:Entity):Void
    {
        var portalTimer = GetPortalTimer(entity);
        if (portalTimer.RunToExpiredAndNotNull())
        {
            portalTimer.Reset();
            CreatePortals(entity);
        }
    }

    private function CreatePortals(entity:Entity):Void
    {
        var level = entity.Level;
        var placePool:Array<Vector2Int> = [];

        var maxColumnCount = level.GetMaxColumnCount();
        var maxRowCount = level.GetMaxLaneCount();
        for (c in (maxColumnCount - 2)...maxColumnCount)
        {
            for (r in 0...maxRowCount)
            {
                placePool.push(new Vector2Int(c, r));
            }
        }
        var portalRNG = GetPortalRNG(entity);
        if (portalRNG != null)
        {
            for (i in 0...3)
            {
                var enemyID = GetRandomPortalEnemyID(portalRNG);
                var index = portalRNG.Next(0, placePool.length);
                var place = placePool[index];
                placePool.remove(place);

                var x = level.GetEntityColumnX(place.x);
                var z = level.GetEntityLaneZ(place.y);
                var y = level.GetGroundY(x, z);
                var pos = new Vector3(x, y, z);
                SpawnPortal(entity, pos, enemyID);
            }
            entity.PlaySound(VanillaSoundID.nightmarePortal);
        }
    }
    public static function SpawnPortal(boss:Entity, position:Vector3, enemyID:NamespaceID):Null<Entity>
    {
        var portal = boss.SpawnWithParams(VanillaEffectID.nightmarePortal, position);
        if (portal != null)
        {
            NightmarePortal.SetEnemyID(portal, enemyID);
        }
        return portal;
    }
    private function GetRandomPortalEnemyID(rng:RandomGenerator):NamespaceID
    {
        var index = rng.WeightedRandom(portalPoolWeights);
        return portalPool[index];
    }
    // #endregion

    // #region Mind Swap
    private function MindSwapUpdate(entity:Entity):Void
    {
        var mindSwapTimer = GetMindSwapTimer(entity);
        if (!mindSwapTimer.RunToExpiredAndNotNull())
            return;
        mindSwapTimer.Reset();
        var level = entity.Level;
        if (!LogicLevelExt.IsConveyorMode(level))
            return;

        var rng = GetMindSwapRNG(entity);
        var pool = VanillaDifficultyLevelProps.SlendermanMindSwapZombies(level) ? hardMindSwapPool : mindSwapPool;
        for (i in 0...level.GetConveyorSeedPackCount())
        {
            var blueprint = level.GetConveyorSeedPackAt(i);
            if (blueprint == null) continue;

            // PORT-NOTE: C# 的 LogicSeedProps 对 SeedDefinition / SeedPack 有同名重载；Haxe 无重载，
            // SeedPack 版本改名为 GetSeedTypeOfPack / GetSeedEntityIDOfPack（GetConveyorSeedPackAt 返回 SeedPack）。
            if (blueprint.GetSeedTypeOfPack() != SeedTypes.ENTITY) continue;

            var entityID = blueprint.GetSeedEntityIDOfPack();
            if (entityID == null) continue;

            var entityDef = level.Content.GetEntityDefinition(entityID);
            if (entityDef == null || entityDef.Type != EntityTypes.PLANT) continue;

            var targetID = rng == null ? VanillaContraptionID.lilyPad : EnumerableExt.Random(pool, rng);
            var buff = blueprint.AddBuff(SlenderManMindSwapBuff);
            buff.SetProperty(SlenderManMindSwapBuff.PROP_TARGET_ID, targetID);
        }
    }
    // #endregion

    // #region Fate Choose
    private function ChooseFate(entity:Entity):Void
    {
        var rng = GetFateOptionRNG(entity);
        ChooseFateWithCallback(entity, rng, function(option) {
            DoFate(entity, option);
            // 用Delayed，防止当前手持僵尸时点击按钮后直接把僵尸放在地上
            LogicLevelExt.ResumeGameDelayed(entity.Level, 100);
        });
    }
    // C#: static ChooseFate(Entity entity, RandomGenerator? rng, Action<int> onSelect)
    // PORT-NOTE: Haxe has no method overloading; renamed overload to ChooseFateWithCallback.
    public static function ChooseFateWithCallback(entity:Entity, rng:Null<RandomGenerator>, onSelect:Int->Void):Void
    {
        var level = entity.Level;
        LogicLevelExt.PauseGame(level, 100);
        var title = Global.Localization.GetText(CHOOSE_FATE_TITLE);
        var desc = Global.Localization.GetText(CHOOSE_FATE_DESCRIPTION);

        var count = VanillaDifficultyLevelProps.GetSlendermanFateChoiceCount(level);
        var selected = rng != null ? EnumerableExt.RandomTake(fateOptions, count, rng) : EnumerableExt.Take(fateOptions, count);
        var options = Lambda.array(Lambda.map(selected, function(i) return GetFateOptionText(i)));
        LogicLevelExt.ShowDialog(level, title, desc, options, function(i) {
            var option = selected[i];
            if (onSelect != null)
                onSelect(option);
        });
    }
    private function DoFate(boss:Entity, option:Int):Void
    {
        switch (option)
        {
            case FATE_PANDORAS_BOX:
                PandorasBox(boss);
            case FATE_BIOHAZARD:
                Biohazard(boss);
            case FATE_DECREPIFY:
                Decrepify(boss);
            case FATE_INSANITY:
                Insanity(boss);
            case FATE_COME_TRUE:
                ComeTrue(boss);
            case FATE_THE_LURKER:
                TheLurker(boss);
            case FATE_BLACK_SUN:
                BlackSun(boss);
        }
    }

    private function PandorasBox(boss:Entity):Void
    {
        boss.PlaySound(VanillaSoundID.odd);

        var level = boss.Level;
        var eventRng = GetEventRNG(boss);
        if (eventRng == null)
            return;
        var rng = new RandomGenerator(eventRng.Next());
        var contraptions = level.FindEntities(function(e) return e.Type == EntityTypes.PLANT && e.IsHostile(boss));
        for (contraption in contraptions)
        {
            contraption.ClearTakenGrids();
        }
        var grids = level.GetAllGrids();
        for (contraption in contraptions)
        {
            var placementID = contraption.Definition.GetPlacementID();
            if (placementID == null)
                continue;
            var placementDef = level.Content.GetPlacementDefinition(placementID);
            if (placementDef == null)
                continue;
            var targetGrids = Lambda.array(Lambda.filter(grids, function(g) return g.CanSpawnEntity(contraption.GetDefinitionID())));
            if (targetGrids.length <= 0)
                continue;
            var grid = EnumerableExt.Random(targetGrids, rng);
            contraption.Position = grid.GetEntityPosition();
            contraption.UpdateTakenGrids();
        }
    }
    public static function Biohazard(boss:Entity):Void
    {
        boss.PlaySound(VanillaSoundID.biohazard);
        boss.PlaySound(VanillaSoundID.nightmarePortal);
        var level = boss.Level;
        for (column in 0...2)
        {
            var x = level.GetEntityColumnX(level.GetMaxColumnCount() - 1 - column);
            for (lane in 0...level.GetMaxLaneCount())
            {
                var z = level.GetEntityLaneZ(lane);
                var y = level.GetGroundY(x, z);
                var pos = new Vector3(x, y, z);
                SpawnPortal(boss, pos, VanillaEnemyID.ironHelmettedZombie);
            }
        }
    }

    private function Decrepify(boss:Entity):Void
    {
        boss.PlaySound(VanillaSoundID.decrepify);
        boss.Level.AddBuff(NightmareDecrepifyBuff);
    }

    private function Insanity(boss:Entity):Void
    {
        boss.PlaySound(VanillaSoundID.confuse);

        var level = boss.Level;
        var rng = GetEventRNG(boss);
        var possible = level.FindEntities(function(e) return e.Type == EntityTypes.PLANT && e.IsHostile(boss) && !VanillaEntityProps.IsLoyal(e));
        var targets = rng != null ? EnumerableExt.RandomTake(possible, 5, rng) : EnumerableExt.Take(possible, 5);
        for (target in targets)
        {
            VanillaEntityExt.CharmPermanent(target, boss.GetFaction(), new EntitySourceReference(boss));
        }
    }


    private function ComeTrue(boss:Entity):Void
    {
        boss.PlaySound(VanillaSoundID.nyaightmareScream);

        var level = boss.Level;
        var targets = level.FindEntities(function(e) return e.Type == EntityTypes.ENEMY && e.IsFriendly(boss) && !e.IsEntityOf(VanillaEnemyID.ghast));
        for (enemy in targets)
        {
            var ghast = boss.SpawnWithParams(VanillaEnemyID.ghast, enemy.Position);
            if (ghast != null)
            {
                ghast.AddBuff(NightmareComeTrueBuff);
            }
            enemy.Remove();
        }
    }

    private function TheLurker(boss:Entity):Void
    {
        boss.PlaySound(VanillaSoundID.splashBig);
        boss.PlaySound(VanillaSoundID.lurker);

        var rng = GetEventRNG(boss);
        var level = boss.Level;
        level.ShakeScreen(50, 0, 30);
        var targets = level.FindEntities(function(e) return e.Type == EntityTypes.PLANT && VanillaEntityExt.IsOnWater(e));
        var count = Mathf.CeilToInt(targets.length * 0.5);
        var randomTargets = rng != null ? EnumerableExt.RandomTake(targets, count, rng) : EnumerableExt.Take(targets, count);
        for (target in randomTargets)
        {
            target.Die(boss);
        }
    }

    private function BlackSun(boss:Entity):Void
    {
        boss.PlaySound(VanillaSoundID.powerOff);
        boss.PlaySound(VanillaSoundID.reverseVampire);
        boss.PlaySound(VanillaSoundID.confuse);

        var level = boss.Level;
        var targets = level.FindEntities(function(e) return e.Type == EntityTypes.PLANT && VanillaEntityProps.CanDeactive(e));
        for (contraption in targets)
        {
            VanillaEntityExt.ShortCircuit(contraption, 300, new EntitySourceReference(boss));
        }
    }
    private static function GetFateOptionText(option:Int):String
    {
        var index = fateOptions.indexOf(option);
        var text = fateTexts[index];
        return Global.Localization.GetText(text);
    }
    // #endregion

    private function GetMaxFateTimes(level:LevelEngine):Int
    {
        return VanillaDifficultyLevelProps.GetSlendermanMaxFateTimes(level);
    }

    // #region 属性
    public static function GetSelectedFateTimes(boss:Entity):Int
    {
        return boss.GetBehaviourFieldNS(ID, PROP_SELECTED_FATE_TIMES);
    }
    public static function SetSelectedFateTimes(boss:Entity, value:Int):Void
    {
        boss.SetBehaviourFieldNS(ID, PROP_SELECTED_FATE_TIMES, value);
    }
    public static function GetReadyFateTimes(boss:Entity):Int
    {
        return boss.GetBehaviourFieldNS(ID, PROP_READY_FATE_TIMES);
    }
    public static function SetReadyFateTimes(boss:Entity, value:Int):Void
    {
        boss.SetBehaviourFieldNS(ID, PROP_READY_FATE_TIMES, value);
    }

    // #region 移动
    public static function GetMoveTimer(boss:Entity):Null<FrameTimer>
    {
        return boss.GetBehaviourFieldNS(ID, PROP_MOVE_TIMER);
    }
    public static function SetMoveTimer(boss:Entity, value:FrameTimer):Void
    {
        boss.SetBehaviourFieldNS(ID, PROP_MOVE_TIMER, value);
    }
    public static function GetMoveTimeout(boss:Entity):Int
    {
        return boss.GetBehaviourFieldNS(ID, PROP_MOVE_TIMEOUT);
    }
    public static function SetMoveTimeout(boss:Entity, value:Int):Void
    {
        boss.SetBehaviourFieldNS(ID, PROP_MOVE_TIMEOUT, value);
    }
    public static function GetMoveDisplacement(boss:Entity):Vector3
    {
        return boss.GetBehaviourFieldNS(ID, PROP_MOVE_DISPLACEMENT);
    }
    public static function SetMoveDisplacement(boss:Entity, value:Vector3):Void
    {
        boss.SetBehaviourFieldNS(ID, PROP_MOVE_DISPLACEMENT, value);
    }
    // #endregion

    // #region 传送门
    public static function GetPortalTimer(boss:Entity):Null<FrameTimer>
    {
        return boss.GetBehaviourFieldNS(ID, PROP_PORTAL_TIMER);
    }
    public static function SetPortalTimer(boss:Entity, value:FrameTimer):Void
    {
        boss.SetBehaviourFieldNS(ID, PROP_PORTAL_TIMER, value);
    }
    // #endregion

    // #region 精神交换
    public static function GetMindSwapTimer(boss:Entity):Null<FrameTimer>
    {
        return boss.GetBehaviourFieldNS(ID, PROP_MIND_SWAP_TIMER);
    }
    public static function SetMindSwapTimer(boss:Entity, value:FrameTimer):Void
    {
        boss.SetBehaviourFieldNS(ID, PROP_MIND_SWAP_TIMER, value);
    }
    // #endregion

    // #region RNG
    public static function GetMoveRNG(boss:Entity):Null<RandomGenerator>
    {
        return boss.GetBehaviourFieldNS(ID, PROP_MOVE_RNG);
    }
    public static function SetMoveRNG(boss:Entity, value:RandomGenerator):Void
    {
        boss.SetBehaviourFieldNS(ID, PROP_MOVE_RNG, value);
    }
    public static function GetPortalRNG(boss:Entity):Null<RandomGenerator>
    {
        return boss.GetBehaviourFieldNS(ID, PROP_PORTAL_RNG);
    }
    public static function SetPortalRNG(boss:Entity, value:RandomGenerator):Void
    {
        boss.SetBehaviourFieldNS(ID, PROP_PORTAL_RNG, value);
    }
    public static function GetMindSwapRNG(boss:Entity):Null<RandomGenerator>
    {
        return boss.GetBehaviourFieldNS(ID, PROP_MIND_SWAP_RNG);
    }
    public static function SetMindSwapRNG(boss:Entity, value:RandomGenerator):Void
    {
        boss.SetBehaviourFieldNS(ID, PROP_MIND_SWAP_RNG, value);
    }
    public static function GetFateOptionRNG(boss:Entity):Null<RandomGenerator>
    {
        return boss.GetBehaviourFieldNS(ID, PROP_FATE_OPTION_RNG);
    }
    public static function SetFateOptionRNG(boss:Entity, value:RandomGenerator):Void
    {
        boss.SetBehaviourFieldNS(ID, PROP_FATE_OPTION_RNG, value);
    }
    public static function GetEventRNG(boss:Entity):Null<RandomGenerator>
    {
        return boss.GetBehaviourFieldNS(ID, PROP_EVENT_RNG);
    }
    public static function SetEventRNG(boss:Entity, value:RandomGenerator):Void
    {
        boss.SetBehaviourFieldNS(ID, PROP_EVENT_RNG, value);
    }
    // #endregion

    // #endregion 属性

    // #region 常量
    public static var ID:NamespaceID = VanillaBossID.slenderman;

    @:translateMsg("梦魇对话框标题")
    public static inline var CHOOSE_FATE_TITLE:String = "选择你的命运";
    @:translateMsg("梦魇对话框文本")
    public static inline var CHOOSE_FATE_DESCRIPTION:String = "选吧。";
    @:translateMsg("梦魇选项")
    public static inline var FATE_TEXT_PANDORAS_BOX:String = "潘多拉的魔盒";
    @:translateMsg("梦魇选项")
    public static inline var FATE_TEXT_BIOHAZARD:String = "尸潮";
    @:translateMsg("梦魇选项")
    public static inline var FATE_TEXT_DECREPIFY:String = "衰老";
    @:translateMsg("梦魇选项")
    public static inline var FATE_TEXT_INSANITY:String = "疯狂";
    @:translateMsg("梦魇选项")
    public static inline var FATE_TEXT_COME_TRUE:String = "成真";
    @:translateMsg("梦魇选项")
    public static inline var FATE_TEXT_THE_LURKER:String = "深潜者";
    @:translateMsg("梦魇选项")
    public static inline var FATE_TEXT_BLACK_SUN:String = "黑太阳";

    public static inline var MAX_MOVE_TIMEOUT:Int = 30;

    public static var PROP_SELECTED_FATE_TIMES:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("SelectedFateTimes");
    public static var PROP_READY_FATE_TIMES:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("ReadyFateTimes");

    public static var PROP_MOVE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("MoveTimer");
    public static var PROP_MOVE_TIMEOUT:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("MoveTimeout");
    public static var PROP_MOVE_DISPLACEMENT:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("MoveDisplacement");

    public static var PROP_PORTAL_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("PortalTimer");

    public static var PROP_MIND_SWAP_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("MindSwapTimer");

    public static var PROP_MOVE_RNG:VanillaEntityPropertyMeta<RandomGenerator> = new VanillaEntityPropertyMeta<RandomGenerator>("MoveRNG");
    public static var PROP_PORTAL_RNG:VanillaEntityPropertyMeta<RandomGenerator> = new VanillaEntityPropertyMeta<RandomGenerator>("PortalRNG");
    public static var PROP_MIND_SWAP_RNG:VanillaEntityPropertyMeta<RandomGenerator> = new VanillaEntityPropertyMeta<RandomGenerator>("MindSwapRNG");
    public static var PROP_FATE_OPTION_RNG:VanillaEntityPropertyMeta<RandomGenerator> = new VanillaEntityPropertyMeta<RandomGenerator>("FateOptionRNG");
    public static var PROP_EVENT_RNG:VanillaEntityPropertyMeta<RandomGenerator> = new VanillaEntityPropertyMeta<RandomGenerator>("EventRNG");

    public static inline var FATE_PANDORAS_BOX:Int = 0;
    public static inline var FATE_BIOHAZARD:Int = 1;
    public static inline var FATE_DECREPIFY:Int = 2;
    public static inline var FATE_INSANITY:Int = 3;
    public static inline var FATE_COME_TRUE:Int = 4;
    public static inline var FATE_THE_LURKER:Int = 5;
    public static inline var FATE_BLACK_SUN:Int = 6;

    private static var portalPool:Array<NamespaceID> = [
        VanillaEnemyID.zombie,
        VanillaEnemyID.leatherCappedZombie,
        VanillaEnemyID.ironHelmettedZombie,
    ];

    private static var portalPoolWeights:Array<Int> = [
        10,
        5,
        2
    ];
    private static var mindSwapPool:Array<NamespaceID> = [
        LogicBlueprintID.FromEntity(VanillaContraptionID.lilyPad),
        LogicBlueprintID.FromEntity(VanillaContraptionID.drivenser),
        LogicBlueprintID.FromEntity(VanillaContraptionID.gravityPad),
        LogicBlueprintID.FromEntity(VanillaContraptionID.vortexHopper),
        LogicBlueprintID.FromEntity(VanillaContraptionID.pistenser),
        LogicBlueprintID.FromEntity(VanillaContraptionID.totenser),
        LogicBlueprintID.FromEntity(VanillaContraptionID.dreamCrystal),
        LogicBlueprintID.FromEntity(VanillaContraptionID.dreamSilk)
    ];
    private static var hardMindSwapPool:Array<NamespaceID> = [
        LogicBlueprintID.FromEntity(VanillaContraptionID.lilyPad),
        LogicBlueprintID.FromEntity(VanillaContraptionID.drivenser),
        LogicBlueprintID.FromEntity(VanillaContraptionID.gravityPad),
        LogicBlueprintID.FromEntity(VanillaContraptionID.vortexHopper),
        LogicBlueprintID.FromEntity(VanillaContraptionID.pistenser),
        LogicBlueprintID.FromEntity(VanillaContraptionID.totenser),
        LogicBlueprintID.FromEntity(VanillaContraptionID.dreamCrystal),
        LogicBlueprintID.FromEntity(VanillaContraptionID.dreamSilk),
        LogicBlueprintID.FromEntity(VanillaEnemyID.zombie)
    ];
    private static var fateOptions:Array<Int> = [
        FATE_PANDORAS_BOX,
        FATE_BIOHAZARD,
        FATE_DECREPIFY,
        FATE_INSANITY,
        FATE_COME_TRUE,
        FATE_THE_LURKER,
        FATE_BLACK_SUN,
    ];
    private static var fateTexts:Array<String> = [
        FATE_TEXT_PANDORAS_BOX,
        FATE_TEXT_BIOHAZARD,
        FATE_TEXT_DECREPIFY,
        FATE_TEXT_INSANITY,
        FATE_TEXT_COME_TRUE,
        FATE_TEXT_THE_LURKER,
        FATE_TEXT_BLACK_SUN,
    ];
    // #endregion 常量
}
