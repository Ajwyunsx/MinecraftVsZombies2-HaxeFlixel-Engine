// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/LockedChest/LockedChest.cs
// TODO-PORT: LockedChest_States.cs (the other half of the C# `partial class LockedChest`,
// containing LockedChestStateMachine and every state class) has not been ported yet;
// `stateMachine` below therefore references a not-yet-created LockedChestStateMachine.
package mvz2.gamecontent.bosses;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.effects.Explosion;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.fragments.VanillaFragmentID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.bosses.VanillaBossStates;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.modifiers.VanillaModifierPriorities;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2.vanilla.statemachine.EntityStateMachine;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityID;
import pvzengine.entities.SpawnParams;
import pvzengine.level.LevelEngine;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;
import mvz2.gamecontent.bosses.RedDragon;
import pvzengine.entities.EngineEntityExt;
import mvz2.vanilla.effects.FragmentExt;
import pvzengine.damages.DamageEffectList;
import mvz2.gamecontent.damages.VanillaDamageEffects;

@:autoEntityBehaviourDefinition(VanillaBossNames.lockedChest)
class LockedChest extends BossBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(EngineEntityProps.FLIP_X, PROP_FLIP_X, VanillaModifierPriorities.FORCE));
        AddModifier(new FloatModifier(EngineEntityProps.GRAVITY, NumberOperator.Multiply, PROP_GRAVITY_MULTIPLIER));
        AddModifier(new Vector3Modifier(EngineEntityProps.DISPLAY_SCALE, NumberOperator.Multiply, PROP_SCALE_MULTIPLIER));
        AddModifier(new Vector3Modifier(EngineEntityProps.SCALE, NumberOperator.Multiply, PROP_SCALE_MULTIPLIER));
        AddModifier(new Vector3Modifier(LogicEntityProps.SHADOW_SCALE, NumberOperator.Multiply, PROP_SCALE_MULTIPLIER));
    }

    // #region 回调
    override public function Init(boss:Entity):Void
    {
        super.Init(boss);
        stateMachine.Init(boss);
        stateMachine.StartState(boss, STATE_IDLE);
        boss.CollisionMaskHostile |= EntityCollisionHelper.MASK_PLANT;
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

        if (GetPhase(entity) == PHASE_1 && entity.Health / entity.GetMaxHealth() < PHASE_2_THRESOLD)
        {
            RedDragonStunHelper.Stun(entity, 5);
            FragmentExt.CreateFragmentAndPlay(entity, VanillaFragmentID.furnace);
            entity.PlaySound(VanillaSoundID.chainsBreak);
            SetPhase(entity, PHASE_2);
            stateMachine.SetNextStateIndex(entity, 1);
        }


        if (entity.IsDead && stateMachine.GetStateNumber(entity) != STATE_DEATH)
        {
            stateMachine.StartState(entity, STATE_DEATH);
        }

        var phase = GetPhase(entity);
        entity.SetAnimationInt("Phase", phase);
        entity.SetModelProperty("Phase", phase);
    }
    override public function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        if (state == EntityCollisionHelper.STATE_ENTER)
        {
            var entity = collision.Entity;
            var other = collision.Other;
            if (other.IsEntityOf(VanillaContraptionID.amethystPylon) && other.GetCenter().y < entity.Position.y)
            {
                if (stateMachine.GetStateNumber(entity) == STATE_SMASH && stateMachine.GetSubState(entity) == HighJumpState.SUBSTATE_FALL)
                {
                    PrickHighJump(entity, other);
                }
            }
        }
    }
    override public function PostDeath(entity:Entity, deathInfo:DeathInfo):Void
    {
        super.PostDeath(entity, deathInfo);
        stateMachine.StartState(entity, STATE_DEATH);
    }
    // #endregion 事件


    public static function SmashAppear(level:LevelEngine, position:Vector3, spawner:Null<Entity>, param:SpawnParams):Null<Entity>
    {
        var e = level.Spawn(VanillaBossID.lockedChest, position, spawner, param);
        if (e != null)
        {
            SetNextJumpTarget(e, position);
            stateMachine.StartState(e, STATE_SMASH);
            stateMachine.StartSubState(e, HighJumpState.SUBSTATE_FALL);
        }
        return e;
    }

    public static function SpawnSmashTarget(entity:Entity, position:Vector3):Null<Entity>
    {
        var target = entity.Spawn(VanillaEffectID.aimTarget, position);
        if (target != null)
        {
            target.SetParent(entity);
        }
        SetSmashTargetID(entity, new EntityID(target));
        return target;
    }
    public static function RemoveSmashTarget(entity:Entity):Void
    {
        var id = GetSmashTargetID(entity);
        var target = id != null ? id.GetEntity(entity.Level) : null;
        if (EngineEntityExt.ExistsAndAlive(target))
        {
            target.Remove();
        }
        SetSmashTargetID(entity, null);
    }

    // PORT-NOTE: 移植自 LockedChest_States.cs 的 SetShake / PrickHighJump（所依赖的辅助函数均已存在本文件）。
    public static function SetShake(entity:Entity, value:Bool):Void
    {
        entity.SetAnimationBool("Shake", value);
    }
    public static function PrickHighJump(entity:Entity, source:Entity):Void
    {
        if (stateMachine.GetStateNumber(entity) != STATE_SMASH)
            return;
        stateMachine.StartSubState(entity, HighJumpState.SUBSTATE_PRICKED);
        entity.SetProperty(PROP_GRAVITY_MULTIPLIER, 0.0);
        var timer = stateMachine.GetSubStateTimer(entity);
        timer.ResetSeconds(1);
        SetShake(entity, true);
        SetHaveBeenPricked(entity, true);

        RemoveSmashTarget(entity);

        var pos = entity.Position;
        var vel = entity.Velocity;
        pos.y = source.GetBounds().max.y;
        vel.y = 0;
        entity.Position = pos;
        entity.Velocity = vel;

        // 伤害放最后，让死亡状态最后触发。
        entity.TakeDamage(600, new DamageEffectList([VanillaDamageEffects.SLICE]), source);
        entity.Spawn(VanillaEffectID.stabEffect, (entity.Position + source.Position) / 2);
        entity.PlaySound(VanillaSoundID.shieldHit);
        entity.PlaySound(VanillaSoundID.lockedChestOuch);
    }


    public static function ReallyDestroy(entity:Entity):Void
    {
        FragmentExt.CreateFragmentAndPlay(entity, VanillaFragmentID.woodenDropper);
        Explosion.Spawn(entity, entity.GetCenter(), 120);
        entity.PlaySound(VanillaSoundID.explosion);
        entity.Level.ShakeScreen(15, 0, 10);
        for (i in 0...20)
        {
            var rng = entity.RNG;
            var x = rng.Next(-10, 10);
            var y = rng.Next(-10, 10);
            var z = rng.Next(-10, 10);
            var vel = new Vector3(x, y, z);
            var param = entity.GetSpawnParams();
            param.SetProperty(EngineEntityProps.GRAVITY, -1);
            var soul = entity.Spawn(VanillaEffectID.soulEffect, entity.GetCenter(), param);
            if (soul != null)
            {
                soul.Velocity = vel;
            }
        }
        entity.PlaySound(VanillaSoundID.wood);
        entity.Remove();
    }

    public static function GetPhase(entity:Entity):Int
    {
        return entity.GetProperty(PROP_PHASE);
    }
    public static function SetPhase(entity:Entity, value:Int):Void
    {
        entity.SetProperty(PROP_PHASE, value);
    }
    public static function GetRevivedTimes(entity:Entity):Int
    {
        return entity.GetProperty(PROP_REVIVED_TIMES);
    }
    public static function SetRevivedTimes(entity:Entity, value:Int):Void
    {
        entity.SetProperty(PROP_REVIVED_TIMES, value);
    }
    public static function IsFlipX(entity:Entity):Bool
    {
        return entity.GetProperty(PROP_FLIP_X);
    }
    public static function SetFlipX(entity:Entity, value:Bool):Void
    {
        entity.SetProperty(PROP_FLIP_X, value);
    }
    public static function HaveBeenPricked(entity:Entity):Bool
    {
        return entity.GetProperty(PROP_HAVE_BEEN_PRICKED);
    }
    public static function SetHaveBeenPricked(entity:Entity, value:Bool):Void
    {
        entity.SetProperty(PROP_HAVE_BEEN_PRICKED, value);
    }
    public static function GetNextJumpState(entity:Entity):Int
    {
        return entity.GetProperty(PROP_NEXT_JUMP_STATE);
    }
    public static function SetNextJumpState(entity:Entity, value:Int):Void
    {
        entity.SetProperty(PROP_NEXT_JUMP_STATE, value);
    }
    public static function GetNextJumpTarget(entity:Entity):Vector3
    {
        return entity.GetProperty(PROP_NEXT_JUMP_TARGET);
    }
    public static function SetNextJumpTarget(entity:Entity, value:Vector3):Void
    {
        entity.SetProperty(PROP_NEXT_JUMP_TARGET, value);
    }
    public static function GetSmashTargetID(entity:Entity):Null<EntityID>
    {
        return entity.GetProperty(PROP_SMASH_TARGET_ID);
    }
    public static function SetSmashTargetID(entity:Entity, value:Null<EntityID>):Void
    {
        entity.SetProperty(PROP_SMASH_TARGET_ID, value);
    }
    public static function GetStateTargetID(entity:Entity):Null<EntityID>
    {
        return entity.GetProperty(PROP_STATE_TARGET_ID);
    }
    public static function SetStateTargetID(entity:Entity, value:Null<EntityID>):Void
    {
        entity.SetProperty(PROP_STATE_TARGET_ID, value);
    }
    public static function GetCoughType(entity:Entity):Int
    {
        return entity.GetProperty(PROP_COUGH_TYPE);
    }
    public static function SetCoughType(entity:Entity, value:Int):Void
    {
        entity.SetProperty(PROP_COUGH_TYPE, value);
    }
    public static function GetUsedCoughType(entity:Entity):Int
    {
        return entity.GetProperty(PROP_USED_COUGH_TYPES);
    }
    public static function SetUsedCoughType(entity:Entity, value:Int):Void
    {
        entity.SetProperty(PROP_USED_COUGH_TYPES, value);
    }
    public static function GetRemainedUltimateSmashTimes(entity:Entity):Int
    {
        return entity.GetProperty(PROP_REMAINED_ULTIMATE_SMASH_TIMES);
    }
    public static function SetRemainedUltimateSmashTimes(entity:Entity, value:Int):Void
    {
        entity.SetProperty(PROP_REMAINED_ULTIMATE_SMASH_TIMES, value);
    }
    public static function GetNextJoke(entity:Entity):Int
    {
        return entity.GetProperty(PROP_NEXT_JOKE);
    }
    public static function SetNextJoke(entity:Entity, value:Int):Void
    {
        entity.SetProperty(PROP_NEXT_JOKE, value);
    }
    public static function GetScaleMultiplier(entity:Entity):Vector3
    {
        return entity.GetProperty(PROP_SCALE_MULTIPLIER);
    }
    public static function SetScaleMultiplier(entity:Entity, value:Vector3):Void
    {
        entity.SetProperty(PROP_SCALE_MULTIPLIER, value);
    }

    public static var PROP_PHASE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("phase");
    public static var PROP_REVIVED_TIMES:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("revived_times");
    public static var PROP_COUGH_TYPE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("cough_type");
    public static var PROP_USED_COUGH_TYPES:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("used_cough_types");
    public static var PROP_NEXT_JUMP_STATE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("next_jump_state");
    public static var PROP_REMAINED_ULTIMATE_SMASH_TIMES:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("remained_ultimate_smash_times");
    public static var PROP_NEXT_JOKE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("next_joke");
    public static var PROP_FLIP_X:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("flip_x");
    public static var PROP_GRAVITY_MULTIPLIER:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("gravity_multiplier", 1);
    public static var PROP_SCALE_MULTIPLIER:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("scale_multiplier", Vector3.one);
    public static var PROP_HAVE_BEEN_PRICKED:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("have_been_pricked");
    public static var PROP_NEXT_JUMP_TARGET:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("next_jump_target");
    public static var PROP_SMASH_TARGET_ID:VanillaEntityPropertyMeta<EntityID> = new VanillaEntityPropertyMeta<EntityID>("smash_target_id");
    public static var PROP_STATE_TARGET_ID:VanillaEntityPropertyMeta<EntityID> = new VanillaEntityPropertyMeta<EntityID>("state_target_id");

    public static inline var STATE_IDLE:Int = VanillaBossStates.IDLE;
    public static inline var STATE_STUNNED:Int = VanillaBossStates.STUNNED;
    public static inline var STATE_DEATH:Int = VanillaBossStates.DEATH;

    public static inline var STATE_JUMP:Int = VanillaBossStates.LOCKED_CHEST_JUMP;
    public static inline var STATE_CHARGE:Int = VanillaBossStates.LOCKED_CHEST_CHARGE;
    public static inline var STATE_SMASH:Int = VanillaBossStates.LOCKED_CHEST_SMASH;
    public static inline var STATE_LOCK:Int = VanillaBossStates.LOCKED_CHEST_LOCK;
    public static inline var STATE_CRUSHING_LOCK:Int = VanillaBossStates.LOCKED_CHEST_CRUSH_LOCK;

    public static inline var STATE_SPIT_TRASH:Int = VanillaBossStates.LOCKED_CHEST_SPIT_TRASH;
    public static inline var STATE_COUGH:Int = VanillaBossStates.LOCKED_CHEST_COUGH;
    public static inline var STATE_SPECIAL_ATTACK:Int = VanillaBossStates.LOCKED_CHEST_SPECIAL_ATTACK;
    public static inline var STATE_RELEASE_SPECIAL_ATTACK:Int = VanillaBossStates.LOCKED_CHEST_RELEASE_SPECIAL_ATTACK;
    public static inline var STATE_CAMERA:Int = VanillaBossStates.LOCKED_CHEST_CAMERA;
    public static inline var STATE_SPIT_ZOMBIE_BLUEPRINTS:Int = VanillaBossStates.LOCKED_CHEST_SPIT_ZOMBIE_BLUEPRINTS;
    public static inline var STATE_PAY_TO_WIN:Int = VanillaBossStates.LOCKED_CHEST_PAY_TO_WIN;
    public static inline var STATE_FIVE_SMASHES:Int = VanillaBossStates.LOCKED_CHEST_FIVE_SMASHES;
    public static inline var STATE_HYPERBEAM:Int = VanillaBossStates.LOCKED_CHEST_HYPERBEAM;
    public static inline var STATE_FOUR_SOULS:Int = VanillaBossStates.LOCKED_CHEST_FOUR_SOULS;

    public static inline var STATE_BOMBARD:Int = VanillaBossStates.LOCKED_CHEST_BOMBARD;
    public static inline var STATE_SUMMON_WITHER:Int = VanillaBossStates.LOCKED_CHEST_SUMMON_WITHER;
    public static inline var STATE_GIANTIZE:Int = VanillaBossStates.LOCKED_CHEST_GIANTIZE;
    public static inline var STATE_FIREBREATH:Int = VanillaBossStates.LOCKED_CHEST_FIREBREATH;
    public static inline var STATE_TIRED:Int = VanillaBossStates.LOCKED_CHEST_TIRED;

    public static inline var ANIMATION_STATE_IDLE:Int = 0;
    public static inline var ANIMATION_STATE_STUNNED:Int = 2;
    public static inline var ANIMATION_STATE_DEATH:Int = 3;

    public static inline var ANIMATION_STATE_JUMP:Int = 10000;
    public static inline var ANIMATION_STATE_SMASH:Int = 10001;
    public static inline var ANIMATION_STATE_OPEN_CHEST:Int = 10002;


    public static inline var ANIMATION_SUBSTATE_JUMP_JUMP:Int = 0;
    public static inline var ANIMATION_SUBSTATE_JUMP_LAND:Int = 1;

    public static inline var ANIMATION_SUBSTATE_OPEN_CHEST_OPEN:Int = 0;
    public static inline var ANIMATION_SUBSTATE_OPEN_CHEST_CLOSE:Int = 1;

    public static inline var ANIMATION_SUBSTATE_SMASH_JUMP:Int = 0;
    public static inline var ANIMATION_SUBSTATE_SMASH_FALL:Int = 1;


    public static inline var MUSHROOM_ANIMATION_STATE_NONE:Int = 0;
    public static inline var MUSHROOM_ANIMATION_STATE_HOLD:Int = 1;
    public static inline var MUSHROOM_ANIMATION_STATE_EAT:Int = 2;

    public static inline var MAX_REVIVE_TIMES:Int = 3;
    public static inline var REVIVAL_HEALTH_PERCENTAGE:Float = 0.1;
    public static inline var FIRE_BREATH_DAMAGE_MULTIPLIER:Float = 0.01;
    public static inline var SPIT_TRASH_DAMAGE_MULTIPLIER:Float = 0.35;
    public static inline var EXPLOSIVE_SOUL_MULTIPLIER:Float = 1;
    public static inline var BOMBARD_DAMAGE_MULTIPLIER:Float = 18;
    public static inline var HYPERBEAM_SCALE:Float = 1;
    public static inline var LOCK_BLUEPRINT_COUNT:Int = 2;
    public static inline var ULTIMATE_SMASH_TIMES:Int = 5;
    public static inline var BOMBARD_RADIUS:Float = 200;
    public static inline var FIRE_BREATH_SPEED:Float = 20;
    public static inline var FIRE_BREATH_ANGLE_START:Float = -30;
    public static inline var FIRE_BREATH_ANGLE_END:Float = 30;

    public static inline var EMOTE_NONE:Int = 0;
    public static inline var EMOTE_QUESTION:Int = 1;
    public static inline var EMOTE_WARNING:Int = 2;
    public static inline var EMOTE_EMERALD:Int = 3;

    public static inline var JOKE_BOMBARD:Int = 0;
    public static inline var JOKE_CHOOSE_YOUR_FATE:Int = 1;
    public static inline var JOKE_SUMMON_WITHER:Int = 2;
    public static inline var JOKE_GIANTIZE:Int = 3;
    public static inline var JOKE_FIRE_BREATH:Int = 4;
    public static inline var JOKE_COUNT:Int = 5;

    public static inline var PHASE_1:Int = 0;
    public static inline var PHASE_2:Int = 1;
    public static inline var PHASE_2_THRESOLD:Float = 0.75;

    // TODO-PORT: LockedChestStateMachine / 各状态类定义于 LockedChest_States.cs，尚未移植。
    public static var stateMachine:EntityStateMachine = null;

    // PORT-NOTE: 移植自 LockedChest_States.cs 的「眩晕」区域（该区域不依赖尚未移植的状态类）。
    public static function Stun(chest:Entity, seconds:Float):Void
    {
        stateMachine.StartState(chest, STATE_STUNNED);
        var timer = stateMachine.GetStateTimer(chest);
        timer.ResetSeconds(seconds);
        chest.PlaySound(VanillaSoundID.stunned);
    }
}

// TODO-PORT: C# LockedChest_States.cs 的 HighJumpState（状态类）尚未移植，
// 这里按 C# 原值保留已被 LockedChest.hx 引用的子状态常量。
//   public const int SUBSTATE_SHAKE = 0;
//   public const int SUBSTATE_JUMP = 1;
//   public const int SUBSTATE_FALL = 2;
//   public const int SUBSTATE_END = 3;
class HighJumpState
{
    public static inline var SUBSTATE_SHAKE:Int = 0;
    public static inline var SUBSTATE_JUMP:Int = 1;
    public static inline var SUBSTATE_FALL:Int = 2;
    public static inline var SUBSTATE_END:Int = 3;
    public static inline var SUBSTATE_PRICKED:Int = 4;
}
