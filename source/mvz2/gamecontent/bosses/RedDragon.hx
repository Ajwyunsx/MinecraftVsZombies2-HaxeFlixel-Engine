// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/RedDragon/RedDragon.cs
// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/RedDragon/RedDragon_States.cs
// PORT-NOTE: the C# `partial class RedDragon` spans RedDragon.cs and RedDragon_States.cs;
// per PORTING.md partial classes are merged into a single Haxe module.
// PORT-NOTE: members accessed by the C# nested state classes are `public` here,
// because Haxe module types do not share class-level private visibility.
package mvz2.gamecontent.bosses;

import Lambda;
import mvz2.gamecontent.areas.VanillaAreaID;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.level.BeaconMeteorBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.CollisionDetector;
import mvz2.gamecontent.detections.RedDragonEatDetector;
import mvz2.gamecontent.effects.DragonFireBreath;
import mvz2.gamecontent.effects.Explosion;
import mvz2.gamecontent.effects.Tornado;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.projectiles.ExplosiveLargeFireball;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.gamecontent.shells.VanillaShellID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.bosses.VanillaBossExt;
import mvz2.vanilla.bosses.VanillaBossStates;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2.vanilla.statemachine.EntityStateMachine;
import mvz2.vanilla.statemachine.EntityStateMachineHelper;
import mvz2.vanilla.statemachine.EntityStateMachineState;
import pvzengine.entities.EntityTypes;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.level.LevelPositions;
import pvzengine.NamespaceID;
import pvzengine.RandomGenerator;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.collisions.IEntityCollider;
import pvzengine.collisions.level.OverlapParams;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.grids.LawnGrid;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.ColorModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import tools.EnumerableExt;
import tools.FrameTimer;
import tools.Ticks;
import unity.Bounds;
import unity.Color;
import unity.Mathf;
import unity.Quaternion;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import mvz2.vanilla.armors.VanillaArmorExt;
import mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
import pvzengine.entities.EngineEntityExt;
import mvz2logic.level.LogicStageProps;

@:autoEntityBehaviourDefinition(VanillaBossNames.redDragon)
class RedDragon extends BossBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Multiply(EngineEntityProps.TINT, PROP_TINT_MULTIPLIER));
        AddModifier(new FloatModifier(EngineEntityProps.GRAVITY, NumberOperator.Multiply, PROP_GRAVITY_MULTIPLIER));
        AddModifier(new FloatModifier(EngineEntityProps.GROUND_LIMIT_OFFSET, NumberOperator.Add, PROP_GROUND_LIMIT_OFFSET));
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, PROP_INVINCIBLE));
        AddModifier(new BooleanModifier(VanillaEntityProps.INVISIBLE, PROP_INVINCIBLE));
    }

    // #region 回调
    override public function Init(boss:Entity):Void
    {
        super.Init(boss);
        stateMachine.Init(boss);
        stateMachine.StartState(boss, STATE_IDLE);
    }
    override public function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        stateMachine.UpdateAI(entity);
    }
    override public function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        stateMachine.UpdateLogic(entity);

        entity.SetAnimationFloat("HeadRotation", GetHeadRotation(entity));
        entity.SetAnimationFloat("Rotation", GetRotation(entity));
        entity.SetModelProperty("FireInMouth", GetFireInMouth(entity));
        entity.SetModelProperty("FireVariant", GetFireVariant(entity));
    }
    // #endregion 事件

    public static function SetAppear(entity:Entity):Void
    {
        stateMachine.StartState(entity, STATE_APPEAR);
    }
    public static function GetNeckDirection(entity:Entity):Vector3
    {
        var headRotation = GetHeadRotation(entity);
        var neckDirection = Quaternion.Euler(0, headRotation, 0) * Vector3.right;
        neckDirection.x *= VanillaEntityExt.GetFacingX(entity);
        return neckDirection;
    }
    public static function GetSpitSourcePosition(entity:Entity):Vector3
    {
        var neckDirection = GetNeckDirection(entity);
        return GetNeckRootPosition(entity) + neckDirection * NECK_LENGTH;
    }
    public static function GetNeckRootPosition(entity:Entity):Vector3
    {
        return entity.Position + VanillaEntityExt.GetFacingDirection(entity) * 140 + Vector3.up * 40;
    }
    public static function GetTornadoSourcePosition(entity:Entity):Vector3
    {
        return entity.Position + VanillaEntityExt.GetFacingDirection(entity) * 240;
    }
    public static function GetFireVariant(entity:Entity):Int
    {
        var eatenFlags = GetEatenFlags(entity);
        if ((eatenFlags & EATEN_FLAG_CORPSE) != 0)
            return DragonFireBreath.VARIANT_CYAN;
        if ((eatenFlags & EATEN_FLAG_CHARCOAL) != 0)
            return DragonFireBreath.VARIANT_RED;
        return DragonFireBreath.VARIANT_ORANGE;
    }
    public static function LandCrush(entity:Entity):Void
    {
        var level = entity.Level;
        landBuffer = [];
        landDetector.DetectMultiple(DetectionParams.fromEntity(entity), landBuffer);
        for (collider in landBuffer)
        {
            var ent = collider.Entity;
            var damageOutput = collider.TakeDamage(VanillaEntityProps.GetTakenCrushDamage(ent), new DamageEffectList([VanillaDamageEffects.IMPACT, VanillaDamageEffects.IGNORE_ARMOR]), entity);
            if (ent.Type == EntityTypes.PLANT)
            {
                if (damageOutput != null && damageOutput.BodyResult != null && damageOutput.BodyResult.Fatal)
                {
                    entity.PlaySound(VanillaSoundID.smash);
                }
            }
        }
    }

    // #region 字段
    public static function GetFireInMouth(entity:Entity):Bool
    {
        return entity.GetBehaviourField(PROP_FIRE_IN_MOUTH);
    }
    public static function SetFireInMouth(entity:Entity, value:Bool):Void
    {
        entity.SetBehaviourField(PROP_FIRE_IN_MOUTH, value);
    }
    public static function GetInvincible(entity:Entity):Bool
    {
        return entity.GetBehaviourField(PROP_INVINCIBLE);
    }
    public static function SetInvincible(entity:Entity, value:Bool):Void
    {
        entity.SetBehaviourField(PROP_INVINCIBLE, value);
    }
    public static function GetHeadRotation(entity:Entity):Float
    {
        return entity.GetBehaviourField(PROP_HEAD_ROTATION);
    }
    public static function SetHeadRotation(entity:Entity, value:Float):Void
    {
        entity.SetBehaviourField(PROP_HEAD_ROTATION, value);
    }
    public static function GetRotation(entity:Entity):Float
    {
        return entity.GetBehaviourField(PROP_ROTATION);
    }
    public static function SetRotation(entity:Entity, value:Float):Void
    {
        entity.SetBehaviourField(PROP_ROTATION, value);
    }
    public static function GetGravityMultiplier(entity:Entity):Float
    {
        return entity.GetBehaviourField(PROP_GRAVITY_MULTIPLIER);
    }
    public static function SetGravityMultiplier(entity:Entity, value:Float):Void
    {
        entity.SetBehaviourField(PROP_GRAVITY_MULTIPLIER, value);
    }
    public static function GetGroundLimitOffset(entity:Entity):Float
    {
        return entity.GetBehaviourField(PROP_GROUND_LIMIT_OFFSET);
    }
    public static function SetGroundLimitOffset(entity:Entity, value:Float):Void
    {
        entity.SetBehaviourField(PROP_GROUND_LIMIT_OFFSET, value);
    }
    public static function GetPhase(entity:Entity):Int
    {
        return entity.GetBehaviourField(PROP_PHASE);
    }
    public static function SetPhase(entity:Entity, value:Int):Void
    {
        entity.SetBehaviourField(PROP_PHASE, value);
    }
    public static function GetEatenFlags(entity:Entity):Int
    {
        return entity.GetBehaviourField(PROP_EATEN_FLAGS);
    }
    public static function SetEatenFlags(entity:Entity, value:Int):Void
    {
        entity.SetBehaviourField(PROP_EATEN_FLAGS, value);
    }
    public static function GetJumpTarget(entity:Entity):Vector3
    {
        return entity.GetBehaviourField(PROP_JUMP_TARGET);
    }
    public static function SetJumpTarget(entity:Entity, value:Vector3):Void
    {
        entity.SetBehaviourField(PROP_JUMP_TARGET, value);
    }
    public static function GetTintMultiplier(entity:Entity):Color
    {
        return entity.GetBehaviourField(PROP_TINT_MULTIPLIER);
    }
    public static function SetTintMultiplier(entity:Entity, value:Color):Void
    {
        entity.SetBehaviourField(PROP_TINT_MULTIPLIER, value);
    }
    public static function GetJumpFinishState(entity:Entity):Int
    {
        return entity.GetBehaviourField(PROP_JUMP_FINISH_STATE);
    }
    public static function SetJumpFinishState(entity:Entity, value:Int):Void
    {
        entity.SetBehaviourField(PROP_JUMP_FINISH_STATE, value);
    }
    public static function GetEatenEntities(entity:Entity):Null<Array<NamespaceID>>
    {
        return entity.GetBehaviourField(PROP_EATEN_ENTITIES);
    }
    public static function SetEatenEntities(entity:Entity, value:Null<Array<NamespaceID>>):Void
    {
        entity.SetBehaviourField(PROP_EATEN_ENTITIES, value);
    }
    // #endregion

    // #region 常量
    public static var PROP_FIRE_IN_MOUTH:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("fire_in_mouth");
    public static var PROP_INVINCIBLE:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("invincible");
    public static var PROP_PHASE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("phase");
    public static var PROP_EATEN_FLAGS:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("eaten_flags");
    public static var PROP_JUMP_FINISH_STATE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("jump_finish_state", -1);
    public static var PROP_HEAD_ROTATION:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("head_rotation");
    public static var PROP_ROTATION:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("rotation");
    public static var PROP_GRAVITY_MULTIPLIER:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("gravity_multiplier", 1);
    public static var PROP_GROUND_LIMIT_OFFSET:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("ground_limit_offset");
    public static var PROP_JUMP_TARGET:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("jump_target");
    public static var PROP_TINT_MULTIPLIER:VanillaEntityPropertyMeta<Color> = new VanillaEntityPropertyMeta<Color>("tint_multiplier", Color.white);
    public static var PROP_EATEN_ENTITIES:VanillaEntityPropertyMeta<Array<NamespaceID>> = new VanillaEntityPropertyMeta<Array<NamespaceID>>("eaten_entities");

    public static var landDetector:Detector = new CollisionDetector(true);
    public static var landBuffer:Array<IEntityCollider> = [];

    public static inline var STATE_IDLE:Int = VanillaBossStates.IDLE;
    public static inline var STATE_APPEAR:Int = VanillaBossStates.APPEAR;
    public static inline var STATE_STUNNED:Int = VanillaBossStates.STUNNED;
    public static inline var STATE_DEATH:Int = VanillaBossStates.DEATH;
    public static inline var STATE_SPIT:Int = VanillaBossStates.RED_DRAGON_SPIT;
    public static inline var STATE_JUMP:Int = VanillaBossStates.RED_DRAGON_JUMP;
    public static inline var STATE_FLAP_WINGS:Int = VanillaBossStates.RED_DRAGON_FLAP_WINGS;
    public static inline var STATE_EAT:Int = VanillaBossStates.RED_DRAGON_EAT;
    public static inline var STATE_FIRE_BREATH:Int = VanillaBossStates.RED_DRAGON_FIRE_BREATH;
    public static inline var STATE_ROAR:Int = VanillaBossStates.RED_DRAGON_ROAR;
    public static inline var STATE_LARGE_FIREBALL:Int = VanillaBossStates.RED_DRAGON_LARGE_FIREBALL;
    public static inline var STATE_SPIT_UP:Int = VanillaBossStates.RED_DRAGON_SPIT_UP;
    public static inline var STATE_FLY:Int = VanillaBossStates.RED_DRAGON_FLY;
    public static inline var STATE_TAIL_SWIPE:Int = VanillaBossStates.RED_DRAGON_TAIL_SWIPE;
    public static inline var STATE_DEATH_ROAR:Int = VanillaBossStates.RED_DRAGON_DEATH_ROAR;
    public static inline var STATE_DEATH_FLY:Int = VanillaBossStates.RED_DRAGON_DEATH_FLY;

    public static inline var ANIMATION_STATE_IDLE:Int = 0;
    public static inline var ANIMATION_STATE_APPEAR:Int = 1;
    public static inline var ANIMATION_STATE_STUNNED:Int = 2;
    public static inline var ANIMATION_STATE_DEATH:Int = 3;
    public static inline var ANIMATION_STATE_SPIT:Int = 10000;
    public static inline var ANIMATION_STATE_JUMP:Int = 10001;
    public static inline var ANIMATION_STATE_FLAP_WINGS:Int = 10002;
    public static inline var ANIMATION_STATE_EAT:Int = 10003;
    public static inline var ANIMATION_STATE_SPIT_UP:Int = 10004;
    public static inline var ANIMATION_STATE_FLY:Int = 10005;
    public static inline var ANIMATION_STATE_TAIL_SWIPE:Int = 10006;
    public static inline var ANIMATION_STATE_DEATH_FLY:Int = 10007;

    public static inline var PHASE_1:Int = 0;
    public static inline var PHASE_2:Int = 1;

    public static inline var NECK_LENGTH:Float = 260;

    public static inline var APPEAR_START_X:Float = -1000;
    public static inline var APPEAR_START_Y:Float = 160;

    public static inline var EAT_HEAL_PER_ENTITY:Float = 400;
    public static inline var EAT_HITBOX_WIDTH:Float = 64;
    public static inline var EAT_HITBOX_HEIGHT:Float = 64;
    public static inline var EAT_HITBOX_Z_LENGTH:Float = 64;
    public static inline var EAT_HITBOX_RANGE:Float = 200;
    public static inline var EAT_HITBOX_DISTANCE_X:Float = 320;
    public static inline var BITE_DAMAGE_MULTIPLIER:Float = 3;

    public static inline var ROAR_SECONDS:Float = 2;

    public static inline var SELF_EXPLODE_STUN_SECONDS:Float = 2;

    public static inline var FIRE_BREATH_DAMAGE_MULTIPLIER:Float = 0.01;
    public static inline var FIRE_BREATH_SPEED:Float = 20;

    public static inline var METEOR_DAMAGE_MULTIPLIER:Float = 3;
    public static inline var METEOR_COUNT:Int = 3;
    public static var METEOR_HSV_OFFSET:Vector3 = new Vector3(-20, 0, 0);

    public static inline var FLY_SPEED:Float = 50;
    public static inline var FIRE_EXPLOSION_DAMAGE_MULTIPLIER:Float = 3;

    public static inline var TAIL_SWIPE_COLUMN_RANGE:Int = 6;
    public static inline var TAIL_SWIPE_LANE_RANGE_START:Int = -2;
    public static inline var TAIL_SWIPE_LANE_RANGE_END:Int = 2;

    public static inline var FIRE_BREATH_ANGLE_START:Float = -30;
    public static inline var FIRE_BREATH_ANGLE_END:Float = 30;

    public static inline var EATEN_FLAG_CORPSE:Int = 1;
    public static inline var EATEN_FLAG_CHARCOAL:Int = 1 << 1;
    public static inline var EATEN_FLAG_DYNAMITE:Int = 1 << 2;

    // #endregion 常量

    public static var stateMachine:RedDragonStateMachine = new RedDragonStateMachine();
    public static var eatDetector:Detector = new RedDragonEatDetector();
    public static var statePoolPhase1:Array<Int> = [
        STATE_SPIT,
        STATE_FLAP_WINGS,
        STATE_EAT,
        STATE_JUMP
    ];
    public static var statePoolPhase2:Array<Int> = [
        STATE_LARGE_FIREBALL,
        STATE_FLAP_WINGS,
        STATE_SPIT_UP,
        STATE_FLY,
        STATE_JUMP
    ];
}

