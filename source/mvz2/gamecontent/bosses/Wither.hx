// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/Wither.cs
// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/Wither_States.cs
// PORT-NOTE: the C# `partial class Wither` spans Wither.cs and Wither_States.cs;
// per PORTING.md partial classes are merged into a single Haxe module.
// PORT-NOTE: members accessed by the C# nested state classes are `public` here,
// because Haxe module types do not share class-level private visibility.
package mvz2.gamecontent.bosses;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.WitherDetector;
import mvz2.gamecontent.effects.Explosion;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.VanillaMod;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.bosses.VanillaBossExt;
import mvz2.vanilla.bosses.VanillaBossStates;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.detection.Detection;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2.vanilla.statemachine.EntityStateMachine;
import mvz2.vanilla.statemachine.EntityStateMachineState;
import pvzengine.entities.EntityTypes;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DamageOutput;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityID;
import pvzengine.entities.ILevelSourceReference;
import tools.EnumerableExt;
import tools.FrameTimer;
import unity.Mathf;
import unity.Vector2;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.EngineEntityProps;
import mvz2.vanilla.armors.VanillaArmorExt;
import mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
import pvzengine.entities.EngineEntityExt;

@:autoEntityBehaviourDefinition(VanillaBossNames.wither)
class Wither extends BossBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.PRE_PROJECTILE_HIT, PreProjectileHitCallback);
    }

    // #region 回调
    override public function Init(boss:Entity):Void
    {
        super.Init(boss);
        stateMachine.Init(boss);
        stateMachine.StartState(boss, STATE_IDLE);

        boss.CollisionMaskHostile |=
            EntityCollisionHelper.MASK_PLANT |
            EntityCollisionHelper.MASK_OBSTACLE;
    }
    override public function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);

        if (entity.IsDead)
            return;
        stateMachine.UpdateAI(entity);

        if (entity.IsTimeInterval(CRY_INTERVAL))
        {
            entity.PlaySound(VanillaSoundID.witherCry);
        }
    }
    override public function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        stateMachine.UpdateLogic(entity);
        entity.SetAnimationBool("Armored", HasArmor(entity));
        entity.SetAnimationFloat("HeadOpen", GetHeadOpen(entity));

        RotateHeadsUpdate(entity);

        if (!entity.IsDead)
        {
            var regen = VanillaDifficultyLevelProps.GetWitherRegeneration(entity.Level);
            entity.Heal(regen, entity);
        }
    }
    override public function PostDeath(boss:Entity, damageInfo:DeathInfo):Void
    {
        super.PostDeath(boss, damageInfo);
        boss.PlaySound(VanillaSoundID.witherDeath);
        stateMachine.StartState(boss, STATE_DEATH);
    }
    override public function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        var other = collision.Other;
        var self = collision.Entity;
        if (!other.IsHostile(self))
            return;
        if (other.Type != EntityTypes.PLANT && other.Type != EntityTypes.OBSTACLE)
            return;
        var otherCollider = collision.OtherCollider;
        var crushDamage = VanillaMod.INSTA_DAMAGE_AMOUNT;
        var substate = stateMachine.GetSubState(self);
        if (EngineEntityProps.IsInvincible(other))
        {
            if (self.State == STATE_CHARGE && substate == ChargeState.SUBSTATE_DASH)
            {
                Stun(self);
            }
        }
        else
        {
            var result = otherCollider.TakeDamage(crushDamage, new DamageEffectList([VanillaDamageEffects.GRIND, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN]), self);
            if (result != null && result.HasAnyFatal())
            {
                other.PlaySound(VanillaSoundID.smash);
                if (self.State == STATE_EAT && (substate == EatState.SUBSTATE_DASH || substate == EatState.SUBSTATE_EATEN))
                {
                    if (other.IsEntityOf(VanillaContraptionID.goldenApple))
                    {
                        Stun(self);
                        self.TakeDamage(GOLDEN_APPLE_DAMAGE, new DamageEffectList([VanillaDamageEffects.IGNORE_ARMOR, VanillaDamageEffects.BYPASS_BOSS_ARMOR]), other);
                    }
                    else
                    {
                        // PORT-NOTE: C# 是 Entity 的扩展方法 self.HealEffects(EAT_HEALING, other)（self 为 Entity 而非 Armor），
                        // 对应 VanillaEntityExt.HealEffects；VanillaArmorExt.HealEffects 的首参是 Armor，不要用错。
                        VanillaEntityExt.HealEffects(self, EAT_HEALING, other);
                    }
                }
            }
        }
        if (self.State == STATE_EAT && substate == EatState.SUBSTATE_DASH)
        {
            FinishEat(self);
        }
    }
    override public function PostTakeDamage(result:DamageOutput):Void
    {
        super.PostTakeDamage(result);

        var entity = result.Entity;
        //取消蓄能
        if (entity.State == STATE_CHARGE)
        {
            var substate = stateMachine.GetSubState(entity);
            if (substate == ChargeState.SUBSTATE_CHARGING)
            {
                Stun(entity);
                return;
            }
        }
        if (result.BodyResult != null)
        {
            var source = result.BodyResult.Source;
            var effects = result.BodyResult.Effects;
            var sourceEnt = source != null ? source.GetEntity(entity.Level) : null;
            if (sourceEnt != null && sourceEnt.IsEntityOf(VanillaEnemyID.bedserker) && effects.HasEffect(VanillaDamageEffects.EXPLOSION))
            {
                Stun(entity);
                return;
            }
        }
    }
    private function PreProjectileHitCallback(param:PreProjectileHitParams, result:CallbackResult):Void
    {
        var hit = param.hit;
        var self = hit.Other;
        if (!self.Definition.HasBehaviour(this))
            return;
        if (!HasArmor(self))
            return;
        // 免疫并移除子弹
        result.SetFinalValue(false);
        var projectile = hit.Projectile;
        projectile.Remove();
    }
    // #endregion 事件

    // #region 字段
    public static function GetPhase(entity:Entity):Int
    {
        return entity.GetBehaviourField(PROP_PHASE);
    }
    public static function SetPhase(entity:Entity, value:Int):Void
    {
        entity.SetBehaviourField(PROP_PHASE, value);
    }
    public static function GetHeadAngles(entity:Entity):Null<Array<Float>>
    {
        return entity.GetBehaviourField(PROP_HEAD_ANGLES);
    }
    public static function SetHeadAngles(entity:Entity, value:Array<Float>):Void
    {
        entity.SetBehaviourField(PROP_HEAD_ANGLES, value);
    }
    public static function GetHeadOpen(entity:Entity):Float
    {
        return entity.GetBehaviourField(PROP_HEAD_OPEN);
    }
    public static function SetHeadOpen(entity:Entity, value:Float):Void
    {
        entity.SetBehaviourField(PROP_HEAD_OPEN, value);
    }
    public static function GetHeadTargets(entity:Entity):Null<Array<Null<EntityID>>>
    {
        return entity.GetBehaviourField(PROP_HEAD_TARGETS);
    }
    public static function SetHeadTargets(entity:Entity, value:Array<Null<EntityID>>):Void
    {
        entity.SetBehaviourField(PROP_HEAD_TARGETS, value);
    }
    public static function GetSkullCharges(entity:Entity):Null<Array<Float>>
    {
        return entity.GetBehaviourField(PROP_SKULL_CHARGES);
    }
    public static function SetSkullCharges(entity:Entity, value:Array<Float>):Void
    {
        entity.SetBehaviourField(PROP_SKULL_CHARGES, value);
    }
    public static function GetTargetLane(entity:Entity):Int
    {
        return entity.GetBehaviourField(PROP_TARGET_LANE);
    }
    public static function SetTargetLane(entity:Entity, value:Int):Void
    {
        entity.SetBehaviourField(PROP_TARGET_LANE, value);
    }
    // #endregion

    public function Stun(entity:Entity):Void
    {
        if (entity.IsDead)
            return;
        entity.PlaySound(VanillaSoundID.witherDamage);
        entity.SetAnimationBool("Shaking", true);
        entity.TriggerAnimation("Interrupt");
        var vel = entity.Velocity;
        vel.x = 0;
        entity.Velocity = vel;
        stateMachine.StartState(entity, STATE_STUNNED);
    }
    public static function FinishEat(entity:Entity):Void
    {
        if (entity.State != STATE_EAT)
            return;
        var subState = stateMachine.GetSubState(entity);
        if (subState != EatState.SUBSTATE_DASH)
            return;
        var vel = entity.Velocity;
        vel.x = 0;
        entity.Velocity = vel;
        stateMachine.StartSubState(entity, EatState.SUBSTATE_EATEN);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetTime(20);
    }
    public function RotateHeadsUpdate(entity:Entity):Void
    {
        var headTargets = GetHeadTargets(entity);
        if (headTargets == null)
            return;
        var headAngles = GetHeadAngles(entity);
        if (headAngles == null)
        {
            headAngles = [];
            for (i in 0...HEAD_COUNT) headAngles.push(0);
            SetHeadAngles(entity, headAngles);
        }
        for (head in 0...headTargets.length)
        {
            var target = headTargets[head] != null ? headTargets[head].GetEntity(entity.Level) : null;
            var targetAngle:Float = 0;
            if (EngineEntityExt.ExistsAndAlive(target))
            {
                var headPosition = GetHeadPosition(entity, head);
                if (EngineEntityExt.ExistsAndAlive(target))
                {
                    var targetDirection = target.GetCenter() - headPosition;
                    var facingDirection = VanillaEntityExt.GetFacingDirection(entity);
                    var targetDir2D = new Vector2(targetDirection.x, targetDirection.z);
                    var facingDir2D = new Vector2(facingDirection.x, facingDirection.z);
                    targetAngle = Vector2.SignedAngle(targetDir2D, facingDir2D);
                }
            }

            var angle = headAngles[head];
            if (angle > 180)
            {
                angle = angle - 360;
            }
            if (targetAngle > angle)
            {
                if (angle + HEAD_ROTATE_SPEED > targetAngle)
                {
                    angle = targetAngle;
                }
                else
                {
                    angle += HEAD_ROTATE_SPEED;
                }
            }
            else
            {
                if (angle - HEAD_ROTATE_SPEED < targetAngle)
                {
                    angle = targetAngle;
                }
                else
                {
                    angle -= HEAD_ROTATE_SPEED;
                }
            }
            angle = Mathf.Repeat(angle, 360);
            headAngles[head] = angle;

            switch (head)
            {
                case HEAD_MAIN:
                    entity.SetAnimationFloat("MainHeadRotation", angle);
                case HEAD_RIGHT:
                    entity.SetAnimationFloat("RightHeadRotation", angle);
                case HEAD_LEFT:
                    entity.SetAnimationFloat("LeftHeadRotation", angle);
            }
        }
    }
    public static function FindChargeLanes(entity:Entity):Null<Array<Int>>
    {
        findChargeLaneBuffer = [];
        findChargeLaneDetector.DetectEntities(DetectionParams.fromEntity(entity), findChargeLaneBuffer);
        if (findChargeLaneBuffer.length <= 0)
            return null;
        // C#: findChargeLaneBuffer.GroupBy(e => e.GetLane()).Select(g => g.Key)
        var lanes:Array<Int> = [];
        for (e in findChargeLaneBuffer)
        {
            var lane = e.GetLane();
            if (lanes.indexOf(lane) < 0)
                lanes.push(lane);
        }
        return lanes;
    }
    public static function CanCharge(entity:Entity):Bool
    {
        var lanes = FindChargeLanes(entity);
        return lanes != null && lanes.length > 0;
    }
    public static function FindChargeLane(entity:Entity):Int
    {
        var lanes = FindChargeLanes(entity);
        if (lanes == null || lanes.length <= 0)
            return -1;
        return EnumerableExt.Random(lanes, entity.RNG);
    }
    public static function FindEatLanes(entity:Entity):Null<Array<Int>>
    {
        findEatLaneBuffer = [];
        findEatLaneDetector.DetectEntities(DetectionParams.fromEntity(entity), findEatLaneBuffer);
        if (findEatLaneBuffer.length <= 0)
            return null;
        var lanes:Array<Int> = [];
        for (e in findEatLaneBuffer)
        {
            var lane = e.GetLane();
            if (lanes.indexOf(lane) < 0)
                lanes.push(lane);
        }
        return lanes;
    }
    public static function CanEat(entity:Entity):Bool
    {
        var lanes = FindEatLanes(entity);
        return lanes != null && lanes.length > 0;
    }
    public static function FindEatLane(entity:Entity):Int
    {
        var lanes = FindEatLanes(entity);
        if (lanes == null || lanes.length <= 0)
            return -1;
        return EnumerableExt.Random(lanes, entity.RNG);
    }
    public static function HasArmor(entity:Entity):Bool
    {
        return GetPhase(entity) == PHASE_2 && !entity.IsDead;
    }
    public static function GetHeadPosition(entity:Entity, head:Int):Vector3
    {
        return entity.Position + headPositionOffsets[head];
    }
    public static function Appear(entity:Entity):Void
    {
        stateMachine.StartState(entity, STATE_APPEAR);
        entity.PlaySound(VanillaSoundID.witherSpawn);
        entity.PlaySound(VanillaSoundID.witherDeath);
    }

    // #region 常量
    public static var PROP_HEAD_ANGLES:VanillaEntityPropertyMeta<Array<Float>> = new VanillaEntityPropertyMeta<Array<Float>>("HeadAngles");
    public static var PROP_HEAD_OPEN:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("HeadOpen");
    public static var PROP_HEAD_TARGETS:VanillaEntityPropertyMeta<Array<Null<EntityID>>> = new VanillaEntityPropertyMeta<Array<Null<EntityID>>>("HeadTargets");
    public static var PROP_SKULL_CHARGES:VanillaEntityPropertyMeta<Array<Float>> = new VanillaEntityPropertyMeta<Array<Float>>("SkullCharges");
    public static var PROP_PHASE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("Phase");
    public static var PROP_TARGET_LANE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("TargetLane");

    public static var headPositionOffsets:Array<Vector3> = [
        new Vector3(0, 128, 0),
        new Vector3(0, 104, -16),
        new Vector3(0, 104, 16),
    ];

    public static inline var STATE_IDLE:Int = VanillaBossStates.IDLE;
    public static inline var STATE_APPEAR:Int = VanillaBossStates.APPEAR;
    public static inline var STATE_STUNNED:Int = VanillaBossStates.STUNNED;
    public static inline var STATE_DEATH:Int = VanillaBossStates.DEATH;
    public static inline var STATE_CHARGE:Int = VanillaBossStates.WITHER_CHARGE;
    public static inline var STATE_EAT:Int = VanillaBossStates.WITHER_EAT;
    public static inline var STATE_SWITCH:Int = VanillaBossStates.WITHER_SWITCH;
    public static inline var STATE_SUMMON:Int = VanillaBossStates.WITHER_SUMMON;

    public static inline var PHASE_1:Int = 0;
    public static inline var PHASE_2:Int = 1;

    public static inline var HEAD_MAIN:Int = 0;
    public static inline var HEAD_RIGHT:Int = 1;
    public static inline var HEAD_LEFT:Int = 2;

    public static inline var CRY_INTERVAL:Int = 100;
    public static inline var HEAD_COUNT:Int = 3;
    public static inline var HEAD_ROTATE_SPEED:Float = 10;
    public static inline var FLY_HEIGHT:Float = 80;
    public static inline var EAT_HEALING:Float = 300;
    public static inline var GOLDEN_APPLE_DAMAGE:Float = 900;
    public static inline var BOSS_REVENGE_PROJECTILE_DAMAGE_MULTIPLIER:Float = 0.05;
    // #endregion 常量

    public static inline var ANIMATION_STATE_IDLE:Int = 0;
    public static inline var ANIMATION_STATE_APPEAR:Int = 1;
    public static inline var ANIMATION_STATE_CHARGE:Int = 2;
    public static inline var ANIMATION_STATE_DEATH:Int = 3;
    public static inline var ANIMATION_STATE_EAT:Int = 4;
    public static inline var ANIMATION_STATE_SWITCH:Int = 5;
    public static inline var ANIMATION_STATE_SUMMON:Int = 6;
    public static inline var ANIMATION_STATE_STUNNED:Int = 7;

    public static var stateMachine:WitherStateMachine = new WitherStateMachine();
    public static var findChargeLaneDetector:Detector = new WitherDetector(WitherDetector.MODE_CHARGE);
    public static var findEatLaneDetector:Detector = new WitherDetector(WitherDetector.MODE_EAT);
    public static var findChargeLaneBuffer:Array<Entity> = [];
    public static var findEatLaneBuffer:Array<Entity> = [];
}

