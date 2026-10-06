// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/Seija.cs
// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/Seija_States.cs
// PORT-NOTE: the C# `partial class Seija` spans Seija.cs and Seija_States.cs;
// per PORTING.md partial classes are merged into a single Haxe module.
// PORT-NOTE: members accessed by the C# nested state classes are `public` here,
// because Haxe module types do not share class-level private visibility.
package mvz2.gamecontent.bosses;

import mvz2.gamecontent.buffs.bosses.SeijaFabricBuff;
import mvz2.gamecontent.buffs.bosses.SeijaGapBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.SeijaDetector;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.projectiles.SeijaBullet;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.bosses.VanillaBossStates;
import mvz2.vanilla.detection.Detection;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2.vanilla.statemachine.EntityStateMachine;
import mvz2.vanilla.statemachine.EntityStateMachineState;
import pvzengine.entities.EntityTypes;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LevelPositions;
import pvzengine.collisions.IEntityCollider;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DamageOutput;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import unity.Color;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.entities.EngineEntityExt;

@:autoEntityBehaviourDefinition(VanillaBossNames.seija)
class Seija extends BossBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public static function StartState(boss:Entity, state:Int):Void
    {
        stateMachine.StartState(boss, state);
    }
    // #region 回调
    override public function Init(boss:Entity):Void
    {
        super.Init(boss);
        stateMachine.Init(boss);
        stateMachine.StartState(boss, STATE_IDLE);
        var timer = new FrameTimer(90);
        timer.Frame = 0;
        SetFabricCooldownTimer(boss, timer);
        SetDanmakuTimer(boss, new FrameTimer(4));

        var spawnParam = boss.GetSpawnParams();
        spawnParam.EntityParent = boss;
        boss.Spawn(VanillaEnemyID.seijaCursedDoll, boss.Position, spawnParam);
    }
    override public function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);

        if (entity.IsDead)
            return;
        stateMachine.UpdateAI(entity);
        var timer = GetFabricCooldownTimer(entity);
        if (timer != null)
            timer.Run();
    }
    override public function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        stateMachine.UpdateLogic(entity);

        var takenDamage = GetRecentTakenDamage(entity);
        takenDamage = Mathf.Max(0, takenDamage - TAKEN_DAMAGE_FADE);
        SetRecentTakenDamage(entity, takenDamage);
    }
    override public function PostDeath(boss:Entity, damageInfo:DeathInfo):Void
    {
        super.PostDeath(boss, damageInfo);
        // PORT-NOTE: C# `boss.PlaySound(VanillaSoundID.touhouDeath, volume: 0.5f)`；
        // 参数槽为 (id, pitch, volume)，0.5 必须落在 volume（原移植写成了 pitch）。
        boss.PlaySound(VanillaSoundID.touhouDeath, 1, 0.5);
        boss.Spawn(VanillaEffectID.seijaFaintEffect, boss.GetCenter());
        stateMachine.StartState(boss, STATE_FAINT);
    }
    override public function PostTakeDamage(result:DamageOutput):Void
    {
        super.PostTakeDamage(result);
        if (result == null || result.BodyResult == null)
            return;
        var boss = result.Entity;
        var takenDamage = GetRecentTakenDamage(boss);
        takenDamage += result.BodyResult.SpendAmount;
        SetRecentTakenDamage(boss, takenDamage);
        if (takenDamage >= FABRIC_DAMAGE_THRESOLD && !boss.IsDead)
        {
            if (CanUseFabric(boss))
            {
                UseFabric(boss);
            }
        }
    }
    // #endregion 事件

    // #region 属性
    public static function GetFabricCount(boss:Entity):Int
    {
        return boss.GetBehaviourField(PROP_FABRIC_COUNT);
    }
    public static function SetFabricCount(boss:Entity, value:Int):Void
    {
        boss.SetBehaviourField(PROP_FABRIC_COUNT, value);
    }
    public static function GetFabricCooldownTimer(boss:Entity):Null<FrameTimer>
    {
        return boss.GetBehaviourField(PROP_FABRIC_COOLDOWN_TIMER);
    }
    public static function SetFabricCooldownTimer(boss:Entity, value:FrameTimer):Void
    {
        boss.SetBehaviourField(PROP_FABRIC_COOLDOWN_TIMER, value);
    }
    public static function GetRecentTakenDamage(boss:Entity):Float
    {
        return boss.GetBehaviourField(PROP_RECENT_TAKEN_DAMAGE);
    }
    public static function SetRecentTakenDamage(boss:Entity, value:Float):Void
    {
        boss.SetBehaviourField(PROP_RECENT_TAKEN_DAMAGE, value);
    }
    public static function AddRecentTakenDamage(boss:Entity, value:Float):Void
    {
        SetRecentTakenDamage(boss, GetRecentTakenDamage(boss) + value);
    }
    public static function GetBulletAngle(boss:Entity):Float
    {
        return boss.GetBehaviourField(PROP_BULLET_ANGLE);
    }
    public static function SetBulletAngle(boss:Entity, value:Float):Void
    {
        boss.SetBehaviourField(PROP_BULLET_ANGLE, value);
    }
    public static function GetDanmakuTimer(boss:Entity):Null<FrameTimer>
    {
        return boss.GetBehaviourField(PROP_DANMAKU_TIMER);
    }
    public static function SetDanmakuTimer(boss:Entity, value:FrameTimer):Void
    {
        boss.SetBehaviourField(PROP_DANMAKU_TIMER, value);
    }
    // #endregion 属性

    public static function GetChangeAdjacentLaneZSpeed(boss:Entity):Float
    {
        var dir = 0;
        var lane = boss.GetLane();
        var maxLane = boss.Level.GetMaxLaneCount();
        if (lane <= 0)
        {
            dir = 1;
        }
        else if (lane >= maxLane - 1)
        {
            dir = -1;
        }
        else
        {
            // PORT-NOTE: C# 的 RandomGenerator.Next(int max) 返回 int；Haxe 侧所有重载合并为
            // Next(?min:Dynamic, ?max:Dynamic):Dynamic，直接参与算术会被推断为 Float，故显式取整。
            dir = Std.int(boss.RNG.Next(2)) * 2 - 1;
        }
        var targetLane = Mathf.ClampInt(lane + dir, 0, maxLane - 1);
        return GetChangeLaneZSpeed(boss, targetLane);
    }
    private static function GetChangeLaneZSpeed(boss:Entity, targetLane:Int):Float
    {
        var targetZ = boss.Level.GetEntityLaneZ(targetLane);
        return GetChangeZSpeed(boss, targetZ);
    }
    private static function GetChangeZSpeed(boss:Entity, targetZ:Float):Float
    {
        var currentZ = boss.Position.z;
        return (targetZ - currentZ) / 16.6;
    }
    public static function CanUseFabric(boss:Entity):Bool
    {
        var count = GetFabricCount(boss);
        if (count >= MAX_FABRIC_COUNT)
            return false;
        var timer = GetFabricCooldownTimer(boss);
        if (timer == null || !timer.Expired)
            return false;
        return true;
    }
    public static function UseFabric(boss:Entity):Void
    {
        stateMachine.StartState(boss, STATE_FABRIC);
        SetFabricCount(boss, GetFabricCount(boss) + 1);
        var timer = GetFabricCooldownTimer(boss);
        if (timer != null)
            timer.Reset();
        SetRecentTakenDamage(boss, 0);
        boss.PlaySound(VanillaSoundID.nimbleFabric);
    }
    public static function ShouldCamera(boss:Entity):Bool
    {
        return cameraDetector.DetectEntityCount(DetectionParams.fromEntity(boss)) >= CAMERA_ENEMY_COUNT;
    }
    public static function ShouldGapBomb(boss:Entity):Bool
    {
        var column = LogicEntityExt.GetMirroredColumn(boss, 0, true);
        if (Detection.IsAheadOfColumn(boss, column))
            return false;
        return gapBombDetector.DetectEntityCount(DetectionParams.fromEntity(boss)) >= GAP_BOMB_ENEMY_COUNT;
    }
    public static function ShouldFrontFlip(boss:Entity):Bool
    {
        return Detection.IsBehindOfColumn(boss, Std.int(boss.Level.GetMaxColumnCount() / 2));
    }
    public static function ShouldBackflip(boss:Entity):Bool
    {
        return Detection.IsAheadOfOrAtColumn(boss, Std.int(boss.Level.GetMaxColumnCount() / 2));
    }
    public static function CanFrontflip(boss:Entity):Bool
    {
        var column = LogicEntityExt.GetMirroredColumn(boss, 1, false);
        return Detection.IsBehindOfColumn(boss, column);
    }
    public static function CanBackflip(boss:Entity):Bool
    {
        var column = LogicEntityExt.GetMirroredColumn(boss, 1, true);
        return Detection.IsAheadOfColumn(boss, column);
    }
    public static function FindHammerTarget(boss:Entity):Null<Entity>
    {
        return hammerCheckDetector.DetectEntityWithTheLeast(DetectionParams.fromEntity(boss), function(e) return Mathf.Abs(e.Position.x - boss.Position.x));
    }

    // #region 常量
    public static var PROP_FABRIC_COUNT:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("FabricCount");
    public static var PROP_FABRIC_COOLDOWN_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("FabricCooldownTimer");
    public static var PROP_DANMAKU_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("DanmakuTimer");
    public static var PROP_RECENT_TAKEN_DAMAGE:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("RecentTakenDamage");
    public static var PROP_BULLET_ANGLE:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("BulletAngle");

    public static inline var MAX_FABRIC_COUNT:Int = 3;
    public static inline var FABRIC_DAMAGE_THRESOLD:Float = 300;
    public static inline var TAKEN_DAMAGE_FADE:Float = FABRIC_DAMAGE_THRESOLD / 75;

    public static inline var CAMERA_ENEMY_COUNT:Int = 3;
    public static inline var GAP_BOMB_ENEMY_COUNT:Int = 5;
    public static inline var BACKFLIP_ENEMY_COUNT:Int = 3;
    public static inline var ADJUST_Z_THRESOLD:Float = 5;

    public static inline var STATE_IDLE:Int = VanillaBossStates.IDLE;
    public static inline var STATE_APPEAR:Int = VanillaBossStates.APPEAR;
    public static inline var STATE_FAINT:Int = VanillaBossStates.DEATH;
    public static inline var STATE_DANMAKU:Int = VanillaBossStates.SEIJA_DANMAKU;
    public static inline var STATE_HAMMER:Int = VanillaBossStates.SEIJA_HAMMER;
    public static inline var STATE_BACKFLIP:Int = VanillaBossStates.SEIJA_BACKFLIP;
    public static inline var STATE_FRONTFLIP:Int = VanillaBossStates.SEIJA_FRONTFLIP;
    public static inline var STATE_GAP_BOMB:Int = VanillaBossStates.SEIJA_GAP_BOMB;
    public static inline var STATE_CAMERA:Int = VanillaBossStates.SEIJA_CAMERA;
    public static inline var STATE_FABRIC:Int = VanillaBossStates.SEIJA_FABRIC;
    // #endregion 常量

    public static inline var ANIMATION_STATE_IDLE:Int = 0;
    public static inline var ANIMATION_STATE_APPEAR:Int = 1;
    public static inline var ANIMATION_STATE_DANMAKU:Int = 2;
    public static inline var ANIMATION_STATE_FAINT:Int = 3;
    public static inline var ANIMATION_STATE_HAMMER:Int = 4;
    public static inline var ANIMATION_STATE_GAP_BOMB:Int = 5;
    public static inline var ANIMATION_STATE_CAMERA:Int = 6;
    public static inline var ANIMATION_STATE_BACKFLIP:Int = 7;
    public static inline var ANIMATION_STATE_FRONTFLIP:Int = 8;
    public static inline var ANIMATION_STATE_FABRIC:Int = 9;

    private static var hammerCheckDetector:Detector = new SeijaDetector(SeijaDetector.MODE_DETECT);
    public static var hammerSmashDetector:Detector = new SeijaDetector(SeijaDetector.MODE_SMASH);
    public static var hammerPlaceBombDetector:Detector = new SeijaDetector(SeijaDetector.MODE_PLACE_BOMB);
    private static var gapBombDetector:Detector = new SeijaDetector(SeijaDetector.MODE_GAP_BOMB);
    private static var cameraDetector:Detector = new SeijaDetector(SeijaDetector.MODE_CAMERA);
    public static var stateMachine:SeijaStateMachine = new SeijaStateMachine();
}