private class RedDragonStateMachine extends EntityStateMachine
{
    public function new()
    {
        super();
        AddState(new DragonIdleState());
        AddState(new DragonAppearState());
        AddState(new DragonStunnedState());
        AddState(new DragonDeathState());
        AddState(new DeathRoarState());
        AddState(new DeathFlyState());
        AddState(new DragonJumpState());
        AddState(new SpitState());
        AddState(new FlapWingsState());
        AddState(new DragonEatState());
        AddState(new FireBreathState());
        AddState(new DragonRoarState());
        AddState(new LargeFireballState());
        AddState(new SpitUpState());
        AddState(new DragonFlyState());
        AddState(new TailSwipeState());
    }
}

class RedDragonHelpers
{
    public static function CheckDeath(entity:Entity):Void
    {
        if (!entity.IsDead)
            return;
        RedDragon.stateMachine.StartState(entity, RedDragon.STATE_DEATH);
    }
    public static function HasEnemiesInTheLane(entity:Entity):Bool
    {
        var lane = entity.GetLane();
        return entity.Level.EntityExists(function(e) return e.GetLane() == lane && entity.IsHostile(e) && LogicEntityExt.IsVulnerableEntity(e));
    }
    public static function Roar(entity:Entity):Void
    {
        var position = RedDragon.GetSpitSourcePosition(entity);
        RoarAt(entity, position);
    }
    public static function RoarAt(entity:Entity, position:Vector3):Void
    {
        var param = entity.GetSpawnParams();
        entity.Spawn(VanillaEffectID.amplifiedRoar, position, param);
        var time = Ticks.FromSeconds(RedDragon.ROAR_SECONDS);
        entity.Level.ShakeScreen(15, 0, time);
        VanillaBossExt.BossRoar(entity, time);
        entity.PlaySound(VanillaSoundID.dragonGrowl);
    }
}

// #region 飞行（出场）
private class DragonAppearState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_APPEAR, RedDragon.ANIMATION_STATE_FLY);
    }
    override public function GetAnimationSubstate(substate:Int):Int
    {
        switch (substate)
        {
            case SUBSTATE_FLY:
                return ANIMATION_SUBSTATE_FLY;
            case SUBSTATE_GLIDE:
                return ANIMATION_SUBSTATE_GLIDE;
            case SUBSTATE_LAND:
                return ANIMATION_SUBSTATE_LAND;
        }
        return super.GetAnimationSubstate(substate);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(2);

        RedDragon.SetRotation(entity, 180);
        var targetLane = Std.int(entity.Level.GetMaxLaneCount() / 2);
        var position = entity.Position;
        position.x = RedDragon.APPEAR_START_X;
        position.y = RedDragon.APPEAR_START_Y;
        position.z = entity.Level.GetEntityLaneZ(targetLane);
        entity.Position = position;
        RedDragon.SetGravityMultiplier(entity, 0);

        RedDragon.SetInvincible(entity, true);
    }
    override public function OnExit(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnExit(machine, entity);
        RedDragon.SetRotation(entity, 0);
        RedDragon.SetGravityMultiplier(entity, 1);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var timer = stateMachine.GetSubStateTimer(entity);
        timer.Run(stateMachine.GetSpeed(entity));
        switch (substate)
        {
            case SUBSTATE_FLY:
                {
                    entity.Velocity = VanillaEntityExt.GetFacingDirection(entity) * -RedDragon.FLY_SPEED; // 向右飞，但是仍面朝左侧，只是模型旋转了180度。
                    if (timer.PassedIntervalSeconds(0.5))
                    {
                        entity.PlaySound(VanillaSoundID.dragonWings);
                    }
                    if (timer.Expired)
                    {
                        stateMachine.StartSubState(entity, SUBSTATE_GLIDE);
                        timer.ResetSeconds(1);
                        entity.PlaySound(VanillaSoundID.dragonGrowl);
                        RedDragon.SetRotation(entity, 0);
                    }
                }
            case SUBSTATE_GLIDE:
                var middleLane = Std.int(entity.Level.GetMaxLaneCount() / 2);
                var targetPosition = RedDragonHelpers2.GetJumpBorderPositionByLane(entity, middleLane);
                entity.Velocity = (targetPosition - entity.Position).normalized * RedDragon.FLY_SPEED;
                if (entity.IsOnGround)
                {
                    entity.Level.ShakeScreen(20, 0, 30);
                    entity.PlaySound(VanillaSoundID.thump);
                    stateMachine.StartSubState(entity, SUBSTATE_LAND);
                    timer.ResetSeconds(1);
                }
            case SUBSTATE_LAND:
                {
                    var position = entity.Position;
                    position.x = Ticks.SmoothDamp(position.x, RedDragonHelpers2.GetJumpBorderX(entity), 0.2);
                    entity.Position = position;
                    entity.Velocity = Ticks.SmoothDampVector(entity.Velocity, Vector3.zero, 0.2);

                    RedDragon.LandCrush(entity);

                    if (timer.Expired)
                    {
                        stateMachine.StartState(entity, RedDragon.STATE_ROAR);
                        stateMachine.StartSubState(entity, DragonRoarState.ANIMATION_SUBSTATE_APPEAR_START);
                    }
                }
        }
    }
    override public function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        RedDragonHelpers.CheckDeath(entity);
    }
    public static inline var SUBSTATE_FLY:Int = 0;
    public static inline var SUBSTATE_GLIDE:Int = 1;
    public static inline var SUBSTATE_LAND:Int = 2;
    public static inline var ANIMATION_SUBSTATE_FLY:Int = 1;
    public static inline var ANIMATION_SUBSTATE_GLIDE:Int = 2;
    public static inline var ANIMATION_SUBSTATE_LAND:Int = 3;
}
// #endregion