// #region 状态机
private class WitherStateMachine extends EntityStateMachine
{
    public function new()
    {
        super();
        AddState(new WitherAppearState());
        AddState(new WitherIdleState());
        AddState(new ChargeState());
        AddState(new EatState());
        AddState(new SwitchState());
        AddState(new SummonState());
        AddState(new StunState());
        AddState(new WitherDeathState());
    }
}
// #endregion

// #region 状态
private class WitherAppearState extends EntityStateMachineState
{
    public function new()
    {
        super(Wither.STATE_APPEAR, Wither.ANIMATION_STATE_APPEAR);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        entity.SetAnimationBool("Shaking", true);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetTime(30);
        Wither.SetHeadOpen(entity, 1);
    }
    override public function OnExit(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnExit(machine, entity);
        entity.SetAnimationBool("Shaking", false);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        Wither.SetHeadOpen(entity, 1);

        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.Run(stateMachine.GetSpeed(entity));
        if (!substateTimer.Expired)
            return;
        stateMachine.StartState(entity, Wither.STATE_IDLE);
    }
}
private class WitherIdleState extends EntityStateMachineState
{
    public var searchTargetBuffer:Array<Entity> = [];
    public var searchTargetDetector:Detector = new WitherDetector(WitherDetector.MODE_SKULL);
    public static inline var MAX_SKULL_CHARGE_MAIN:Int = 90;
    public static inline var MAX_SKULL_CHARGE:Int = 60;
    public function new()
    {
        super(Wither.STATE_IDLE, Wither.ANIMATION_STATE_IDLE);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var time = 300;
        if (VanillaBossExt.IsBossRevengeVersion(entity))
        {
            // Boss复仇模式下行动速度减半
            time *= 2;
        }
        var stateTimer = stateMachine.GetStateTimer(entity);
        stateTimer.ResetTime(time);
    }
    override public function OnExit(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnExit(machine, entity);
        var headTargets = Wither.GetHeadTargets(entity);
        if (headTargets == null)
            return;
        for (i in 0...headTargets.length)
        {
            headTargets[i] = null;
        }
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        if (Wither.GetPhase(entity) == Wither.PHASE_1 && entity.Health <= entity.GetMaxHealth() * 0.5)
        {
            Wither.SetPhase(entity, Wither.PHASE_2);
            stateMachine.StartState(entity, Wither.STATE_SWITCH);
            return;
        }
        UpdateAction(stateMachine, entity);
        UpdateStateSwitch(stateMachine, entity);
    }
    private function UpdateAction(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        var headOpen = Wither.GetHeadOpen(entity);
        headOpen *= 0.5;
        Wither.SetHeadOpen(entity, headOpen);

        UpdateArmored(entity);
        UpdateHeads(entity);
    }
    private function UpdateArmored(entity:Entity):Void
    {
        entity.SetRelativeY(Mathf.Max(0, entity.GetRelativeY() - 1));

        var targetPos = new Vector2(entity.Position.x, entity.Position.z);
        if (!Wither.HasArmor(entity))
        {
            if (entity.GetRelativeY() < Wither.FLY_HEIGHT)
            {
                var pos = entity.Position;
                pos.y += 7;
                entity.Position = pos;

                var vel = entity.Velocity;
                vel.y = Mathf.Max(0, vel.y);
                entity.Velocity = vel;
            }
            //主头负责移动
            var headTargets = Wither.GetHeadTargets(entity);
            if (headTargets != null && headTargets.length > 0)
            {
                var target = headTargets[0] != null ? headTargets[0].GetEntity(entity.Level) : null;
                if (EngineEntityExt.ExistsAndAlive(target))
                {
                    var level = entity.Level;
                    var targetColumn = LogicEntityExt.GetMirroredColumn(entity, 1, true);
                    targetPos = new Vector2(level.GetEntityColumnX(targetColumn), target.Position.z);
                }
            }
        }
        else
        {
            var level = entity.Level;
            var targetColumn = LogicEntityExt.GetMirroredColumn(entity, 1, true);
            var targetLane = Std.int(level.GetMaxLaneCount() / 2);
            targetPos = new Vector2(level.GetEntityColumnX(targetColumn), level.GetEntityLaneZ(targetLane));
        }
        var thisPos = new Vector2(entity.Position.x, entity.Position.z);
        var dir = targetPos - thisPos;
        if (dir.magnitude > 20)
        {
            var moveVel = dir.normalized * 20;
            var pos = entity.Position;
            pos.x += moveVel.x;
            pos.z += moveVel.y;
            entity.Position = pos;
        }
    }
    private function UpdateHeads(entity:Entity):Void
    {
        var headTargets = Wither.GetHeadTargets(entity);
        if (headTargets == null)
        {
            headTargets = [];
            for (i in 0...Wither.HEAD_COUNT) headTargets.push(null);
            Wither.SetHeadTargets(entity, headTargets);
        }
        for (head in 0...headTargets.length)
        {
            //锁定目标
            var target = headTargets[head] != null ? headTargets[head].GetEntity(entity.Level) : null;
            if (!EngineEntityExt.ExistsAndAlive(target))
            {
                //搜寻物体，看是否有合格的敌人
                searchTargetBuffer = [];
                searchTargetDetector.DetectEntities(DetectionParams.fromEntity(entity), searchTargetBuffer);
                //若拥有合格的敌人，则随机选取一个
                if (searchTargetBuffer.length > 0)
                {
                    target = EnumerableExt.Random(searchTargetBuffer, entity.RNG);
                    headTargets[head] = new EntityID(target);
                }
            }
            else
            {
                //判断目标是否合格，否则取消锁定
                if (!searchTargetDetector.ValidateTarget(DetectionParams.fromEntity(entity), target))
                {
                    target = null;
                    headTargets[head] = null;
                }
            }
            //锁定完毕，开始执行
            if (EngineEntityExt.ExistsAndAlive(target))
            {
                //发射凋灵之首
                FireSkullUpdate(entity, head, target);
            }
        }
    }
    private function FireSkullUpdate(entity:Entity, head:Int, target:Entity):Void
    {
        var skullCharges = Wither.GetSkullCharges(entity);
        if (skullCharges == null)
        {
            skullCharges = [];
            for (i in 0...Wither.HEAD_COUNT) skullCharges.push(0);
            Wither.SetSkullCharges(entity, skullCharges);
        }
        var maxCharges = head == 0 ? MAX_SKULL_CHARGE_MAIN : MAX_SKULL_CHARGE;
        if (VanillaBossExt.IsBossRevengeVersion(entity))
        {
            // Boss复仇模式下发射头颅速度减半
            maxCharges *= 2;
        }
        skullCharges[head] += VanillaEntityProps.GetAttackSpeed(entity);

        while (skullCharges[head] >= maxCharges)
        {
            var headPosition = Wither.GetHeadPosition(entity, head);
            var param = entity.GetShootParams();
            param.position = headPosition;
            param.projectileID = VanillaProjectileID.witherSkull;
            param.damage = VanillaEntityProps.GetDamage(entity) * 0.75;
            param.soundID = VanillaSoundID.witherShoot;
            param.velocity = (target.GetCenter() - headPosition).normalized * 9;
            entity.ShootProjectile(param);
            skullCharges[head] -= maxCharges;
        }
    }
    private function UpdateStateSwitch(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        var stateTimer = stateMachine.GetStateTimer(entity);
        stateTimer.Run(stateMachine.GetSpeed(entity));
        if (!stateTimer.Expired)
            return;
        var nextState = GetNextState(stateMachine, entity);
        stateMachine.StartState(entity, nextState);
        stateMachine.SetPreviousState(entity, nextState);
    }
    private function GetNextState(stateMachine:EntityStateMachine, entity:Entity):Int
    {
        var lastState = stateMachine.GetPreviousState(entity);
        if (lastState == Wither.STATE_IDLE || lastState == Wither.STATE_EAT)
        {
            lastState = Wither.STATE_SUMMON;
            if (Wither.GetPhase(entity) == Wither.PHASE_2)
            {
                return lastState;
            }
        }
        if (lastState == Wither.STATE_SUMMON)
        {
            lastState = Wither.STATE_CHARGE;
            if (Wither.CanCharge(entity))
            {
                return lastState;
            }
        }
        if (lastState == Wither.STATE_CHARGE)
        {
            lastState = Wither.STATE_EAT;
            if (Wither.CanEat(entity))
            {
                return lastState;
            }
        }

        return Wither.STATE_IDLE;
    }
}
private class ChargeState extends EntityStateMachineState
{
    public function new()
    {
        super(Wither.STATE_CHARGE, Wither.ANIMATION_STATE_CHARGE);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetTime(15);

        var lane = Wither.FindChargeLane(entity);
        if (lane < 0)
        {
            lane = entity.GetLane();
        }
        Wither.SetTargetLane(entity, lane);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.Run(stateMachine.GetSpeed(entity));

        var level = entity.Level;
        switch (substate)
        {
            case SUBSTATE_MOVE:
                {
                    //移动
                    var column = LogicEntityExt.GetMirroredColumn(entity, 0, true);
                    var targetX = level.GetEntityColumnX(column);
                    var targetZ = level.GetEntityLaneZ(Wither.GetTargetLane(entity));
                    var targetY = level.GetGroundY(targetX, targetZ);

                    var pos = entity.Position;
                    pos.x = pos.x * 0.85 + targetX * 0.15;
                    pos.y = pos.y * 0.85 + targetY * 0.15;
                    pos.z = pos.z * 0.85 + targetZ * 0.15;
                    entity.Position = pos;

                    if (substateTimer.Expired)
                    {
                        substateTimer.ResetTime(90);
                        stateMachine.StartSubState(entity, SUBSTATE_CHARGING);
                    }
                }

            case SUBSTATE_CHARGING:
                //聚能
                //张嘴
                var headOpen = Wither.GetHeadOpen(entity);
                headOpen = headOpen * 0.7 + 1 * 0.3;
                Wither.SetHeadOpen(entity, headOpen);

                if (substateTimer.Expired)
                {
                    var vel = entity.Velocity;
                    vel.x = VanillaEntityExt.GetFacingX(entity) * -20;
                    entity.Velocity = vel;
                    stateMachine.StartSubState(entity, SUBSTATE_DASH);
                    substateTimer.ResetTime(20);
                }
            case SUBSTATE_DASH:
                {
                    var pos = entity.Position;
                    var vel = entity.Velocity;
                    vel.x += VanillaEntityExt.GetFacingX(entity) * (substateTimer.MaxFrame - substateTimer.Frame) * 0.5;

                    var reachEnd = false;
                    var column = LogicEntityExt.GetMirroredColumn(entity, 0, false);
                    var endX = level.GetEntityColumnX(column);
                    reachEnd = Detection.IsInTheRearOf(endX, pos.x + vel.x, entity.IsFacingLeft());
                    if (reachEnd)
                    {
                        pos.x = endX;

                        vel.x = 0;
                        stateMachine.StartSubState(entity, SUBSTATE_DASH_END);
                        substateTimer.ResetTime(30);
                    }
                    entity.Position = pos;
                    entity.Velocity = vel;
                }
            case SUBSTATE_DASH_END:
                if (substateTimer.Expired)
                {
                    stateMachine.StartState(entity, Wither.STATE_IDLE);
                }
        }
    }
    public static inline var SUBSTATE_MOVE:Int = 0;
    public static inline var SUBSTATE_CHARGING:Int = 1;
    public static inline var SUBSTATE_DASH:Int = 2;
    public static inline var SUBSTATE_DASH_END:Int = 3;
}
private class EatState extends EntityStateMachineState
{
    public function new()
    {
        super(Wither.STATE_EAT, Wither.ANIMATION_STATE_EAT);
    }

    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetTime(15);