// #region 状态机
private class SeijaStateMachine extends EntityStateMachine
{
    public function new()
    {
        super();
        AddState(new AppearState());
        AddState(new SeijaIdleState());
        AddState(new BackflipState());
        AddState(new FrontflipState());
        AddState(new DanmakuState());
        AddState(new HammerState());
        AddState(new GapBombState());
        AddState(new SeijaCameraState());
        AddState(new FabricState());
        AddState(new SeijaFaintState());
    }
}
// #endregion

// #region 状态
private class AppearState extends EntityStateMachineState
{
    public function new()
    {
        super(Seija.STATE_APPEAR, Seija.ANIMATION_STATE_APPEAR);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer != null)
            substateTimer.ResetTime(30);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (!substateTimer.RunToExpiredAndNotNull(stateMachine.GetSpeed(entity)))
            return;
        stateMachine.StartState(entity, Seija.STATE_IDLE);
    }
}
private class SeijaIdleState extends EntityStateMachineState
{
    public function new()
    {
        super(Seija.STATE_IDLE, Seija.ANIMATION_STATE_IDLE);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var stateTimer = stateMachine.GetStateTimer(entity);
        if (stateTimer != null)
            stateTimer.ResetTime(90);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        if (entity.IsOnGround)
        {
            var pos = entity.Position;
            var lane = Mathf.ClampInt(entity.GetLane(), 0, entity.Level.GetMaxLaneCount() - 1);
            var targetZ = entity.Level.GetEntityLaneZ(lane);
            if (Mathf.Abs(targetZ - pos.z) > Seija.ADJUST_Z_THRESOLD)
            {
                pos.z = pos.z * 0.5 + targetZ * 0.5;
                entity.Position = pos;
            }
        }

        var stateTimer = stateMachine.GetStateTimer(entity);
        if (!stateTimer.RunToExpiredAndNotNull(stateMachine.GetSpeed(entity)))
            return;
        var nextState = GetNextState(stateMachine, entity);
        stateMachine.StartState(entity, nextState);
        stateMachine.SetPreviousState(entity, nextState);
    }
    private function GetNextState(stateMachine:EntityStateMachine, entity:Entity):Int
    {
        var lastState = stateMachine.GetPreviousState(entity);
        if (lastState == Seija.STATE_IDLE || lastState == Seija.STATE_BACKFLIP)
        {
            lastState = Seija.STATE_DANMAKU;
            return lastState;
        }

        var attackAttempted = false;
        if (lastState == Seija.STATE_DANMAKU)
        {
            lastState = Seija.STATE_CAMERA;
            attackAttempted = true;
            if (Seija.ShouldCamera(entity))
            {
                return lastState;
            }
        }
        if (lastState == Seija.STATE_CAMERA)
        {
            lastState = Seija.STATE_HAMMER;
            attackAttempted = true;
            entity.Target = Seija.FindHammerTarget(entity);
            if (EngineEntityExt.ExistsAndAlive(entity.Target))
            {
                return lastState;
            }
        }
        if (lastState == Seija.STATE_HAMMER)
        {
            lastState = Seija.STATE_GAP_BOMB;
            if (Seija.ShouldGapBomb(entity))
            {
                return lastState;
            }
        }
        if (lastState == Seija.STATE_GAP_BOMB)
        {
            lastState = Seija.STATE_FRONTFLIP;
            if (attackAttempted && Seija.ShouldFrontFlip(entity) && Seija.CanFrontflip(entity))
            {
                return lastState;
            }
        }
        if (lastState == Seija.STATE_FRONTFLIP)
        {
            lastState = Seija.STATE_BACKFLIP;
            if (attackAttempted && Seija.ShouldBackflip(entity) && Seija.CanBackflip(entity))
            {
                return lastState;
            }
        }

        return Seija.STATE_DANMAKU;
    }
}
private class DanmakuState extends EntityStateMachineState
{
    public function new()
    {
        super(Seija.STATE_DANMAKU, Seija.ANIMATION_STATE_DANMAKU);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer != null)
            substateTimer.ResetTime(30);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        RunDanmakuTimer(stateMachine, entity);
        RunTimer(stateMachine, entity);
    }
    private function RunDanmakuTimer(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        var danmakuTimer = Seija.GetDanmakuTimer(entity);
        if (danmakuTimer == null)
            return;
        danmakuTimer.Run(stateMachine.GetSpeed(entity));
        if (danmakuTimer.Expired)
        {
            danmakuTimer.Reset();
            var substate = stateMachine.GetSubState(entity);
            var bulletAngle = Seija.GetBulletAngle(entity);
            var color = Color.red;
            switch (substate)
            {
                case SUBSTATE_ROTATE_1, SUBSTATE_ROTATE_3:
                    bulletAngle = Mathf.Repeat(bulletAngle + 5, 360);
                case SUBSTATE_ROTATE_2:
                    color = Color.blue;
                    bulletAngle = Mathf.Repeat(bulletAngle - 5, 360);
            }
            for (i in 0...6)
            {
                var angle = bulletAngle + i * 60;
                var param = entity.GetShootParams();
                param.projectileID = VanillaProjectileID.seijaBullet;
                param.position = entity.GetCenter();
                param.damage = VanillaEntityProps.GetDamage(entity) * 0.5;
                param.velocity = new Vector3(Mathf.Cos(angle * Mathf.Deg2Rad), 0, Mathf.Sin(angle * Mathf.Deg2Rad)) * SeijaBullet.LIGHT_SPEED;
                var bullet = entity.ShootProjectile(param);
                if (bullet != null)
                    LogicEntityProps.SetHSVToColor(bullet, color);
            }
            Seija.SetBulletAngle(entity, bulletAngle);
            // PORT-NOTE: C# `entity.PlaySound(VanillaSoundID.danmaku, volume: 0.5f)`；参数槽为 (id, pitch, volume)。
            entity.PlaySound(VanillaSoundID.danmaku, 1, 0.5);
        }
    }
    private function RunTimer(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        var substate = stateMachine.GetSubState(entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer == null)
            return;
        substateTimer.Run(stateMachine.GetSpeed(entity));

        switch (substate)
        {
            case SUBSTATE_ROTATE_1:
                if (substateTimer.Expired)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_ROTATE_2);
                    substateTimer.ResetTime(30);
                }
            case SUBSTATE_ROTATE_2:
                if (substateTimer.Expired)
                {
                    stateMachine.StartState(entity, Seija.STATE_IDLE);
                }
        }
    }
    public static inline var SUBSTATE_ROTATE_1:Int = 0;
    public static inline var SUBSTATE_ROTATE_2:Int = 1;
    public static inline var SUBSTATE_ROTATE_3:Int = 2;
}
private class HammerState extends EntityStateMachineState
{
    public function new()
    {
        super(Seija.STATE_HAMMER, Seija.ANIMATION_STATE_HAMMER);
    }

    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer != null)
            substateTimer.ResetTime(17);

        if (EngineEntityExt.ExistsAndAlive(entity.Target))
        {
            entity.Velocity = (entity.Target.Position - entity.Position) / 6.6667;
        }
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer == null)
            return;
        substateTimer.Run(stateMachine.GetSpeed(entity));

        switch (substate)
        {
            case SUBSTATE_RAISE:
                if (substateTimer.Expired)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_HAMMERED);
                    substateTimer.ResetTime(8);
                    smashDetectBuffer = [];
                    Seija.hammerSmashDetector.DetectMultiple(DetectionParams.fromEntity(entity), smashDetectBuffer);
                    if (smashDetectBuffer.length > 0)
                    {
                        entity.Level.ShakeScreen(10, 0, 15);
                        entity.PlaySound(VanillaSoundID.fling);
                    }

                    for (collider in smashDetectBuffer)
                    {
                        var target = collider.Entity;
                        var damageResult = collider.TakeDamage(VanillaEntityProps.GetTakenCrushDamage(target), new DamageEffectList([VanillaDamageEffects.IMPACT, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN]), entity);
                        if (damageResult != null && damageResult.BodyResult != null && damageResult.BodyResult.Fatal && damageResult.BodyResult.Entity.Type == EntityTypes.PLANT)
                        {
                            damageResult.Entity.PlaySound(VanillaSoundID.smash);
                        }
                    }
                }
            case SUBSTATE_HAMMERED:
                if (substateTimer.Expired)
                {
                    var count = Seija.hammerPlaceBombDetector.DetectEntityCount(DetectionParams.fromEntity(entity));
                    if (count >= Seija.BACKFLIP_ENEMY_COUNT && Seija.CanBackflip(entity))
                    {
                        stateMachine.StartState(entity, Seija.STATE_BACKFLIP);
                        var param = entity.GetSpawnParams();
                        param.SetProperty(VanillaEntityProps.DAMAGE, VanillaEntityProps.GetDamage(entity));
                        var bomb = entity.Spawn(VanillaProjectileID.seijaMagicBomb, entity.GetCenter(), param);
                        if (bomb != null)
                        {
                            bomb.Velocity = new Vector3(0, 5, 0);
                        }
                    }
                    else
                    {
                        stateMachine.StartState(entity, Seija.STATE_IDLE);
                    }
                }
        }
    }

    private var smashDetectBuffer:Array<IEntityCollider> = [];
    public static inline var SUBSTATE_RAISE:Int = 0;
    public static inline var SUBSTATE_HAMMERED:Int = 1;
}
private class GapBombState extends EntityStateMachineState
{
    public function new()
    {
        super(Seija.STATE_GAP_BOMB, Seija.ANIMATION_STATE_GAP_BOMB);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer != null)
            substateTimer.ResetTime(40);