// #region 待命
private class DragonIdleState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_IDLE, RedDragon.ANIMATION_STATE_IDLE);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var seconds = RedDragon.GetPhase(entity) == RedDragon.PHASE_1 ? 3 : 2; // 一阶段行动更慢
        var stateTimer = stateMachine.GetStateTimer(entity);
        stateTimer.ResetSeconds(seconds);
        RedDragon.SetInvincible(entity, false);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        UpdateStateSwitch(stateMachine, entity);
    }
    override public function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        RedDragonHelpers.CheckDeath(entity);
    }
    private function UpdateStateSwitch(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        // 转阶段
        if (entity.Health <= entity.GetMaxHealth() * 0.5 && RedDragon.GetPhase(entity) == RedDragon.PHASE_1)
        {
            RedDragon.SetPhase(entity, RedDragon.PHASE_2);
            RedDragon.SetEatenFlags(entity, 0);
            stateMachine.StartState(entity, RedDragon.STATE_ROAR);
            return;
        }

        var stateTimer = stateMachine.GetStateTimer(entity);
        stateTimer.Run(stateMachine.GetSpeed(entity));
        if (stateTimer.Expired)
        {
            var nextIndex = stateMachine.GetNextStateIndex(entity);
            var pool:Array<Int>;
            if (RedDragon.GetPhase(entity) == RedDragon.PHASE_1)
            {
                pool = RedDragon.statePoolPhase1;
                nextIndex = EntityStateMachineHelper.FindNextStateIndex(pool, nextIndex, function(state) return RedDragonHelpers2.CanSwitchStatePhase1(entity, state));
            }
            else
            {
                pool = RedDragon.statePoolPhase2;
                nextIndex = EntityStateMachineHelper.FindNextStateIndex(pool, nextIndex, function(state) return RedDragonHelpers2.CanSwitchStatePhase2(entity, state));
            }
            if (nextIndex >= 0)
            {
                var state = pool[nextIndex];
                stateMachine.SetNextStateIndex(entity, nextIndex + 1);
                RedDragonHelpers2.SwitchState(entity, state);
            }
            else
            {
                stateTimer.Reset();
            }
        }
    }
}

// #endregion

class RedDragonHelpers2
{
    public static function CanSwitchStatePhase1(entity:Entity, state:Int):Bool
    {
        switch (state)
        {
            case RedDragon.STATE_SPIT, RedDragon.STATE_FLAP_WINGS:
                if (!entity.Level.EntityExists(function(e) return entity.IsHostile(e) && LogicEntityExt.IsVulnerableEntity(e)))
                    return false;
        }
        return true;
    }
    public static function CanSwitchStatePhase2(entity:Entity, state:Int):Bool
    {
        switch (state)
        {
            case RedDragon.STATE_LARGE_FIREBALL, RedDragon.STATE_FLAP_WINGS, RedDragon.STATE_FLY:
                if (!entity.Level.EntityExists(function(e) return entity.IsHostile(e) && LogicEntityExt.IsVulnerableEntity(e)))
                    return false;
        }
        return true;
    }
    public static function SwitchState(entity:Entity, state:Int):Void
    {
        switch (state)
        {
            case RedDragon.STATE_SPIT, RedDragon.STATE_FLAP_WINGS, RedDragon.STATE_LARGE_FIREBALL:
                if (RedDragonHelpers.HasEnemiesInTheLane(entity))
                {
                    RedDragon.stateMachine.StartState(entity, state);
                }
                else
                {
                    var jumpTarget = RedDragonHelpers2.FindEnemyJumpTargetPosition(entity);
                    RedDragonHelpers2.JumpTo(entity, jumpTarget, state);
                }
            case RedDragon.STATE_EAT:
                {
                    var middleLane = Std.int(entity.Level.GetMaxLaneCount() / 2);
                    // 没有可吃的目标，直接喷火。
                    if (!RedDragonHelpers2.HasEatableTargets(entity))
                    {
                        state = RedDragon.STATE_FIRE_BREATH;
                    }
                    if (entity.GetLane() == middleLane)
                    {
                        RedDragon.stateMachine.StartState(entity, state);
                    }
                    else
                    {
                        var jumpTarget = RedDragonHelpers2.GetJumpBorderPositionByLane(entity, middleLane);
                        RedDragonHelpers2.JumpTo(entity, jumpTarget, state);
                    }
                }
            case RedDragon.STATE_JUMP:
                {
                    var jumpTarget = RedDragonHelpers2.FindRandomJumpTargetPosition(entity);
                    RedDragonHelpers2.JumpTo(entity, jumpTarget, RedDragon.STATE_IDLE);
                }
            case RedDragon.STATE_SPIT_UP:
                {
                    var middleLane = Std.int(entity.Level.GetMaxLaneCount() / 2);
                    if (entity.GetLane() == middleLane)
                    {
                        RedDragon.stateMachine.StartState(entity, state);
                    }
                    else
                    {
                        var jumpTarget = RedDragonHelpers2.GetJumpBorderPositionByLane(entity, middleLane);
                        RedDragonHelpers2.JumpTo(entity, jumpTarget, state);
                    }
                }
            case RedDragon.STATE_FLY:
                {
                    RedDragon.stateMachine.StartState(entity, state);
                }
        }
    }
    public static function HasEatableTargets(boss:Entity):Bool
    {
        return RedDragon.eatDetector.DetectEntityCount(DetectionParams.fromEntity(boss)) > 0;
    }

    // #region 跳跃
    public static function JumpTo(entity:Entity, jumpTarget:Vector3, state:Int):Void
    {
        RedDragon.SetJumpFinishState(entity, state);
        RedDragon.SetJumpTarget(entity, jumpTarget);
        RedDragon.stateMachine.StartState(entity, RedDragon.STATE_JUMP);
    }
    public static function GetJumpBorderX(boss:Entity):Float
    {
        return LogicEntityExt.GetMirroredX(boss, LevelPositions.RIGHT_BORDER + 80, false);
    }
    public static function GetJumpBorderPositionByLane(boss:Entity, lane:Int):Vector3
    {
        var x = GetJumpBorderX(boss);
        var z = boss.Level.GetEntityLaneZ(lane);
        var y = boss.Level.GetGroundY(x, z);
        return new Vector3(x, y, z);
    }
    public static function FindLanesWithEnemies(boss:Entity):Array<Int>
    {
        var entities = boss.Level.FindEntities(function(e) return LogicEntityExt.IsVulnerableEntity(e) && boss.IsHostile(e));
        var lanes:Array<Int> = [];
        for (e in entities)
        {
            var lane = e.GetLane();
            if (lanes.indexOf(lane) < 0)
                lanes.push(lane);
        }
        return lanes;
    }
    public static function FindRandomLaneWithEnemy(boss:Entity):Int
    {
        var lanes = FindLanesWithEnemies(boss);
        if (lanes.length <= 0)
        {
            return boss.GetLane();
        }
        else
        {
            var rng = boss.RNG;
            return EnumerableExt.Random(lanes, rng);
        }
    }
    public static function FindEnemyJumpTargetPosition(boss:Entity):Vector3
    {
        var lane = FindRandomLaneWithEnemy(boss);
        return GetJumpBorderPositionByLane(boss, lane);
    }
    public static function FindRandomJumpTargetPosition(boss:Entity):Vector3
    {
        var currentLane = boss.GetLane();
        var lane = boss.RNG.Next(boss.Level.GetMaxLaneCount() - 1); // 自己的一行不算
        if (lane >= currentLane)
        {
            // 如果获取到的行数大于或等于该实体目前的行数，则目标行数+1。
            lane++;
        }
        return GetJumpBorderPositionByLane(boss, lane);
    }
    // #endregion
}

// #region 眩晕
class RedDragonStunHelper
{
    public static function Stun(dragon:Entity, seconds:Float):Void
    {
        RedDragon.stateMachine.StartState(dragon, RedDragon.STATE_STUNNED);
        var timer = RedDragon.stateMachine.GetSubStateTimer(dragon);
        timer.ResetSeconds(seconds);
        Explosion.Spawn(dragon, dragon.GetCenter(), 200);
        dragon.PlaySound(VanillaSoundID.explosion);
        dragon.PlaySound(VanillaSoundID.meteorLand);
        dragon.Level.ShakeScreen(20, 0, 30);
    }
}
private class DragonStunnedState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_STUNNED, RedDragon.ANIMATION_STATE_STUNNED);
    }
    override public function GetAnimationSubstate(substate:Int):Int
    {
        return substate;
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(2);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var timer = stateMachine.GetSubStateTimer(entity);
        timer.Run(stateMachine.GetSpeed(entity));
        switch (substate)
        {
            case SUBSTATE_START:
                // 倒地
                if (timer.PassedSecondsFromMax(5 / 6))
                {
                    entity.PlaySound(VanillaSoundID.thump);
                    entity.Level.ShakeScreen(10, 0, 15);
                }
                if (timer.Expired)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_END);
                    timer.ResetSeconds(2);
                }
            case SUBSTATE_END:
                if (timer.Expired)
                {
                    stateMachine.StartState(entity, RedDragon.STATE_IDLE);
                }
        }
    }
    override public function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        RedDragonHelpers.CheckDeath(entity);
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_END:Int = 1;
}
// #endregion

