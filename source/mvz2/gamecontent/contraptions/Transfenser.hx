// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter6/Transfenser.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.TransfenserLaserDetector;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.contraptions.VanillaContraptionStates;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntitySourceReference;
import tools.FrameTimer;
import tools.Ticks;
import tools.TimerHelper;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;
import pvzengine.Ticks;
import mvz2.gamecontent.contraptions.DispenserFamily;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.transfenser)
class Transfenser extends DispenserFamily
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        InitShootTimer(entity);
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (entity.IsEvoked())
        {
            EvokedUpdate(entity);
        }
        else
        {
            if (IsShooterMode(entity))
            {
                ShootTick(entity);
            }
            else if (IsAimerMode(entity))
            {
                AimerUpdate(entity);
            }
            else if (IsTransforming(entity))
            {
                UpdateTransforming(entity);
            }
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        if (IsAimerMode(entity))
        {
            UpdateAimerAnimation(entity);
        }
        entity.SetAnimationBool("LaserActive", IsAimerMode(entity) && !entity.IsAIFrozen());
        entity.SetAnimationInt("TransformState", GetAnimationTransformState(entity));
        entity.SetAnimationFloat("TransformSpeed", entity.IsAIFrozen() ? 0 : 1);
    }
    override function GetTimerTime(entity:Entity):Int
    {
        if (entity.Level.IsIZombie())
        {
            return ATTACK_INTERVAL_MAX;
        }
        return entity.RNG.Next(ATTACK_INTERVAL_MIN, ATTACK_INTERVAL_MAX + 1);
    }
    function AimerUpdate(entity:Entity):Void
    {
        if (entity.IsTimeInterval(LASER_EFFECT_INTERVAL))
        {
            laserTargetBuffer = [];
            laserDetector.DetectEntities(DetectionParams.fromEntity(entity), laserTargetBuffer);
            var damage = entity.GetDamage() * LASER_EFFECT_INTERVAL * LASER_DPS_MULTIPLIER / Ticks.GetTPS();
            var effects = new DamageEffectList([VanillaDamageEffects.LIGHT, VanillaDamageEffects.MUTE]);
            for (target in laserTargetBuffer)
            {
                target.InflictGlowing(LASER_EFFECT_INTERVAL + 1, new EntitySourceReference(entity));
                target.TakeDamage(damage, effects, entity);
            }
        }
    }

    //region 触发
    public override function CanTrigger(entity:Entity):Bool
    {
        if (Transfenser.IsTransforming(entity) || entity.IsEvoked())
        {
            return false;
        }
        return super.CanTrigger(entity);
    }
    public override function Trigger(entity:Entity):Void
    {
        super.Trigger(entity);
        Transfenser.StartTransforming(entity);
        entity.PlaySound(VanillaSoundID.mechSetup);
    }
    //endregion

    //region 激发
    public override function CanEvoke(entity:Entity):Bool
    {
        if (Transfenser.IsTransforming(entity))
        {
            return false;
        }
        return super.CanEvoke(entity);
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        if (IsAimerMode(entity))
        {
            var offset = LASER_SHOOT_OFFSET;
            offset.x *= entity.GetFacingX();
            var sourcePosition = entity.Position + offset;

            var laserID = VanillaEffectID.megaGlowingLaser;
            var param = entity.GetSpawnParams();
            param.SetProperty(VanillaEntityProps.DAMAGE, entity.GetDamage() * EVOCATION_LASER_DAMAGE_MULTIPLIER);
            entity.Spawn(laserID, sourcePosition, param);
        }
        else if (IsShooterMode(entity))
        {
            var evocationTimer = GetEvocationTimer(entity);
            if (evocationTimer != null)
                evocationTimer.Reset();
            entity.SetEvoked(true);
        }
    }
    function EvokedUpdate(entity:Entity):Void
    {
        var evocationTimer = GetEvocationTimer(entity);
        if (evocationTimer == null)
        {
            evocationTimer = TimerHelper.NewSecondTimer(EVOCATION_DURATION_SECONDS);
            SetEvocationTimer(entity, evocationTimer);
        }
        evocationTimer.Run();
        if (evocationTimer.PassedInterval(2))
        {
            var projectile = Shoot(entity);
            if (projectile != null)
                projectile.Velocity *= 2;
        }
        if (evocationTimer.Expired)
        {
            entity.SetEvoked(false);
            var shootTimer = DispenserFamily.GetShootTimer(entity);
            if (shootTimer != null)
                shootTimer.Reset();
        }
    }
    //endregion

    //region 变形
    function UpdateTransforming(entity:Entity):Void
    {
        var timer = GetTransformTimer(entity);
        if (timer == null)
        {
            timer = TimerHelper.NewSecondTimer(TRANSFORM_TIME_SECONDS);
            SetTransformTimer(entity, timer);
        }
        if (timer.RunToExpired())
        {
            EndTransforming(entity);
        }
    }
    public static function StartTransforming(entity:Entity):Void
    {
        if (entity.State == STATE_SHOOTER)
        {
            entity.State = STATE_TO_AIMER;
        }
        else
        {
            entity.State = STATE_TO_SHOOTER;
        }
        var timer = GetTransformTimer(entity);
        if (timer != null)
            timer.Reset();
    }
    function EndTransforming(entity:Entity):Void
    {
        if (entity.State == STATE_TO_AIMER)
        {
            entity.State = STATE_AIMER;
            UpdateAimerAnimation(entity);
        }
        else
        {
            entity.State = STATE_SHOOTER;
        }
    }
    //endregion

    //region 模式判断
    public static function IsShooterMode(entity:Entity):Bool
    {
        return entity.State == STATE_SHOOTER;
    }
    public static function IsAimerMode(entity:Entity):Bool
    {
        return entity.State == STATE_AIMER;
    }
    public static function IsTransforming(entity:Entity):Bool
    {
        return entity.State == STATE_TO_AIMER || entity.State == STATE_TO_SHOOTER;
    }
    //endregion

    //region 动画器
    function UpdateAimerAnimation(entity:Entity):Void
    {
        entity.SetAnimationFloat("LaserLength", MAX_LASER_RANGE);
    }
    public static function GetAnimationTransformState(entity:Entity):Int
    {
        switch (entity.State)
        {
            case STATE_TO_AIMER:
                return TRANSFORM_STATE_TO_AIMER;
            case STATE_AIMER:
                return TRANSFORM_STATE_AIMER;
            case STATE_TO_SHOOTER:
                return TRANSFORM_STATE_TO_SHOOTER;
        }
        return TRANSFORM_STATE_SHOOTER;
    }
    //endregion

    //region 属性
    public static function GetTransformTimer(entity:Entity):Null<FrameTimer>
    {
        return entity.GetProperty(PROP_TRANSFORM_TIMER);
    }
    public static function SetTransformTimer(entity:Entity, value:Null<FrameTimer>):Void
    {
        entity.SetProperty(PROP_TRANSFORM_TIMER, value);
    }
    public static function GetEvocationTimer(entity:Entity):Null<FrameTimer> return entity.GetProperty(PROP_EVOCATION_TIMER);
    public static function SetEvocationTimer(entity:Entity, timer:FrameTimer):Void entity.SetProperty(PROP_EVOCATION_TIMER, timer);
    //endregion

    public static var PROP_EVOCATION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("evocation_timer");
    public static var PROP_TRANSFORM_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("transform_timer");

    public static var LASER_SHOOT_OFFSET:Vector3 = new Vector3(12, 40, 0);
    public static var laserDetector:Detector = makeLaserDetector();

    static function makeLaserDetector():Detector
    {
        var d:Detector = new TransfenserLaserDetector(LASER_SHOOT_OFFSET, MAX_LASER_RANGE);
        cast(d, TransfenserLaserDetector).canDetectInvisible = true;
        return d;
    }

    public static inline var ATTACK_INTERVAL_MIN:Int = 40;
    public static inline var ATTACK_INTERVAL_MAX:Int = 45;
    public static inline var MAX_LASER_RANGE:Int = 2000;
    public static inline var LASER_EFFECT_INTERVAL:Int = 3;
    public static inline var LASER_DPS_MULTIPLIER:Float = 0.25;
    public static inline var TRANSFORM_TIME_SECONDS:Float = 1;
    public static inline var EVOCATION_DURATION_SECONDS:Float = 4;
    public static inline var EVOCATION_LASER_DAMAGE_MULTIPLIER:Float = 10;

    public static inline var STATE_SHOOTER:Int = VanillaContraptionStates.IDLE;
    public static inline var STATE_TO_AIMER:Int = VanillaContraptionStates.TRANSFENSER_TO_AIMER;
    public static inline var STATE_AIMER:Int = VanillaContraptionStates.TRANSFENSER_AIMER;
    public static inline var STATE_TO_SHOOTER:Int = VanillaContraptionStates.TRANSFENSER_TO_SHOOTER;

    public static inline var TRANSFORM_STATE_SHOOTER:Int = 0;
    public static inline var TRANSFORM_STATE_TO_AIMER:Int = 1;
    public static inline var TRANSFORM_STATE_AIMER:Int = 2;
    public static inline var TRANSFORM_STATE_TO_SHOOTER:Int = 3;

    static var laserTargetBuffer:Array<Entity> = [];
}
