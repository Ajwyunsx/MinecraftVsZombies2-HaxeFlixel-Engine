// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Common/CatapultBehaviour.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.detections.CatapultDetector;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.ShootParams;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EntityID;
import pvzengine.PropertyRegions;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import tools.FrameTimer;
import tools.Ticks;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;

// abstract
class CatapultBehaviour extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        detector = GetDetector();
    }

    public function CatapultUpdate(entity:Entity):Void
    {
        var state = GetCatapultState(entity);
        switch (state)
        {
            case CATAPULT_STATE_IDLE:
                IdleUpdate(entity);
            case CATAPULT_STATE_ATTACK:
                AttackUpdate(entity);
            case CATAPULT_STATE_THROWN:
                ThrownUpdate(entity);
        }
    }
    public function UpdateAnimation(entity:Entity):Void
    {
        entity.SetAnimationInt("ThrowState", GetAnimationThrowState(entity));
        entity.SetAnimationFloat("AttackSpeed", entity.IsAIFrozen() ? 0 : entity.GetAttackSpeed());
    }
    public function IdleUpdate(entity:Entity):Void
    {
        var timer = GetStateTimer(entity);
        if (timer == null)
        {
            timer = new FrameTimer(GetAttackInterval(entity));
            SetStateTimer(entity, timer);
        }
        if (timer.RunToExpired(entity.GetAttackSpeed()))
        {
            var target = detector.DetectEntityWithTheLeast(DetectionParams.fromEntity(entity), e -> GetTargetPriority(e, entity));
            if (target != null)
            {
                SetCatapultState(entity, CATAPULT_STATE_ATTACK);
                SetThrowTarget(entity, new EntityID(target));
                timer.ResetTime(GetThrowTime(entity));
                OnIdleTimeout(entity);
            }
            else
            {
                timer.ResetTime(GetAttackInterval(entity));
            }
        }
    }
    public function AttackUpdate(entity:Entity):Void
    {
        var timer = GetStateTimer(entity);
        if (timer == null)
        {
            timer = new FrameTimer(GetThrowTime(entity));
            SetStateTimer(entity, timer);
        }
        if (timer.RunToExpired(entity.GetAttackSpeed()))
        {
            SetCatapultState(entity, CATAPULT_STATE_THROWN);
            timer.ResetTime(GetRestoreTime(entity));
            OnAttackTimeout(entity);
        }
    }
    public function ThrownUpdate(entity:Entity):Void
    {
        var timer = GetStateTimer(entity);
        if (timer == null)
        {
            timer = new FrameTimer(GetRestoreTime(entity));
            SetStateTimer(entity, timer);
        }
        if (timer.RunToExpired(entity.GetAttackSpeed()))
        {
            SetCatapultState(entity, CATAPULT_STATE_IDLE);
            timer.ResetTime(GetAttackInterval(entity));
            OnThrownTimeout(entity);
        }
    }
    public function OnIdleTimeout(entity:Entity):Void
    {
    }
    public function OnAttackTimeout(entity:Entity):Void
    {
        ThrowProjectile(entity);
    }
    public function OnThrownTimeout(entity:Entity):Void
    {
    }
    public function ThrowProjectile(entity:Entity):Null<Entity>
    {
        var param = entity.GetShootParams();
        // PORT-NOTE: C# 的 ref 参数改为将返回值重新赋回 param。
        param = PreModifyShootParameters(entity, param);
        var throwTargetID = GetThrowTarget(entity);
        var throwTarget = throwTargetID != null ? throwTargetID.GetEntity(entity.Level) : null;
        var flyTime = Ticks.FromSeconds(PROJECTILE_FLY_TIME_SECONDS);
        var targetPosition:Vector3;
        if (throwTarget != null && throwTarget.ExistsAndAlive())
        {
            var bounds = throwTarget.GetBounds();
            targetPosition = bounds.center;
            targetPosition.y = bounds.max.y;
            targetPosition += throwTarget.Velocity * flyTime;

            var limitsX = GetLimitTargetPositionX(entity);
            var limitsZ = GetLimitTargetPositionZ(entity);
            targetPosition.x = Mathf.Clamp(targetPosition.x, limitsX.min, limitsX.max);
            targetPosition.z = Mathf.Clamp(targetPosition.z, limitsZ.min, limitsZ.max);
        }
        else
        {
            var level = entity.Level;
            var lane = entity.GetLane();
            var x = level.GetEntityColumnX(level.GetMaxColumnCount() - 1);
            var z = level.GetEntityLaneZ(lane);
            var y = level.GetGroundY(x, z);
            targetPosition = new Vector3(x, y, z);
        }
        var projectileId = param.projectileID;
        var projectileDefinition = entity.Level.Content.GetEntityDefinition(projectileId);
        var gravity = projectileDefinition != null ? projectileDefinition.GetGravity() : 1;
        param.velocity = VanillaProjectileExt.GetLobVelocityByTime(param.position, targetPosition, flyTime, gravity);
        param = PostModifyShootParameters(entity, param);
        return entity.ShootProjectile(param);
    }
    public function GetTargetPriority(target:Entity, entity:Entity):Float
    {
        var priority = (target.GetCenter().x - entity.GetCenter().x) * entity.GetFacingX();
        if (target.Type == EntityTypes.OBSTACLE)
        {
            priority += 100000;
        }
        return priority;
    }
    // PORT-NOTE: C# 的 out 参数改为返回匿名结构 { min, max }。
    public function GetLimitTargetPositionX(entity:Entity):{min:Float, max:Float}
    {
        if (entity.IsFacingLeft())
        {
            return {min: entity.Position.x - entity.GetRange(), max: entity.Position.x};
        }
        else
        {
            return {min: entity.Position.x, max: entity.Position.x + entity.GetRange()};
        }
    }
    // PORT-NOTE: C# 的 out 参数改为返回匿名结构 { min, max }。
    public function GetLimitTargetPositionZ(entity:Entity):{min:Float, max:Float}
    {
        return {min: entity.Position.z - 20, max: entity.Position.z + 20};
    }
    // PORT-NOTE: C# 的 ref 参数改为传入并返回 ShootParams。
    function PreModifyShootParameters(entity:Entity, param:ShootParams):ShootParams
    {
        return param;
    }
    // PORT-NOTE: C# 的 ref 参数改为传入并返回 ShootParams。
    function PostModifyShootParameters(entity:Entity, param:ShootParams):ShootParams
    {
        return param;
    }
    function GetAnimationThrowState(entity:Entity):Int
    {
        var state = GetCatapultState(entity);
        switch (state)
        {
            case CATAPULT_STATE_ATTACK, CATAPULT_STATE_THROWN:
                return ANIMATION_THROW_STATE_ATTACK;
            default:
                return ANIMATION_THROW_STATE_IDLE;
        }
    }
    function GetAttackInterval(entity:Entity):Int
    {
        var frames = AttackIntervalMax;
        if (!entity.Level.IsIZombie())
        {
            frames = entity.RNG.Next(AttackIntervalMin, AttackIntervalMax);
        }
        return frames;
    }
    function GetThrowTime(entity:Entity):Int
    {
        return Ticks.FromSeconds(0.25);
    }
    function GetRestoreTime(entity:Entity):Int
    {
        return Ticks.FromSeconds(0.75);
    }
    function GetDetector():Detector
    {
        return new CatapultDetector();
    }
    public static function GetCatapultState(entity:Entity):Int return entity.GetProperty(PROP_CATAPULT_STATE);
    public static function SetCatapultState(entity:Entity, value:Int):Void entity.SetProperty(PROP_CATAPULT_STATE, value);
    public static function GetStateTimer(entity:Entity):Null<FrameTimer> return entity.GetProperty(PROP_STATE_TIMER);
    public static function SetStateTimer(entity:Entity, value:Null<FrameTimer>):Void entity.SetProperty(PROP_STATE_TIMER, value);
    public static function GetThrowTarget(entity:Entity):Null<EntityID> return entity.GetProperty(PROP_THROW_TARGET);
    public static function SetThrowTarget(entity:Entity, value:Null<EntityID>):Void entity.SetProperty(PROP_THROW_TARGET, value);
    public var AttackIntervalMin(get, never):Int;
    public var AttackIntervalMax(get, never):Int;
    public static inline var CATAPULT_STATE_IDLE:Int = 0;
    public static inline var CATAPULT_STATE_ATTACK:Int = 1;
    public static inline var CATAPULT_STATE_THROWN:Int = 2;
    public static inline var ANIMATION_THROW_STATE_IDLE:Int = 0;
    public static inline var ANIMATION_THROW_STATE_ATTACK:Int = 1;
    public static inline var PROJECTILE_FLY_TIME_SECONDS:Float = 1;
    var detector:Detector;
    static inline var PROP_REGION:String = "catapult";
    @:entityPropertyRegistry(PROP_REGION)
    public static var PROP_STATE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("state_timer");
    @:entityPropertyRegistry(PROP_REGION)
    public static var PROP_CATAPULT_STATE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("catapult_state");
    @:entityPropertyRegistry(PROP_REGION)
    public static var PROP_THROW_TARGET:VanillaEntityPropertyMeta<EntityID> = new VanillaEntityPropertyMeta<EntityID>("throw_target");

    // C#: public virtual int AttackIntervalMin { get; } = Ticks.FromSeconds(1.666667f);
    function get_AttackIntervalMin():Int return Ticks.FromSeconds(1.666667);
    // C#: public virtual int AttackIntervalMax { get; } = Ticks.FromSeconds(2f);
    function get_AttackIntervalMax():Int return Ticks.FromSeconds(2);
}