// #region 死亡
private class DragonDeathState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_DEATH, RedDragon.ANIMATION_STATE_DEATH);
    }
    override public function GetAnimationSubstate(substate:Int):Int
    {
        switch (substate)
        {
            case SUBSTATE_SPECIAL:
                return ANIMATION_SUBSTATE_END;
        }
        return ANIMATION_SUBSTATE_START;
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(2);

        entity.PlaySound(VanillaSoundID.dragonHit);
    }
    override public function OnExit(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnExit(machine, entity);
        RedDragon.SetTintMultiplier(entity, Color.white);
    }
    override public function OnUpdateLogic(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var timer = stateMachine.GetSubStateTimer(entity);
        timer.Run(stateMachine.GetSpeed(entity));
        switch (substate)
        {
            case SUBSTATE_START:
                // 倒地
                if (timer.PassedSecondsFromMax(5 / 6))
                {
                    entity.PlaySound(VanillaSoundID.thump);
                    entity.Level.ShakeScreen(10, 0, 15);
                }
                if (timer.Expired)
                {
                    if (entity.Level.AreaID == VanillaAreaID.ship && LogicLevelExt.IsFirstAdventure(entity.Level))
                    {
                        stateMachine.StartSubState(entity, SUBSTATE_SPECIAL);
                        timer.ResetSeconds(2);
                    }
                    else
                    {
                        stateMachine.StartSubState(entity, SUBSTATE_FADE);
                        timer.ResetSeconds(2);
                    }
                }
            case SUBSTATE_FADE:
                {
                    RedDragon.SetTintMultiplier(entity, Color.Lerp(Color.white, Color.black, timer.GetPassedPercentage() * 2));
                    if (timer.Expired)
                    {
                        stateMachine.StartSubState(entity, SUBSTATE_DISAPPEAR);
                        timer.ResetSeconds(1);
                    }
                }
            case SUBSTATE_DISAPPEAR:
                {
                    RedDragon.SetTintMultiplier(entity, Color.Lerp(Color.black, Color.clear, timer.GetPassedPercentage()));
                    if (timer.Expired)
                    {
                        entity.Remove();
                    }
                }
            case SUBSTATE_SPECIAL:
                {
                    if (timer.Expired)
                    {
                        stateMachine.StartState(entity, RedDragon.STATE_DEATH_ROAR);
                    }
                }
        }
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_FADE:Int = 1;
    public static inline var SUBSTATE_DISAPPEAR:Int = 2;
    public static inline var SUBSTATE_SPECIAL:Int = 3;
    public static inline var ANIMATION_SUBSTATE_START:Int = 0;
    public static inline var ANIMATION_SUBSTATE_END:Int = 1;
}
// #endregion

// #region 死亡吼叫
private class DeathRoarState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_DEATH_ROAR, RedDragon.ANIMATION_STATE_SPIT);
    }
    override public function GetAnimationSubstate(substate:Int):Int
    {
        switch (substate)
        {
            case SUBSTATE_START:
                return ANIMATION_SUBSTATE_START;
            case SUBSTATE_ROAR:
                return ANIMATION_SUBSTATE_ROAR;
            case SUBSTATE_END:
                return ANIMATION_SUBSTATE_END;
        }
        return super.GetAnimationSubstate(substate);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(1);
    }
    override public function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        var substate = RedDragon.stateMachine.GetSubState(entity);
        var timer = RedDragon.stateMachine.GetSubStateTimer(entity);
        timer.Run(RedDragon.stateMachine.GetSpeed(entity));
        switch (substate)
        {
            case SUBSTATE_START:
                if (timer.Expired)
                {
                    RedDragonHelpers.Roar(entity);
                    RedDragon.stateMachine.StartSubState(entity, SUBSTATE_ROAR);
                    timer.ResetSeconds(RedDragon.ROAR_SECONDS);
                }
            case SUBSTATE_ROAR:
                if (timer.Expired)
                {
                    RedDragon.stateMachine.StartSubState(entity, SUBSTATE_END);
                    timer.ResetSeconds(0.5);
                }
            case SUBSTATE_END:
                if (timer.Expired)
                {
                    RedDragon.stateMachine.StartState(entity, RedDragon.STATE_DEATH_FLY);
                }
        }
    }

    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_ROAR:Int = 1;
    public static inline var SUBSTATE_END:Int = 2;
    public static inline var ANIMATION_SUBSTATE_START:Int = 0;
    public static inline var ANIMATION_SUBSTATE_ROAR:Int = 1;
    public static inline var ANIMATION_SUBSTATE_END:Int = 2;
}
// #endregion

// #region 死亡飞行
private class DeathFlyState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_DEATH_FLY, RedDragon.ANIMATION_STATE_DEATH_FLY);
    }
    override public function GetAnimationSubstate(substate:Int):Int
    {
        switch (substate)
        {
            case SUBSTATE_START:
                return ANIMATION_SUBSTATE_START;
            case SUBSTATE_FLY, SUBSTATE_DAMAGED:
                return ANIMATION_SUBSTATE_FLY;
            case SUBSTATE_FALL, SUBSTATE_SMASHED:
                return ANIMATION_SUBSTATE_FALL;
        }
        return super.GetAnimationSubstate(substate);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(4 / 3);
        RedDragon.SetGravityMultiplier(entity, 0);
        RedDragon.SetGroundLimitOffset(entity, -2000);
    }
    override public function OnExit(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnExit(machine, entity);
        RedDragon.SetGravityMultiplier(entity, 1);
        RedDragon.SetGroundLimitOffset(entity, 0);
    }
    override public function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        var substate = RedDragon.stateMachine.GetSubState(entity);
        var timer = RedDragon.stateMachine.GetSubStateTimer(entity);
        timer.Run(RedDragon.stateMachine.GetSpeed(entity));
        switch (substate)
        {
            case SUBSTATE_START:
                {
                    if (timer.PassedIntervalSeconds(0.5))
                    {
                        entity.PlaySound(VanillaSoundID.dragonWings);
                    }
                    entity.Velocity = Vector3.up * 10;
                    if (timer.Expired)
                    {
                        RedDragon.stateMachine.StartSubState(entity, SUBSTATE_FLY);
                        timer.ResetSeconds(5);
                        entity.PlaySound(VanillaSoundID.dragonGrowl);
                    }
                }
            case SUBSTATE_FLY:
                {
                    if (timer.PassedIntervalSeconds(0.5))
                    {
                        entity.PlaySound(VanillaSoundID.dragonWings);
                    }
                    entity.Velocity = Vector3.up * 5;
                    if (timer.PassedIntervalSeconds(2))
                    {
                        entity.PlaySound(VanillaSoundID.dragonGrowl);
                    }
                    if (timer.Expired)
                    {
                        RedDragon.stateMachine.StartSubState(entity, SUBSTATE_DAMAGED);
                        timer.ResetSeconds(1);

                        entity.Level.ShakeScreen(10, 0, 15);
                        entity.PlaySound(VanillaSoundID.dragonHit);
                        RedDragon.SetGravityMultiplier(entity, 1);
                    }
                }
            case SUBSTATE_DAMAGED:
                if (timer.Expired)
                {
                    RedDragon.stateMachine.StartSubState(entity, SUBSTATE_FALL);
                    entity.PlaySound(VanillaSoundID.dragonEnd);
                }
            case SUBSTATE_FALL:
                if (entity.IsOnGround)
                {
                    SmashShip(entity);

                    RedDragon.stateMachine.StartSubState(entity, SUBSTATE_SMASHED);
                    timer.ResetSeconds(5);
                }
            case SUBSTATE_SMASHED:
                if (timer.Expired)
                {
                    entity.Remove();
                }
        }
    }

    private function SmashShip(entity:Entity):Void
    {
        entity.Level.ShakeScreen(30, 0, 60);
        Explosion.Spawn(entity, entity.Position, 1000);
        entity.PlaySound(VanillaSoundID.explosion);
        entity.PlaySound(VanillaSoundID.meteorLand);
        if (entity.Level.AreaID == VanillaAreaID.ship)
        {
            var areaModel = LogicLevelExt.GetAreaModelInterface(entity.Level);
            if (areaModel != null)
                areaModel.SetModelProperty("Broken", true);
            DestroyShipEntities(entity);
            DestroyShipGrids(entity);
            var endShip = entity.Spawn(VanillaEffectID.fallenEndShip, new Vector3(LevelPositions.LEVEL_WIDTH, 0, 0));
            if (endShip != null)
            {
                var velocity = endShip.Velocity;
                velocity.y = entity.Velocity.y;
                endShip.Velocity = velocity;
            }
        }
    }
    private function DestroyShipEntities(dragon:Entity):Void
    {
        for (entity in dragon.Level.FindEntities(function(e) return e.GetColumn() > 1 && EngineEntityExt.ExistsAndAlive(e)))
        {
            if (LogicEntityExt.IsVulnerableEntity(entity))
            {
                entity.Die(new DamageEffectList([VanillaDamageEffects.INSTA_KILL]), dragon);
            }
            else if (entity.IsEntityOf(VanillaEffectID.gridFire) || entity.IsEntityOf(VanillaEffectID.waterStain))
            {
                entity.Remove();
            }
        }
    }
    private function DestroyShipGrids(dragon:Entity):Void
    {
        var level = dragon.Level;
        for (x in 2...level.GetMaxColumnCount())
        {
            for (z in 0...level.GetMaxLaneCount())
            {
                var grid = level.GetGrid(x, z);
                if (grid == null)
                    continue;
                grid.RemoveBuffs(VanillaBuffID.Grid.goldenGrid);
                grid.AddBuff(VanillaBuffID.Grid.shipBrokenGrid);
            }
        }
    }

    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_FLY:Int = 1;
    public static inline var SUBSTATE_DAMAGED:Int = 2;
    public static inline var SUBSTATE_FALL:Int = 3;
    public static inline var SUBSTATE_SMASHED:Int = 4;
    public static inline var ANIMATION_SUBSTATE_START:Int = 0;
    public static inline var ANIMATION_SUBSTATE_FLY:Int = 1;
    public static inline var ANIMATION_SUBSTATE_FALL:Int = 2;
}
// #endregion

