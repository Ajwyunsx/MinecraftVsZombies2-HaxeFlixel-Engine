// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/LockedChestPickup/LockedChestPickup.cs
package mvz2.gamecontent.pickups;

import mvz2.gamecontent.bosses.LockedChest;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.stages.VanillaStageID;
import mvz2.gamecontent.talk.VanillaTalkID;
import mvz2.vanilla.audios.VanillaMusicID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.bosses.VanillaBossExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.pickups.VanillaPickupExt;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.models.SortingLayers;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.auras.IBuffTarget;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.SpawnParams;
import pvzengine.level.LevelEngine;
import tools.FrameTimer;
import tools.Ticks;
import unity.Mathf;
import unity.Vector2;
import unity.Vector3;
using mvz2.vanilla.bosses.VanillaBossExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2.vanilla.pickups.VanillaPickupProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.entities.LogicEntityProps;
using mvz2logic.level.LevelPositions;

@:autoEntityBehaviourDefinition(VanillaPickupNames.lockedChestPickup)
class LockedChestPickup extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new ClearedAura());
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Timeout = entity.GetMaxTimeout();
    }
    public override function Update(pickup:Entity):Void
    {
        super.Update(pickup);
        var level = pickup.Level;
        var shadowAlpha:Float = 1;
        var gravity:Float = 1;
        if (pickup.IsCollected())
        {
            UpdateCollected(pickup);

            shadowAlpha = 0;
            gravity = 0;
        }
        else
        {
            var variant = pickup.GetVariant();
            if (variant > VARIANT_FIRST_TIME)
            {
                pickup.Timeout--;
                if (pickup.Timeout <= 0)
                {
                    LockedChest.ReallyDestroy(pickup);
                }
            }
            else if (pickup.GetEntityTime() > Ticks.FromSeconds(10))
            {
                pickup.Collect();
            }
        }
        pickup.SetShadowAlpha(shadowAlpha);
        pickup.SetGravity(gravity);
    }
    private static function GetMoveTargetPosition(entity:Entity):Vector3
    {
        var level = entity.Level;
        // PORT-NOTE: C# 将 Vector2 隐式转换为 Vector3，移植层显式补 z=0。
        var slotPosition2D = level.GetScreenCenterPosition() + Vector2.down * (entity.GetSize().y * entity.GetFinalDisplayScale().y * 0.5);
        var slotPosition = new Vector3(slotPosition2D.x, slotPosition2D.y, 0);
        return new Vector3(slotPosition.x, slotPosition.y - COLLECTED_Z - 15, COLLECTED_Z);
    }
    private function UpdateCollected(pickup:Entity):Void
    {
        switch (GetPickupState(pickup))
        {
            case STATE_JUST_COLLECTED:
                UpdateJustCollected(pickup);
            case STATE_SHAKE:
                UpdateShake(pickup);
            case STATE_LAUNCHED:
                UpdateLaunched(pickup);
            default:
        }
    }
    private function MoveToCenter(pickup:Entity):Void
    {
        var level = pickup.Level;
        var collectedTime = pickup.GetCollectedTime();
        var moveTime = level.GetSecondTicks(3);
        var timePercent:Float = collectedTime / moveTime;
        var targetPos = GetMoveTargetPosition(pickup);
        pickup.Velocity = (targetPos - pickup.Position) * 0.05;
        pickup.SetScale(Vector3.one * Mathf.Lerp(1, 3, timePercent));
        pickup.SetDisplayScale(Vector3.one * Mathf.Lerp(1, 3, timePercent));
        pickup.SetSortingLayer(SortingLayers.collectedPickups);
        pickup.SetSortingOrder(9999);
    }
    private function UpdateJustCollected(pickup:Entity):Void
    {
        MoveToCenter(pickup);

        var timer = GetOrInitStateTimer(pickup);
        if (timer.RunToExpired())
        {
            if (pickup.Level.IsFirstAdventure() && pickup.GetVariant() == VARIANT_FIRST_TIME && pickup.Level.StageID == VanillaStageID.palace11)
            {
                SetPickupState(pickup, STATE_TALK_STARTED);
                pickup.Level.SimpleStartTalk(VanillaTalkID.palace11Boss, 0, function()
                {
                    StartShake(pickup);
                }, null, function()
                {
                    StartShake(pickup);
                });
            }
            else
            {
                StartShake(pickup);
            }
        }
    }
    public static function StartShake(pickup:Entity):Void
    {
        SetPickupState(pickup, STATE_SHAKE);

        var level = pickup.Level;
        level.PlayMusic(VanillaMusicID.palaceBoss);
        level.SetMusicVolume(1);
        level.SetSubtrackWeight(0);

        var timer = GetOrInitStateTimer(pickup);
        timer.ResetSeconds(SECONDS_TO_END_SHAKE);
    }
    public static function UpdateShake(pickup:Entity):Void
    {
        var pos = GetMoveTargetPosition(pickup);
        pos.x += pickup.RNG.NextFloat() * 5 - 10;
        pos.y += pickup.RNG.NextFloat() * 5 - 10;
        pos.z += pickup.RNG.NextFloat() * 5 - 10;
        pickup.Position = pos;

        var timer = GetOrInitStateTimer(pickup);
        if (timer.RunToExpired())
        {
            pickup.PlaySound(VanillaSoundID.launch);
            pickup.Position = GetMoveTargetPosition(pickup);
            SetPickupState(pickup, STATE_LAUNCHED);
            timer.ResetSeconds(SECONDS_TO_SPAWN_CHEST);
        }
    }
    public static function UpdateLaunched(pickup:Entity):Void
    {
        pickup.Velocity = Vector3.up * 200;

        var timer = GetOrInitStateTimer(pickup);
        if (timer.RunToExpired())
        {
            var level = pickup.Level;
            var position = level.GetEntityGridPosition(7, 3);
            position.y += 1500;

            var param = new SpawnParams();
            var variant = pickup.GetVariant();
            var revival = variant > VARIANT_FIRST_TIME;
            if (revival)
            {
                param.SetProperty(LockedChest.PROP_HAVE_BEEN_PRICKED, true);
                param.SetProperty(LockedChest.PROP_NEXT_JOKE, LockedChest.JOKE_COUNT);
                param.SetProperty(LockedChest.PROP_PHASE, LockedChest.PHASE_2);
                param.SetProperty(LockedChest.PROP_REVIVED_TIMES, variant);
            }

            // C#: LockedChest.SmashAppear(...)?.Let(e => { ... })
            var chest = LockedChest.SmashAppear(level, position, pickup, param);
            if (chest != null)
            {
                chest.ApplyBuffForBossRevenge();
                if (revival)
                {
                    chest.Health = chest.GetMaxHealth() * LockedChest.REVIVAL_HEALTH_PERCENTAGE;
                }
            }
            pickup.Remove();
        }
    }
    public static function Produce(level:LevelEngine, position:Vector3, ?spawner:Null<Entity>, ?param:Null<SpawnParams>):Null<Entity>
    {
        return VanillaPickupExt.ProduceOnLevel(level, VanillaPickupID.lockedChestPickup, position, spawner, param);
    }
    public static function GetPickupState(entity:Entity):Int return entity.GetProperty(PROP_PICKUP_STATE);
    public static function SetPickupState(entity:Entity, value:Int):Void entity.SetProperty(PROP_PICKUP_STATE, value);
    public static function GetStateTimer(entity:Entity):Null<FrameTimer> return entity.GetProperty(PROP_STATE_TIMER);
    public static function SetStateTimer(entity:Entity, value:Null<FrameTimer>):Void entity.SetProperty(PROP_STATE_TIMER, value);
    public static function GetOrInitStateTimer(entity:Entity):FrameTimer
    {
        var timer = GetStateTimer(entity);
        if (timer == null)
        {
            timer = new FrameTimer();
            SetStateTimer(entity, timer);
        }
        return timer;
    }
    public static inline var SECONDS_TO_START_TALK:Float = 5;
    public static inline var SECONDS_TO_END_SHAKE:Float = 2;
    public static inline var SECONDS_TO_SPAWN_CHEST:Float = 1;

    public static inline var VARIANT_FIRST_TIME:Int = 0;

    public static inline var STATE_JUST_COLLECTED:Int = 0;
    public static inline var STATE_TALK_STARTED:Int = 1;
    public static inline var STATE_SHAKE:Int = 2;
    public static inline var STATE_LAUNCHED:Int = 3;

    private static inline var COLLECTED_Z:Float = 0;
    public static var PROP_PICKUP_STATE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("pickup_state");
    public static var PROP_STATE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("state_timer");
}

// PORT-NOTE: C# 的嵌套类 LockedChestPickup.ClearedAura → Haxe 模块级类（Haxe 不支持嵌套类）。
class ClearedAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Level.battleRespite, 1);
    }
    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var sourceEntity = auraEffect.Source.GetEntity();
        if (sourceEntity == null)
            return;
        if (!sourceEntity.IsCollected())
            return;
        results.push(auraEffect.Level);
    }
}