        if (!entity.HasBuff(SeijaGapBuff))
        {
            entity.AddBuff(SeijaGapBuff);
        }
        entity.PlaySound(VanillaSoundID.gapWarp);
    }
    override public function OnExit(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnExit(machine, entity);
        entity.RemoveBuffs(SeijaGapBuff);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer == null)
            return;
        substateTimer.Run(stateMachine.GetSpeed(entity));
        var substate = stateMachine.GetSubState(entity);

        switch (substate)
        {
            case SUBSTATE_PREPARE:
                if (substateTimer.Expired)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_WRAPPED);
                    substateTimer.ResetTime(12);
                    var level = entity.Level;
                    var pos = entity.Position;
                    pos.x = LogicEntityExt.GetMirroredX(entity, LevelPositions.LEFT_BORDER + 40, false);
                    pos.y = entity.Level.GetGroundY(pos.x, pos.z);
                    entity.Position = pos;
                    entity.PlaySound(VanillaSoundID.gapWarp);
                }

            case SUBSTATE_WRAPPED:
                if (substateTimer.Expired)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_BOMB_THROWN);
                    substateTimer.ResetTime(30);

                    var pos = entity.Position;
                    pos.y += 40;
                    var param = entity.GetSpawnParams();
                    param.SetProperty(VanillaEntityProps.DAMAGE, VanillaEntityProps.GetDamage(entity));
                    var bomb = entity.Spawn(VanillaProjectileID.seijaMagicBomb, pos, param);
                    if (bomb != null)
                    {
                        bomb.Velocity = new Vector3(VanillaEntityExt.GetFacingX(entity) * -5, 10, 0);
                    }
                    entity.PlaySound(VanillaSoundID.fling);
                }

            case SUBSTATE_BOMB_THROWN:
                if (substateTimer.Expired)
                {
                    var level = entity.Level;
                    stateMachine.StartSubState(entity, SUBSTATE_RETURN);
                    substateTimer.ResetTime(23);
                    var pos = entity.Position;
                    pos.x = level.GetEntityColumnX(LogicEntityExt.GetMirroredColumn(entity, 0, true));
                    var lane = entity.RNG.Next(level.GetMaxLaneCount());
                    pos.z = level.GetEntityLaneZ(lane);
                    pos.y = level.GetGroundY(pos.x, pos.z);
                    entity.Position = pos;
                    entity.PlaySound(VanillaSoundID.gapWarp);
                }

            case SUBSTATE_RETURN:
                if (entity.IsOnGround)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_LANDED);
                    substateTimer.ResetTime(17);
                }

            case SUBSTATE_LANDED:
                if (substateTimer.Expired)
                {
                    stateMachine.StartState(entity, Seija.STATE_IDLE);
                }
        }
    }
    public static inline var SUBSTATE_PREPARE:Int = 0;
    public static inline var SUBSTATE_WRAPPED:Int = 1;
    public static inline var SUBSTATE_BOMB_THROWN:Int = 2;
    public static inline var SUBSTATE_RETURN:Int = 3;
    public static inline var SUBSTATE_LANDED:Int = 4;
}
private class SeijaCameraState extends EntityStateMachineState
{
    public function new()
    {
        super(Seija.STATE_CAMERA, Seija.ANIMATION_STATE_CAMERA);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer != null)
            substateTimer.ResetTime(12);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer == null)
            return;
        substateTimer.Run(stateMachine.GetSpeed(entity));
        var substate = stateMachine.GetSubState(entity);
        switch (substate)
        {
            case SUBSTATE_PREPARE:
                if (substateTimer.Expired)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_JUMP);
                    var pos = entity.Position;
                    pos.x += VanillaEntityExt.GetFacingX(entity) * 80;
                    pos.y = entity.Level.GetGroundY(pos);
                    var frame = entity.SpawnWithParams(VanillaEffectID.seijaCameraFrame, pos);
                    if (frame != null)
                    {
                        frame.Velocity = new Vector3(VanillaEntityExt.GetFacingX(entity) * 30, 0, 0);
                    }
                    entity.Velocity = new Vector3(VanillaEntityExt.GetFacingX(entity) * 10, 10, Seija.GetChangeAdjacentLaneZSpeed(entity));
                }

            case SUBSTATE_JUMP:
                if (entity.IsOnGround)
                {
                    if (Seija.CanBackflip(entity))
                    {
                        stateMachine.StartState(entity, Seija.STATE_BACKFLIP);
                    }
                    else
                    {
                        stateMachine.StartSubState(entity, SUBSTATE_LANDED);
                        substateTimer.ResetTime(17);
                    }
                }

            case SUBSTATE_LANDED:
                if (substateTimer.Expired)
                {
                    stateMachine.StartState(entity, Seija.STATE_IDLE);
                }
        }
    }
    public static inline var SUBSTATE_PREPARE:Int = 0;
    public static inline var SUBSTATE_JUMP:Int = 1;
    public static inline var SUBSTATE_LANDED:Int = 2;
}
private class BackflipState extends EntityStateMachineState
{
    public function new()
    {
        super(Seija.STATE_BACKFLIP, Seija.ANIMATION_STATE_BACKFLIP);
    }
    override public function OnEnter(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(machine, entity);
        entity.Velocity = new Vector3(-10 * VanillaEntityExt.GetFacingX(entity), 10, Seija.GetChangeAdjacentLaneZSpeed(entity));
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer == null)
            return;
        substateTimer.Run(stateMachine.GetSpeed(entity));
        var substate = stateMachine.GetSubState(entity);
        switch (substate)
        {
            case SUBSTATE_JUMP:
                if (entity.IsOnGround)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_LANDED);
                    substateTimer.ResetTime(17);
                }

            case SUBSTATE_LANDED:
                if (substateTimer.Expired)
                {
                    stateMachine.StartState(entity, Seija.STATE_IDLE);
                }
        }
    }
    public static inline var SUBSTATE_JUMP:Int = 0;
    public static inline var SUBSTATE_LANDED:Int = 1;
}
private class FrontflipState extends EntityStateMachineState
{
    public function new()
    {
        super(Seija.STATE_FRONTFLIP, Seija.ANIMATION_STATE_FRONTFLIP);
    }
    override public function OnEnter(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(machine, entity);
        entity.Velocity = new Vector3(10 * VanillaEntityExt.GetFacingX(entity), 10, Seija.GetChangeAdjacentLaneZSpeed(entity));
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer == null)
            return;
        substateTimer.Run(stateMachine.GetSpeed(entity));
        var substate = stateMachine.GetSubState(entity);
        switch (substate)
        {
            case SUBSTATE_JUMP:
                if (entity.IsOnGround)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_LANDED);
                    substateTimer.ResetTime(17);
                }

            case SUBSTATE_LANDED:
                if (substateTimer.Expired)
                {
                    stateMachine.StartState(entity, Seija.STATE_IDLE);
                }
        }
    }
    public static inline var SUBSTATE_JUMP:Int = 0;
    public static inline var SUBSTATE_LANDED:Int = 1;
}
private class FabricState extends EntityStateMachineState
{
    public function new()
    {
        super(Seija.STATE_FABRIC, Seija.ANIMATION_STATE_FABRIC);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer != null)
            substateTimer.ResetTime(30);
        if (!entity.HasBuff(SeijaFabricBuff))
        {
            entity.AddBuff(SeijaFabricBuff);
        }
        entity.Velocity = Vector3.zero;
    }
    override public function OnExit(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnExit(machine, entity);
        entity.RemoveBuffs(SeijaFabricBuff);
        entity.Velocity = Vector3.zero;
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer == null)
            return;
        substateTimer.Run(stateMachine.GetSpeed(entity));
        var substate = stateMachine.GetSubState(entity);
        switch (substate)
        {
            case SUBSTATE_FABRICED:
                if (substateTimer.Expired)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_OFF);
                    substateTimer.ResetTime(10);
                }

            case SUBSTATE_OFF:
                if (substateTimer.Expired)
                {
                    if (Seija.CanBackflip(entity))
                    {
                        stateMachine.StartState(entity, Seija.STATE_BACKFLIP);
                    }
                    else
                    {
                        stateMachine.StartState(entity, Seija.STATE_IDLE);
                    }
                }
        }
    }
    public static inline var SUBSTATE_FABRICED:Int = 0;
    public static inline var SUBSTATE_OFF:Int = 1;
}
private class SeijaFaintState extends EntityStateMachineState
{
    public function new()
    {
        super(Seija.STATE_FAINT, Seija.ANIMATION_STATE_FAINT);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
    }
    override public function OnUpdateLogic(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(stateMachine, entity);
    }
}
// #endregion