// #region 跳跃
private class DragonJumpState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_JUMP, RedDragon.ANIMATION_STATE_JUMP);
    }
    override public function GetAnimationSubstate(substate:Int):Int
    {
        switch (substate)
        {
            case SUBSTATE_START:
                return ANIMATION_SUBSTATE_START;
            case SUBSTATE_FALL:
                return ANIMATION_SUBSTATE_FALL;
            case SUBSTATE_END:
                return ANIMATION_SUBSTATE_END;
        }
        return super.GetAnimationSubstate(substate);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(1 / 6);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var timer = stateMachine.GetSubStateTimer(entity);
        timer.Run(stateMachine.GetSpeed(entity));
        switch (substate)
        {
            case SUBSTATE_START:
                if (timer.Expired)
                {
                    StartJump(entity);
                    stateMachine.StartSubState(entity, SUBSTATE_FALL);
                }
            case SUBSTATE_FALL:
                {
                    var target = RedDragon.GetJumpTarget(entity);
                    var pos = entity.Position;
                    pos.x = Ticks.SmoothDamp(pos.x, target.x, 0.2);
                    pos.z = Ticks.SmoothDamp(pos.z, target.z, 0.2);
                    entity.Position = pos;
                    if (entity.IsOnGround)
                    {
                        Land(entity);
                        stateMachine.StartSubState(entity, SUBSTATE_END);
                        timer.ResetSeconds(0.5);
                    }
                }
            case SUBSTATE_END:
                if (timer.Expired)
                {
                    var finishState = RedDragon.GetJumpFinishState(entity);
                    RedDragon.SetJumpFinishState(entity, -1);
                    if (finishState < 0)
                    {
                        finishState = RedDragon.STATE_IDLE;
                    }
                    stateMachine.StartState(entity, finishState);
                }
        }
    }
    override public function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        RedDragonHelpers.CheckDeath(entity);
    }
    private function StartJump(boss:Entity):Void
    {
        var velocity = boss.Velocity;
        velocity.y = boss.GetGravity() * Ticks.FromSeconds(jumpFlyingSeconds) / 2;
        boss.Velocity = velocity;
    }
    private function Land(entity:Entity):Void
    {
        RedDragon.LandCrush(entity);
        entity.Level.ShakeScreen(5, 0, 15);
        entity.PlaySound(VanillaSoundID.thump);
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_FALL:Int = 1;
    public static inline var SUBSTATE_END:Int = 2;
    public static inline var ANIMATION_SUBSTATE_START:Int = 0;
    public static inline var ANIMATION_SUBSTATE_FALL:Int = 1;
    public static inline var ANIMATION_SUBSTATE_END:Int = 2;

    private static inline var jumpFlyingSeconds:Float = 0.5;
}
// #endregion

// #region 喷吐火球
private class SpitState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_SPIT, RedDragon.ANIMATION_STATE_SPIT);
    }
    override public function GetAnimationSubstate(substate:Int):Int
    {
        switch (substate)
        {
            case SUBSTATE_START:
                return ANIMATION_SUBSTATE_START;
            case SUBSTATE_SPIT_1, SUBSTATE_SPIT_2, SUBSTATE_SPIT_3:
                return ANIMATION_SUBSTATE_SPIT;
            case SUBSTATE_END:
                return ANIMATION_SUBSTATE_END;
        }
        return super.GetAnimationSubstate(substate);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(1);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var timer = stateMachine.GetSubStateTimer(entity);
        timer.Run(stateMachine.GetSpeed(entity));
        switch (substate)
        {
            case SUBSTATE_START:
                if (timer.Expired)
                {
                    ShootFireball(entity);
                    stateMachine.StartSubState(entity, SUBSTATE_SPIT_1);
                    timer.ResetSeconds(0.2);
                }
            case SUBSTATE_SPIT_1:
                if (timer.Expired)
                {
                    ShootFireball(entity);
                    stateMachine.StartSubState(entity, SUBSTATE_SPIT_2);
                    timer.ResetSeconds(0.2);
                }
            case SUBSTATE_SPIT_2:
                if (timer.Expired)
                {
                    ShootFireball(entity);
                    stateMachine.StartSubState(entity, SUBSTATE_SPIT_3);
                    timer.ResetSeconds(0.2);
                }
            case SUBSTATE_SPIT_3:
                if (timer.Expired)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_END);
                    timer.ResetSeconds(0.5);
                }
            case SUBSTATE_END:
                if (timer.Expired)
                {
                    stateMachine.StartState(entity, RedDragon.STATE_IDLE);
                }
        }
    }
    override public function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        RedDragonHelpers.CheckDeath(entity);
    }

    private function ShootFireball(entity:Entity):Void
    {
        var param = entity.GetShootParams();
        param.projectileID = VanillaProjectileID.fireCharge;
        param.velocity = RedDragon.GetNeckDirection(entity) * 20;
        param.position = RedDragon.GetSpitSourcePosition(entity);
        param.soundID = VanillaSoundID.fireCharge;
        param.damage = VanillaEntityProps.GetDamage(entity) * 1;
        VanillaProjectileExt.ShootProjectile(entity, param);
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_SPIT_1:Int = 1;
    public static inline var SUBSTATE_SPIT_2:Int = 2;
    public static inline var SUBSTATE_SPIT_3:Int = 3;
    public static inline var SUBSTATE_END:Int = 4;
    public static inline var ANIMATION_SUBSTATE_START:Int = 0;
    public static inline var ANIMATION_SUBSTATE_SPIT:Int = 1;
    public static inline var ANIMATION_SUBSTATE_END:Int = 2;
}
// #endregion

// #region 扇风
private class FlapWingsState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_FLAP_WINGS, RedDragon.ANIMATION_STATE_FLAP_WINGS);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(2 / 3);
        if (RedDragon.GetPhase(entity) == RedDragon.PHASE_2)
        {
            RedDragon.SetFireInMouth(entity, true);
        }
    }
    override public function OnExit(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnExit(machine, entity);
        RedDragon.SetFireInMouth(entity, false);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var timer = stateMachine.GetSubStateTimer(entity);
        timer.Run(stateMachine.GetSpeed(entity));
        switch (substate)
        {
            case SUBSTATE_START:
                if (timer.Expired)
                {
                    entity.PlaySound(VanillaSoundID.dragonWings);
                    stateMachine.StartSubState(entity, SUBSTATE_FLAP_1);
                    timer.ResetSeconds(1);
                }
            case SUBSTATE_FLAP_1:
                if (timer.Expired)
                {
                    entity.PlaySound(VanillaSoundID.dragonWings);
                    stateMachine.StartSubState(entity, SUBSTATE_FLAP_2);
                    timer.ResetSeconds(1);
                }
            case SUBSTATE_FLAP_2:
                if (timer.Expired)
                {
                    entity.PlaySound(VanillaSoundID.dragonGrowl);
                    entity.PlaySound(VanillaSoundID.dragonWings);
                    entity.Level.ShakeScreen(10, 0, 15);
                    ShootTornado(entity);
                    RedDragon.SetFireInMouth(entity, false);
                    stateMachine.StartSubState(entity, SUBSTATE_END);
                    timer.ResetSeconds(7 / 12);
                }
            case SUBSTATE_END:
                if (timer.Expired)
                {
                    stateMachine.StartState(entity, RedDragon.STATE_IDLE);
                }
        }
    }
    override public function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        RedDragonHelpers.CheckDeath(entity);
    }

    private function ShootTornado(entity:Entity):Void
    {
        var level = entity.Level;
        var variant = Tornado.VARIANT_NORMAL;
        var speed = 2;
        var count = 1;
        var phase2 = RedDragon.GetPhase(entity) == RedDragon.PHASE_2;
        if (phase2)
        {
            variant = Tornado.VARIANT_FIRE;
            speed = 4;
        }
        else
        {
            count = VanillaDifficultyLevelProps.GetRedDragonTornadoCount(level);
        }

        var param = entity.GetSpawnParams();
        param.SetProperty(LogicEntityProps.VARIANT, variant);

        var lane = entity.GetLane();
        for (i in 0...count)
        {
            var laneOffsetLength = Std.int((i + 1) / 2);
            var laneOffsetDirection = (i % 2) * 2 - 1;
            var laneOffset = laneOffsetDirection * laneOffsetLength;
            var targetLane = lane + laneOffset;
            if (targetLane < 0 || targetLane >= level.GetMaxLaneCount())
                continue;
            var position = RedDragon.GetTornadoSourcePosition(entity);
            position.z = level.GetEntityLaneZ(targetLane);
            var tornado = entity.Spawn(VanillaEffectID.tornado, position, param);
            if (tornado != null)
            {
                tornado.Velocity = VanillaEntityExt.GetFacingDirection(entity) * speed;
                if (phase2)
                {
                    tornado.PlaySound(VanillaSoundID.refuel);
                }
            }
        }
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_FLAP_1:Int = 1;
    public static inline var SUBSTATE_FLAP_2:Int = 2;
    public static inline var SUBSTATE_END:Int = 3;
}
// #endregion