        var lane = Wither.FindEatLane(entity);
        if (lane < 0)
        {
            lane = entity.GetLane();
        }
        Wither.SetTargetLane(entity, lane);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.Run(stateMachine.GetSpeed(entity));

        var level = entity.Level;
        switch (substate)
        {
            case SUBSTATE_MOVE:
                {
                    //移动
                    var column = LogicEntityExt.GetMirroredColumn(entity, 0, true);
                    var targetX = level.GetEntityColumnX(column);
                    var targetZ = level.GetEntityLaneZ(Wither.GetTargetLane(entity));
                    var targetY = level.GetGroundY(targetX, targetZ);

                    var pos = entity.Position;
                    pos.x = pos.x * 0.85 + targetX * 0.15;
                    pos.y = pos.y * 0.85 + targetY * 0.15;
                    pos.z = pos.z * 0.85 + targetZ * 0.15;
                    entity.Position = pos;

                    if (substateTimer.Expired)
                    {
                        substateTimer.ResetTime(30);
                        stateMachine.StartSubState(entity, SUBSTATE_READY);
                    }
                }

            case SUBSTATE_READY:
                //聚能
                //张嘴
                var progress = substateTimer.MaxFrame - substateTimer.Frame;
                if (progress < 16)
                {
                    var headOpen = Wither.GetHeadOpen(entity);
                    if (progress < 4)
                    {
                        headOpen = Mathf.Lerp(0, 1, progress / 4);
                    }
                    else if (progress < 8)
                    {
                        headOpen = Mathf.Lerp(1, 0, (progress - 4) / 4);
                    }
                    else if (progress < 12)
                    {
                        headOpen = Mathf.Lerp(0, 1, (progress - 8) / 4);
                    }
                    else
                    {
                        headOpen = Mathf.Lerp(1, 0, (progress - 12) / 4);
                    }
                    Wither.SetHeadOpen(entity, headOpen);
                }
                if (substateTimer.PassedFrame(substateTimer.MaxFrame - 8) || substateTimer.PassedFrame(substateTimer.MaxFrame - 16))
                {
                    entity.PlaySound(VanillaSoundID.shieldHit, 0.5, 2);
                }

                if (substateTimer.Expired)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_DASH);
                    substateTimer.ResetTime(20);
                }
            case SUBSTATE_DASH:
                {
                    var headOpen = Wither.GetHeadOpen(entity);
                    headOpen = headOpen * 0.7 + 1 * 0.3;
                    Wither.SetHeadOpen(entity, headOpen);

                    var vel = entity.Velocity;
                    vel.x += VanillaEntityExt.GetFacingX(entity) * (substateTimer.MaxFrame - substateTimer.Frame) * 0.5;
                    entity.Velocity = vel;
                    if (substateTimer.Expired)
                    {
                        Wither.FinishEat(entity);
                    }
                }
            case SUBSTATE_EATEN:
                {
                    var headOpen = Wither.GetHeadOpen(entity);
                    headOpen = headOpen * 0.7;
                    Wither.SetHeadOpen(entity, headOpen);

                    var pos = entity.Position;
                    var vel = entity.Velocity;
                    vel.x -= VanillaEntityExt.GetFacingX(entity) * (substateTimer.MaxFrame - substateTimer.Frame) * 0.5;

                    var reachEnd = false;
                    var column = LogicEntityExt.GetMirroredColumn(entity, 0, true);
                    var endX = level.GetEntityColumnX(column);
                    reachEnd = Detection.IsInTheFrontOf(endX, pos.x + vel.x, entity.IsFacingLeft());
                    if (reachEnd)
                    {
                        pos.x = endX;
                        vel.x = 0;
                        stateMachine.StartState(entity, Wither.STATE_IDLE);
                    }
                    entity.Position = pos;
                    entity.Velocity = vel;
                }
        }
    }

    public static inline var SUBSTATE_MOVE:Int = 0;
    public static inline var SUBSTATE_READY:Int = 1;
    public static inline var SUBSTATE_DASH:Int = 2;
    public static inline var SUBSTATE_EATEN:Int = 3;
}
private class SwitchState extends EntityStateMachineState
{
    public function new()
    {
        super(Wither.STATE_SWITCH, Wither.ANIMATION_STATE_SWITCH);
    }
    override public function OnEnter(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(machine, entity);
        var stateTimer = machine.GetStateTimer(entity);
        stateTimer.ResetTime(60);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var headOpen = Wither.GetHeadOpen(entity);
        headOpen *= 0.5;
        Wither.SetHeadOpen(entity, headOpen);

        var substate = stateMachine.GetSubState(entity);
        UpdateMotion(stateMachine, entity, substate);
        if (substate == SUBSTATE_FLYING)
        {
            var distance2D = new Vector2(GetTargetX(entity) - entity.Position.x, GetTargetZ(entity) - entity.Position.z);
            if (distance2D.sqrMagnitude < 100)
            {
                stateMachine.StartSubState(entity, SUBSTATE_FALLING);
            }
        }
        else if (substate == SUBSTATE_FALLING)
        {
            if (entity.GetRelativeY() <= 1)
            {
                stateMachine.StartSubState(entity, SUBSTATE_ON_GROUND);
                entity.PlaySound(VanillaSoundID.witherSpawn);
                entity.PlaySound(VanillaSoundID.explosion);
                entity.Explode(entity.GetCenter(), 120, entity.GetFaction(), VanillaEntityProps.GetDamage(entity) * 18, new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN]));

                Explosion.Spawn(entity, entity.GetCenter(), 120);
                for (i in 0...entity.Level.GetMaxLaneCount())
                {
                    if (i == entity.GetLane())
                        continue;
                    var x = entity.Position.x;
                    var z = entity.Level.GetEntityLaneZ(i);
                    var y = entity.Level.GetGroundY(x, z);
                    entity.SpawnWithParams(VanillaEnemyID.dullahan, new Vector3(x, y, z));
                }
            }
        }

        var stateTimer = stateMachine.GetStateTimer(entity);
        stateTimer.Run(stateMachine.GetSpeed(entity));
        if (stateTimer.Expired)
        {
            stateMachine.StartState(entity, Wither.STATE_IDLE);
        }
    }
    private function UpdateMotion(stateMachine:EntityStateMachine, entity:Entity, substate:Int):Void
    {
        var level = entity.Level;
        var x = GetTargetX(entity);
        var z = GetTargetZ(entity);
        var y = level.GetGroundY(x, z);
        if (substate == SUBSTATE_FLYING)
        {
            y += 80;
        }
        var targetPos = new Vector3(x, y, z);

        var pos = entity.Position;
        pos = pos * 0.5 + targetPos * 0.5;
        entity.Position = pos;
    }
    private function GetTargetX(entity:Entity):Float
    {
        var level = entity.Level;
        var targetColumn = LogicEntityExt.GetMirroredColumn(entity, 1, true);
        return level.GetEntityColumnX(targetColumn);
    }
    private function GetTargetZ(entity:Entity):Float
    {
        var level = entity.Level;
        var targetLane = Std.int(level.GetMaxLaneCount() / 2);
        return level.GetEntityLaneZ(targetLane);
    }
    public static inline var SUBSTATE_FLYING:Int = 0;
    public static inline var SUBSTATE_FALLING:Int = 1;
    public static inline var SUBSTATE_ON_GROUND:Int = 2;
}
private class SummonState extends EntityStateMachineState
{
    public function new()
    {
        super(Wither.STATE_SUMMON, Wither.ANIMATION_STATE_SUMMON);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetTime(15);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.Run(stateMachine.GetSpeed(entity));

        var level = entity.Level;
        switch (substate)
        {
            case SUBSTATE_MOVE:
                {
                    //移动
                    var column = LogicEntityExt.GetMirroredColumn(entity, 0, true);
                    var lane = Std.int(level.GetMaxLaneCount() / 2);
                    var targetX = level.GetEntityColumnX(column);
                    var targetZ = level.GetEntityLaneZ(lane);
                    var targetY = level.GetGroundY(targetX, targetZ);

                    var pos = entity.Position;
                    pos.x = pos.x * 0.85 + targetX * 0.15;
                    pos.y = pos.y * 0.85 + targetY * 0.15;
                    pos.z = pos.z * 0.85 + targetZ * 0.15;
                    entity.Position = pos;

                    if (substateTimer.Expired)
                    {
                        substateTimer.ResetTime(30);
                        stateMachine.StartSubState(entity, SUBSTATE_ROAR);
                        entity.PlaySound(VanillaSoundID.witherCry);
                        entity.SetAnimationBool("Shaking", true);
                    }
                }

            case SUBSTATE_ROAR:
                {
                    //张嘴
                    var headOpen = Wither.GetHeadOpen(entity);
                    headOpen = headOpen * 0.7 + 1 * 0.3;
                    Wither.SetHeadOpen(entity, headOpen);

                    if (substateTimer.Expired)
                    {
                        entity.SetAnimationBool("Shaking", false);
                        stateMachine.StartSubState(entity, SUBSTATE_SUMMONED);
                        substateTimer.ResetTime(30);

                        entity.PlaySound(VanillaSoundID.witherSpawn);
                        var count = 1;
                        for (i in 0...count)
                        {
                            var lane = entity.GetLane();
                            var laneOffsetLength = Std.int((i + 1) / 2);
                            var laneOffsetDirection = ((i + 1) % 2) * 2 - 1;
                            lane += laneOffsetDirection * laneOffsetLength;
                            var position = entity.Position;
                            position.z = entity.Level.GetEntityLaneZ(lane);
                            position += VanillaEntityExt.GetFacingDirection(entity) * 80;
                            var e = entity.SpawnWithParams(VanillaEnemyID.bedserker, position);
                            if (e != null)
                            {
                                Explosion.Spawn(entity, e.GetCenter(), 60);
                            }
                        }
                        entity.PlaySound(VanillaSoundID.explosion);
                    }
                }
            case SUBSTATE_SUMMONED:
                {
                    var headOpen = Wither.GetHeadOpen(entity);
                    headOpen = headOpen * 0.7;
                    Wither.SetHeadOpen(entity, headOpen);

                    if (substateTimer.Expired)
                    {
                        stateMachine.StartState(entity, Wither.STATE_IDLE);
                    }
                }
        }
    }
    public static inline var SUBSTATE_MOVE:Int = 0;
    public static inline var SUBSTATE_ROAR:Int = 1;
    public static inline var SUBSTATE_SUMMONED:Int = 2;
}
private class StunState extends EntityStateMachineState
{
    public function new()
    {
        super(Wither.STATE_STUNNED, Wither.ANIMATION_STATE_STUNNED);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var stateTimer = stateMachine.GetStateTimer(entity);
        stateTimer.ResetTime(30);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var stateTimer = stateMachine.GetStateTimer(entity);
        stateTimer.Run(stateMachine.GetSpeed(entity));
        var headOpen = Wither.GetHeadOpen(entity);
        headOpen = headOpen * 0.7 + 1 * 0.3;
        Wither.SetHeadOpen(entity, headOpen);

        if (stateTimer.Expired)
        {
            entity.SetAnimationBool("Shaking", false);
            stateMachine.StartState(entity, Wither.STATE_IDLE);
        }
    }
}
private class WitherDeathState extends EntityStateMachineState
{
    public function new()
    {
        super(Wither.STATE_DEATH, Wither.ANIMATION_STATE_DEATH);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        entity.SetAnimationBool("Shaking", true);
        var stateTimer = stateMachine.GetStateTimer(entity);
        stateTimer.ResetTime(150);
    }
    override public function OnUpdateLogic(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(stateMachine, entity);
        var headOpen = Wither.GetHeadOpen(entity);
        headOpen = headOpen * 0.7 + 1 * 0.3;
        Wither.SetHeadOpen(entity, headOpen);

        var stateTimer = stateMachine.GetStateTimer(entity);
        stateTimer.Run(stateMachine.GetSpeed(entity));

        if (stateTimer.Expired)
        {
            entity.PlaySound(VanillaSoundID.witherDeath);
            entity.PlaySound(VanillaSoundID.explosion);
            entity.Explode(entity.GetCenter(), 120, entity.GetFaction(), VanillaEntityProps.GetDamage(entity) * 18, new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN]));

            Explosion.Spawn(entity, entity.GetCenter(), 120);
            entity.Level.ShakeScreen(20, 0, 30);
            entity.Remove();
        }
    }
}
// #endregion