// #region 吞食
private class DragonEatState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_EAT, RedDragon.ANIMATION_STATE_EAT);
    }
    override public function GetAnimationSubstate(substate:Int):Int
    {
        switch (substate)
        {
            case SUBSTATE_SWALLOW, SUBSTATE_SWALLOW_END:
                return ANIMATION_SUBSTATE_SWALLOW;
        }
        return substate;
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(2 / 3);
        RedDragon.SetEatenEntities(entity, null);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var timer = stateMachine.GetSubStateTimer(entity);
        timer.Run(stateMachine.GetSpeed(entity));
        switch (substate)
        {
            case SUBSTATE_START:
                if (timer.Expired)
                {
                    entity.PlaySound(VanillaSoundID.fling);
                    entity.PlaySound(VanillaSoundID.bigChomp, 0.5);
                    stateMachine.StartSubState(entity, SUBSTATE_EAT);
                    timer.ResetSeconds(0.25);
                }
            case SUBSTATE_EAT:
                Eat(entity, timer.GetPassedPercentage());
                if (timer.Expired)
                {
                    var entities = RedDragon.GetEatenEntities(entity);
                    if (entities != null && entities.length > 0)
                    {
                        stateMachine.StartSubState(entity, SUBSTATE_SWALLOW);
                        timer.ResetSeconds(1);
                    }
                    else
                    {
                        stateMachine.StartSubState(entity, SUBSTATE_END);
                        timer.ResetSeconds(0.5);
                    }
                }
            case SUBSTATE_SWALLOW:
                if (timer.Expired)
                {
                    Swallow(entity);
                    RedDragon.SetEatenEntities(entity, null);
                    stateMachine.StartSubState(entity, SUBSTATE_SWALLOW_END);
                    timer.ResetSeconds(2 / 3);
                }
            case SUBSTATE_SWALLOW_END:
                if (timer.Expired)
                {
                    stateMachine.StartState(entity, RedDragon.STATE_FIRE_BREATH);
                }
            case SUBSTATE_END:
                if (timer.Expired)
                {
                    stateMachine.StartState(entity, RedDragon.STATE_FIRE_BREATH);
                }
        }
    }
    override public function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        RedDragonHelpers.CheckDeath(entity);
    }

    private function Eat(entity:Entity, time:Float):Void
    {
        var hitbox = RedDragonHelpers3.GetEatHitbox(entity, time);
        var overlapParam = OverlapParams.AnyFaction(EntityCollisionHelper.MASK_VULNERABLE);
        var targets = entity.Level.OverlapBox(hitbox.center, hitbox.size, overlapParam);
        for (collider in targets)
        {
            var target = collider.Entity;
            if (!EngineEntityExt.ExistsAndAlive(target))
                return;
            if (collider.IsForMain() && target.Type != EntityTypes.BOSS)
            {
                if (target.Type != EntityTypes.PLANT)
                {
                    LogicEntityExt.PlayDeathSound(target);
                }
                target.Die(new DamageEffectList([VanillaDamageEffects.REMOVE_ON_DEATH, VanillaDamageEffects.NO_DEATH_EFFECTS]), entity);
                EatEntity(entity, target);
            }
            else
            {
                collider.TakeDamage(VanillaEntityProps.GetDamage(entity) * RedDragon.BITE_DAMAGE_MULTIPLIER, new DamageEffectList([]), entity);
            }
        }
    }
    private function EatEntity(entity:Entity, target:Entity):Void
    {
        var entities = RedDragon.GetEatenEntities(entity);
        if (entities == null)
        {
            entities = [];
            RedDragon.SetEatenEntities(entity, entities);
        }
        entities.push(target.GetDefinitionID());
    }
    private function Swallow(entity:Entity):Void
    {
        var entities = RedDragon.GetEatenEntities(entity);
        if (entities == null)
            return;
        var eatenFlags = RedDragon.GetEatenFlags(entity);
        for (entityID in entities)
        {
            if (!NamespaceID.IsValid(entityID))
                continue;
            var entityDef = entity.Level.Content.GetEntityDefinition(entityID);
            if (entityDef == null)
                continue;
            if (entityDef.GetShellID() == VanillaShellID.flesh && VanillaEntityProps.IsUndeadOfDefinition(entityDef))
            {
                eatenFlags |= RedDragon.EATEN_FLAG_CORPSE;
            }
            if (entityDef.GetShellID() == VanillaShellID.wood)
            {
                eatenFlags |= RedDragon.EATEN_FLAG_CHARCOAL;
            }
            if (VanillaEntityProps.IsDynamiteOfDefinition(entityDef))
            {
                eatenFlags |= RedDragon.EATEN_FLAG_DYNAMITE;
            }
        }
        RedDragon.SetEatenFlags(entity, eatenFlags);
        VanillaEntityExt.HealEffects(entity, entities.length * RedDragon.EAT_HEAL_PER_ENTITY, entity);
        entity.PlaySound(VanillaSoundID.gulp, 0.5);
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_EAT:Int = 1;
    public static inline var SUBSTATE_END:Int = 2;
    public static inline var SUBSTATE_SWALLOW:Int = 3;
    public static inline var SUBSTATE_SWALLOW_END:Int = 4;
    public static inline var ANIMATION_SUBSTATE_SWALLOW:Int = 3;
}
// #endregion

class RedDragonHelpers3
{
    public static function GetEatDetectionHitbox(entity:Entity):Bounds
    {
        var size = new Vector3(RedDragon.EAT_HITBOX_WIDTH, RedDragon.EAT_HITBOX_HEIGHT, RedDragon.EAT_HITBOX_Z_LENGTH + RedDragon.EAT_HITBOX_RANGE * 2);
        var position = entity.Position + VanillaEntityExt.GetFacingDirection(entity) * RedDragon.EAT_HITBOX_DISTANCE_X;
        position.y += size.y * 0.5;
        return new Bounds(position, size);
    }
    public static function GetEatHitbox(entity:Entity, time:Float):Bounds
    {
        var size = new Vector3(RedDragon.EAT_HITBOX_WIDTH, RedDragon.EAT_HITBOX_HEIGHT, RedDragon.EAT_HITBOX_Z_LENGTH);
        var position = entity.Position + VanillaEntityExt.GetFacingDirection(entity) * RedDragon.EAT_HITBOX_DISTANCE_X;
        position.y += size.y * 0.5;
        position.z += RedDragon.EAT_HITBOX_RANGE * (1 - 2 * time);
        return new Bounds(position, size);
    }

    // #region 火焰吐息
    public static function ShouldExplodeOnBreath(entity:Entity):Bool
    {
        var eatenFlags = RedDragon.GetEatenFlags(entity);
        if ((eatenFlags & RedDragon.EATEN_FLAG_CORPSE) != 0 && (eatenFlags & RedDragon.EATEN_FLAG_CHARCOAL) != 0)
            return true;
        if ((eatenFlags & RedDragon.EATEN_FLAG_DYNAMITE) != 0)
            return true;
        return false;
    }
    public static function SelfExplode(entity:Entity):Void
    {
        RedDragon.SetEatenFlags(entity, 0);
        RedDragonStunHelper.Stun(entity, RedDragon.SELF_EXPLODE_STUN_SECONDS);
        entity.PlaySound(VanillaSoundID.dragonHit);
        var damage:Float;
        if (LogicStageProps.IsBossRevenge(entity.Level))
        {
            damage = 1800;
        }
        else
        {
            damage = entity.GetMaxHealth() * 0.5;
        }
        var damageEffects = new DamageEffectList([VanillaDamageEffects.BYPASS_BOSS_ARMOR, VanillaDamageEffects.IGNORE_ARMOR, VanillaDamageEffects.SELF_DAMAGE, VanillaDamageEffects.EXPLOSION]);
        entity.TakeDamage(damage, damageEffects, entity);
    }
    // #endregion
}

// #region 火焰吐息
private class FireBreathState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_FIRE_BREATH, RedDragon.ANIMATION_STATE_SPIT);
    }
    override public function GetAnimationSubstate(substate:Int):Int
    {
        switch (substate)
        {
            case SUBSTATE_START:
                return ANIMATION_SUBSTATE_START;
            case SUBSTATE_LOOP:
                return ANIMATION_SUBSTATE_SPIT;
            case SUBSTATE_END:
                return ANIMATION_SUBSTATE_END;
        }
        return super.GetAnimationSubstate(substate);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(1);
        RedDragon.SetFireInMouth(entity, true);
    }
    override public function OnExit(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnExit(machine, entity);
        RedDragon.SetHeadRotation(entity, 0);
        RedDragon.SetFireInMouth(entity, false);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var timer = stateMachine.GetSubStateTimer(entity);
        timer.Run(stateMachine.GetSpeed(entity));
        switch (substate)
        {
            case SUBSTATE_START:
                {
                    var headRotation = RedDragon.GetHeadRotation(entity);
                    headRotation = Ticks.SmoothDamp(headRotation, RedDragon.FIRE_BREATH_ANGLE_START, 0.2);
                    RedDragon.SetHeadRotation(entity, headRotation);
                    if (timer.Expired)
                    {
                        entity.PlaySound(VanillaSoundID.dragonGrowl);
                        if (RedDragonHelpers3.ShouldExplodeOnBreath(entity))
                        {
                            RedDragonHelpers3.SelfExplode(entity);
                        }
                        else
                        {
                            stateMachine.StartSubState(entity, SUBSTATE_LOOP);
                            timer.ResetSeconds(1.5);
                        }
                    }
                }
            case SUBSTATE_LOOP:
                {
                    RedDragon.SetHeadRotation(entity, Mathf.Lerp(RedDragon.FIRE_BREATH_ANGLE_START, RedDragon.FIRE_BREATH_ANGLE_END, timer.GetPassedPercentage()));

                    if (timer.PassedIntervalSeconds(0.2))
                    {
                        ShootFireBreath(entity);
                    }
                    if (timer.Expired)
                    {
                        stateMachine.StartSubState(entity, SUBSTATE_END);
                        timer.ResetSeconds(0.5);
                        RedDragon.SetFireInMouth(entity, false);
                    }
                }
            case SUBSTATE_END:
                {
                    var headRotation = RedDragon.GetHeadRotation(entity);
                    headRotation = Ticks.SmoothDamp(headRotation, 0, 0.2);
                    if (timer.Expired)
                    {
                        stateMachine.StartState(entity, RedDragon.STATE_IDLE);
                        headRotation = 0;
                    }
                    RedDragon.SetHeadRotation(entity, headRotation);
                }
        }
    }
    override public function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        RedDragonHelpers.CheckDeath(entity);
    }

    private function ShootFireBreath(entity:Entity):Void
    {
        var fireVariant = RedDragon.GetFireVariant(entity);
        var param = entity.GetSpawnParams();
        param.SetProperty(VanillaEntityProps.DAMAGE, VanillaEntityProps.GetDamage(entity) * RedDragon.FIRE_BREATH_DAMAGE_MULTIPLIER);
        param.SetProperty(LogicEntityProps.VARIANT, fireVariant);
        var position = RedDragon.GetSpitSourcePosition(entity) + Vector3.down * 48; // 龙息高度的一半
        var breath = entity.Spawn(VanillaEffectID.dragonFireBreath, position, param);
        if (breath != null)
        {
            breath.Velocity = RedDragon.GetNeckDirection(entity) * RedDragon.FIRE_BREATH_SPEED;
        }
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_LOOP:Int = 1;
    public static inline var SUBSTATE_END:Int = 2;
    public static inline var ANIMATION_SUBSTATE_START:Int = 0;
    public static inline var ANIMATION_SUBSTATE_SPIT:Int = 1;
    public static inline var ANIMATION_SUBSTATE_END:Int = 2;
}
// #endregion

// #region 吼叫
private class DragonRoarState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_ROAR, RedDragon.ANIMATION_STATE_SPIT);
    }
    override public function GetAnimationSubstate(substate:Int):Int
    {
        switch (substate)
        {
            case SUBSTATE_START:
                return ANIMATION_SUBSTATE_START;
            case SUBSTATE_ROAR:
                return ANIMATION_SUBSTATE_ROAR;
            case SUBSTATE_END:
                return ANIMATION_SUBSTATE_END;
            case SUBSTATE_APPEAR_START:
                return ANIMATION_SUBSTATE_APPEAR_START;
        }
        return super.GetAnimationSubstate(substate);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(1);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var timer = stateMachine.GetSubStateTimer(entity);
        timer.Run(stateMachine.GetSpeed(entity));
        switch (substate)
        {
            case SUBSTATE_START, SUBSTATE_APPEAR_START:
                if (timer.Expired)
                {
                    RedDragonHelpers.Roar(entity);
                    stateMachine.StartSubState(entity, SUBSTATE_ROAR);
                    timer.ResetSeconds(RedDragon.ROAR_SECONDS);
                }
            case SUBSTATE_ROAR:
                if (timer.Expired)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_END);
                    timer.ResetSeconds(0.5);
                }
            case SUBSTATE_END:
                if (timer.Expired)
                {
                    stateMachine.StartState(entity, RedDragon.STATE_IDLE);
                }
        }
    }
    override public function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        RedDragonHelpers.CheckDeath(entity);
    }

    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_ROAR:Int = 1;
    public static inline var SUBSTATE_END:Int = 2;
    public static inline var SUBSTATE_APPEAR_START:Int = 3;
    public static inline var ANIMATION_SUBSTATE_START:Int = 0;
    public static inline var ANIMATION_SUBSTATE_ROAR:Int = 1;
    public static inline var ANIMATION_SUBSTATE_END:Int = 2;
    public static inline var ANIMATION_SUBSTATE_APPEAR_START:Int = 3;
}
// #endregion

// #region 爆炸火球
private class LargeFireballState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_LARGE_FIREBALL, RedDragon.ANIMATION_STATE_SPIT);
    }
    override public function GetAnimationSubstate(substate:Int):Int
    {
        switch (substate)
        {
            case SUBSTATE_START:
                return ANIMATION_SUBSTATE_START;
            case SUBSTATE_CREATE:
                return ANIMATION_SUBSTATE_CREATE;
            case SUBSTATE_END:
                return ANIMATION_SUBSTATE_END;
        }
        return super.GetAnimationSubstate(substate);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(1);

        RedDragon.SetFireInMouth(entity, true);
    }
    override public function OnExit(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnExit(machine, entity);
        RedDragon.SetFireInMouth(entity, false);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var timer = stateMachine.GetSubStateTimer(entity);
        timer.Run(stateMachine.GetSpeed(entity));
        switch (substate)
        {
            case SUBSTATE_START:
                if (timer.Expired)
                {
                    CreateLargeFireball(entity);
                    entity.PlaySound(VanillaSoundID.dragonGrowl);
                    stateMachine.StartSubState(entity, SUBSTATE_CREATE);
                    timer.ResetSeconds(2);
                }
            case SUBSTATE_CREATE:
                if (timer.Expired)
                {
                    RedDragon.SetFireInMouth(entity, false);
                    stateMachine.StartSubState(entity, SUBSTATE_END);
                    timer.ResetSeconds(0.5);
                }
            case SUBSTATE_END:
                if (timer.Expired)
                {
                    stateMachine.StartState(entity, RedDragon.STATE_IDLE);
                }
        }
    }
    override public function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        RedDragonHelpers.CheckDeath(entity);
    }

    private function CreateLargeFireball(entity:Entity):Void
    {
        var level = entity.Level;
        var speed = VanillaDifficultyLevelProps.GetRedDragonGiantFireballSpeed(level);

        var param = entity.GetShootParams();
        param.projectileID = VanillaProjectileID.explosiveLargeFireball;
        param.velocity = RedDragon.GetNeckDirection(entity) * speed;
        param.position = RedDragon.GetSpitSourcePosition(entity) + Vector3.down * 20; // 离地有一定距离
        param.pivot = VanillaEntityProps.SHOT_PIVOT_BOTTOM;
        param.soundID = VanillaSoundID.dragonBreath;
        param.damage = VanillaEntityProps.GetDamage(entity) * 18;
        var p = VanillaProjectileExt.ShootProjectile(entity, param);
        if (p != null)
        {
            var triggerTime = ExplosiveLargeFireball.TRIGGER_SECONDS / speed;
            ExplosiveLargeFireball.SetTriggerTime(p, triggerTime);
        }
        entity.PlaySound(VanillaSoundID.refuel);
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_CREATE:Int = 1;
    public static inline var SUBSTATE_END:Int = 2;
    public static inline var ANIMATION_SUBSTATE_START:Int = 0;
    public static inline var ANIMATION_SUBSTATE_CREATE:Int = 1;
    public static inline var ANIMATION_SUBSTATE_END:Int = 2;
}
// #endregion

// #region 向天喷射
private class SpitUpState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_SPIT_UP, RedDragon.ANIMATION_STATE_SPIT_UP);
    }
    override public function GetAnimationSubstate(substate:Int):Int
    {
        switch (substate)
        {
            case SUBSTATE_START:
                return ANIMATION_SUBSTATE_START;
            case SUBSTATE_SPIT:
                return ANIMATION_SUBSTATE_SPIT;
            case SUBSTATE_END:
                return ANIMATION_SUBSTATE_END;
        }
        return super.GetAnimationSubstate(substate);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(1);

        RedDragon.SetFireInMouth(entity, true);
    }
    override public function OnExit(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnExit(machine, entity);
        RedDragon.SetFireInMouth(entity, false);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var timer = stateMachine.GetSubStateTimer(entity);
        timer.Run(stateMachine.GetSpeed(entity));
        switch (substate)
        {
            case SUBSTATE_START:
                if (timer.Expired)
                {
                    entity.PlaySound(VanillaSoundID.dragonGrowl);
                    stateMachine.StartSubState(entity, SUBSTATE_SPIT);
                    timer.ResetSeconds(2);


                    var buff = entity.Level.NewBuff(BeaconMeteorBuff);
                    BeaconMeteorBuff.SetFaction(buff, entity.GetFaction());
                    BeaconMeteorBuff.SetDamage(buff, VanillaEntityProps.GetDamage(entity) * RedDragon.METEOR_DAMAGE_MULTIPLIER);
                    BeaconMeteorBuff.SetCount(buff, RedDragon.METEOR_COUNT);
                    BeaconMeteorBuff.SetHSVOffset(buff, RedDragon.METEOR_HSV_OFFSET);
                    BeaconMeteorBuff.SetVariant(buff, BeaconMeteorBuff.VARIANT_BOULDER);
                    BeaconMeteorBuff.SetRNG(buff, new RandomGenerator(entity.RNG.Next()));
                    entity.Level.AddBuff(buff);
                }
            case SUBSTATE_SPIT:
                if (timer.PassedIntervalSeconds(0.2))
                {
                    ShootBreath(entity);
                }
                if (timer.Expired)
                {
                    RedDragon.SetFireInMouth(entity, false);
                    stateMachine.StartSubState(entity, SUBSTATE_END);
                    timer.ResetSeconds(0.5);
                }
            case SUBSTATE_END:
                if (timer.Expired)
                {
                    stateMachine.StartState(entity, RedDragon.STATE_IDLE);
                }
        }
    }
    override public function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        RedDragonHelpers.CheckDeath(entity);
    }

    private function ShootBreath(entity:Entity):Void
    {
        var fireVariant = RedDragon.GetFireVariant(entity);
        var param = entity.GetSpawnParams();
        param.SetProperty(VanillaEntityProps.DAMAGE, VanillaEntityProps.GetDamage(entity) * RedDragon.FIRE_BREATH_DAMAGE_MULTIPLIER);
        param.SetProperty(LogicEntityProps.VARIANT, fireVariant);
        param.SetProperty(VanillaEntityProps.MAX_TIMEOUT, 30);
        var source = RedDragon.GetNeckRootPosition(entity);
        var direction = new Vector3(VanillaEntityExt.GetFacingX(entity) * 0.3, 1, 0).normalized;
        var position = source + direction * RedDragon.NECK_LENGTH;
        var breath = entity.Spawn(VanillaEffectID.dragonFireBreath, position, param);
        if (breath != null)
        {
            breath.Velocity = direction * RedDragon.FIRE_BREATH_SPEED;
        }
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_SPIT:Int = 1;
    public static inline var SUBSTATE_END:Int = 2;
    public static inline var ANIMATION_SUBSTATE_START:Int = 0;
    public static inline var ANIMATION_SUBSTATE_SPIT:Int = 1;
    public static inline var ANIMATION_SUBSTATE_END:Int = 2;
}
// #endregion

// #region 飞行
private class DragonFlyState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_FLY, RedDragon.ANIMATION_STATE_FLY);
    }
    override public function GetAnimationSubstate(substate:Int):Int
    {
        switch (substate)
        {
            case SUBSTATE_START:
                return ANIMATION_SUBSTATE_START;
            case SUBSTATE_FLY:
                return ANIMATION_SUBSTATE_FLY;
            case SUBSTATE_GLIDE, SUBSTATE_GLIDE_BACK:
                return ANIMATION_SUBSTATE_GLIDE;
            case SUBSTATE_LAND:
                return ANIMATION_SUBSTATE_LAND;
        }
        return super.GetAnimationSubstate(substate);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(4 / 3);
        RedDragon.SetGravityMultiplier(entity, 0);
    }
    override public function OnExit(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnExit(machine, entity);
        RedDragon.SetFireInMouth(entity, false);
        RedDragon.SetRotation(entity, 0);
        RedDragon.SetGravityMultiplier(entity, 1);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var timer = stateMachine.GetSubStateTimer(entity);
        timer.Run(stateMachine.GetSpeed(entity));
        switch (substate)
        {
            case SUBSTATE_START:
                if (timer.PassedIntervalSeconds(0.5))
                {
                    entity.PlaySound(VanillaSoundID.dragonWings);
                }
                entity.Velocity = VanillaEntityExt.GetFacingDirection(entity) * -10 + Vector3.up * 5;
                if (timer.Expired)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_FLY);
                    timer.ResetSeconds(1);
                    entity.Level.ShakeScreen(10, 0, 15);
                    entity.PlaySound(VanillaSoundID.dragonGrowl);
                }
            case SUBSTATE_FLY:
                {
                    entity.Velocity = Ticks.SmoothDampVector(entity.Velocity, Vector3.zero, 0.2);
                    if (timer.PassedIntervalSeconds(0.5))
                    {
                        entity.PlaySound(VanillaSoundID.dragonWings);
                    }
                    if (timer.Expired)
                    {
                        stateMachine.StartSubState(entity, SUBSTATE_GLIDE);
                        timer.ResetSeconds(1.5); // 这个时间会影响灭火的反应时间，算上飞走和飞回的时间，算是两倍

                        var targetLane = RedDragonHelpers2.FindRandomLaneWithEnemy(entity);
                        var position = entity.Position;
                        position.z = entity.Level.GetEntityLaneZ(targetLane);
                        entity.Position = position;

                        entity.PlaySound(VanillaSoundID.fireBreathBig);
                        entity.PlaySound(VanillaSoundID.dragonGrowl);
                    }
                }
            case SUBSTATE_GLIDE:
                ShootBreath(entity);
                entity.Level.ShakeScreen(10, 0, 2);
                entity.Velocity = VanillaEntityExt.GetFacingDirection(entity) * RedDragon.FLY_SPEED;
                if (timer.Expired)
                {
                    RedDragon.SetRotation(entity, 180);
                    stateMachine.StartSubState(entity, SUBSTATE_GLIDE_BACK);
                }
            case SUBSTATE_GLIDE_BACK:
                var middleLane = Std.int(entity.Level.GetMaxLaneCount() / 2);
                var targetPosition = RedDragonHelpers2.GetJumpBorderPositionByLane(entity, middleLane);
                entity.Velocity = (targetPosition - entity.Position).normalized * RedDragon.FLY_SPEED;
                if (entity.IsOnGround)
                {
                    entity.Level.ShakeScreen(20, 0, 30);
                    entity.PlaySound(VanillaSoundID.meteorLand);
                    stateMachine.StartSubState(entity, SUBSTATE_LAND);
                    timer.ResetSeconds(1);

                    DetonateFireGrids(entity);
                }
            case SUBSTATE_LAND:
                {
                    var position = entity.Position;
                    position.x = Ticks.SmoothDamp(position.x, RedDragonHelpers2.GetJumpBorderX(entity), 0.2);
                    entity.Position = position;
                    entity.Velocity = Ticks.SmoothDampVector(entity.Velocity, Vector3.zero, 0.2);

                    RedDragon.LandCrush(entity);

                    if (timer.Expired)
                    {
                        stateMachine.StartState(entity, RedDragon.STATE_TAIL_SWIPE);
                        var swipeSubstate = TailSwipeState.GetRandomReadySubstate(entity.RNG);
                        stateMachine.StartSubState(entity, swipeSubstate);
                        RedDragon.SetRotation(entity, 180);
                    }
                }
        }
    }
    private function ShootBreath(entity:Entity):Void
    {
        var fireVariant = RedDragon.GetFireVariant(entity);
        var param = entity.GetSpawnParams();
        param.SetProperty(VanillaEntityProps.DAMAGE, VanillaEntityProps.GetDamage(entity) * RedDragon.FIRE_BREATH_DAMAGE_MULTIPLIER);
        param.SetProperty(LogicEntityProps.VARIANT, fireVariant);
        param.SetProperty(VanillaEntityProps.MAX_TIMEOUT, 30);
        var source = RedDragon.GetNeckRootPosition(entity);
        var direction = new Vector3(VanillaEntityExt.GetFacingX(entity) * 0.3, -1, 0).normalized;
        var position = source + VanillaEntityExt.GetFacingDirection(entity) * RedDragon.NECK_LENGTH;
        var breath = entity.Spawn(VanillaEffectID.dragonFireBreath, position, param);
        if (breath != null)
        {
            breath.Velocity = direction * RedDragon.FIRE_BREATH_SPEED * 5;
        }
    }
    private function DetonateFireGrids(entity:Entity):Void
    {
        var level = entity.Level;
        var radius = VanillaDifficultyLevelProps.GetRedDragonFireExplosionRadius(level);
        for (fire in level.FindEntities(function(e) return e.IsEntityOf(VanillaEffectID.gridFire) && entity.IsFriendly(entity)))
        {
            var center = fire.GetCenter();
            var damage = VanillaEntityProps.GetDamage(entity) * RedDragon.FIRE_EXPLOSION_DAMAGE_MULTIPLIER;
            var damageEffects = new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.FIRE]);
            fire.Explode(center, radius, entity.GetFaction(), damage, damageEffects);
            var explosion = Explosion.Spawn(fire, center, radius);
            if (explosion != null)
            {
                explosion.SetTint(Color.red);
            }
            entity.PlaySound(VanillaSoundID.explosion);
            entity.PlaySound(VanillaSoundID.impact);
        }
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_FLY:Int = 1;
    public static inline var SUBSTATE_GLIDE:Int = 2;
    public static inline var SUBSTATE_GLIDE_BACK:Int = 3;
    public static inline var SUBSTATE_LAND:Int = 4;
    public static inline var ANIMATION_SUBSTATE_START:Int = 0;
    public static inline var ANIMATION_SUBSTATE_FLY:Int = 1;
    public static inline var ANIMATION_SUBSTATE_GLIDE:Int = 2;
    public static inline var ANIMATION_SUBSTATE_LAND:Int = 3;
}
// #endregion

// #region 扫尾
private class TailSwipeState extends EntityStateMachineState
{
    public function new()
    {
        super(RedDragon.STATE_TAIL_SWIPE, RedDragon.ANIMATION_STATE_TAIL_SWIPE);
    }
    override public function GetAnimationSubstate(substate:Int):Int
    {
        switch (substate)
        {
            case SUBSTATE_CLOCKWISE_READY:
                return ANIMATION_SUBSTATE_CLOCKWISE_READY;
            case SUBSTATE_COUNTERCLOCKWISE_READY:
                return ANIMATION_SUBSTATE_COUNTERCLOCKWISE_READY;
            case SUBSTATE_CLOCKWISE:
                return ANIMATION_SUBSTATE_CLOCKWISE;
            case SUBSTATE_COUNTERCLOCKWISE:
                return ANIMATION_SUBSTATE_COUNTERCLOCKWISE;
        }
        return super.GetAnimationSubstate(substate);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(2 / 3);
    }
    override public function OnExit(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnExit(machine, entity);
        RedDragon.SetRotation(entity, Mathf.Repeat(RedDragon.GetRotation(entity) + 180, 360));
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substate = stateMachine.GetSubState(entity);
        var timer = stateMachine.GetSubStateTimer(entity);
        timer.Run(stateMachine.GetSpeed(entity));
        switch (substate)
        {
            case SUBSTATE_CLOCKWISE_READY:
                if (timer.Expired)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_CLOCKWISE);
                    timer.ResetSeconds(1);

                    entity.PlaySound(VanillaSoundID.fling);
                }
            case SUBSTATE_COUNTERCLOCKWISE_READY:
                if (timer.Expired)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_COUNTERCLOCKWISE);
                    timer.ResetSeconds(1);

                    entity.PlaySound(VanillaSoundID.fling);
                }
            case SUBSTATE_CLOCKWISE:
                if (timer.PassedSecondsFromMax(0.1))
                {
                    Swipe(entity, -1);
                }
                if (timer.Expired)
                {
                    stateMachine.StartState(entity, RedDragon.STATE_IDLE);
                }
            case SUBSTATE_COUNTERCLOCKWISE:
                if (timer.PassedSecondsFromMax(0.1))
                {
                    Swipe(entity, 1);
                }
                if (timer.Expired)
                {
                    stateMachine.StartState(entity, RedDragon.STATE_IDLE);
                }
        }
    }
    override public function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(machine, entity);
        RedDragonHelpers.CheckDeath(entity);
    }
    private function Swipe(entity:Entity, laneDirection:Int):Void
    {
        var level = entity.Level;
        var column = entity.GetColumn();
        var lane = entity.GetLane();
        var columnDirection = VanillaEntityExt.GetFacingX(entity);
        var column2 = column + columnDirection * RedDragon.TAIL_SWIPE_COLUMN_RANGE;
        var minColumn = Mathf.MinInt(column, column2);
        var maxColumn = Mathf.MaxInt(column, column2);
        for (x in minColumn...maxColumn)
        {
            for (z in (lane + RedDragon.TAIL_SWIPE_LANE_RANGE_START)...(lane + RedDragon.TAIL_SWIPE_LANE_RANGE_END + 1))
            {
                var grid = level.GetGrid(x, z);
                if (grid == null)
                    continue;
                for (gridEntity in grid.GetEntities())
                {
                    if (gridEntity.Type != EntityTypes.PLANT || !entity.IsHostile(gridEntity))
                        continue;
                    var targetLane = z + laneDirection;
                    var targetGrid = level.GetGrid(x, targetLane);
                    if (targetGrid == null)
                    {
                        gridEntity.Die(new DamageEffectList([VanillaDamageEffects.OUT_OF_BOUND]), entity);
                    }
                    else
                    {
                        VanillaEntityExt.StartChangingGrid(gridEntity, x, targetLane, false);
                    }
                    gridEntity.PlaySound(VanillaSoundID.punch, 0.75);
                }
            }
        }
    }
    public static function GetRandomReadySubstate(rng:RandomGenerator):Int
    {
        return rng.Next(2) == 1 ? SUBSTATE_COUNTERCLOCKWISE_READY : SUBSTATE_CLOCKWISE_READY;
    }
    public static inline var SUBSTATE_CLOCKWISE_READY:Int = 0;
    public static inline var SUBSTATE_COUNTERCLOCKWISE_READY:Int = 1;
    public static inline var SUBSTATE_CLOCKWISE:Int = 2;
    public static inline var SUBSTATE_COUNTERCLOCKWISE:Int = 3;
    public static inline var ANIMATION_SUBSTATE_CLOCKWISE_READY:Int = 0;
    public static inline var ANIMATION_SUBSTATE_COUNTERCLOCKWISE_READY:Int = 1;
    public static inline var ANIMATION_SUBSTATE_CLOCKWISE:Int = 2;
    public static inline var ANIMATION_SUBSTATE_COUNTERCLOCKWISE:Int = 3;
}
// #endregion
