// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter6/AmethystPylon.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.detections.AmethystPylonDetector;
import mvz2.gamecontent.effects.MasterSpark;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.contraptions.VanillaContraptionStates;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.EngineEntityProps;
import pvzengine.EntityID;
import pvzengine.entities.Entity;
import pvzengine.entities.EntitySourceReference;
import tools.FrameTimer;
import tools.Ticks;
import tools.TimerHelper;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.amethystPylon)
class AmethystPylon extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        detector = new AmethystPylonDetector();
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetStateTimer(entity, TimerHelper.NewSecondTimer(ATTACK_COOLDOWN_SECONDS));
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (entity.IsEvoked())
        {
            SetCrystalAlpha(entity, 1);
            var masterSparkID = GetMasterSparkID(entity);
            var masterSpark = masterSparkID != null ? masterSparkID.GetEntity(entity.Level) : null;
            if (!masterSpark.ExistsAndAlive() || MasterSpark.IsShrinking(masterSpark))
            {
                SetMasterSparkID(entity, null);
                SetCrystalAlpha(entity, 0);
                entity.SetEvoked(false);
                entity.ShortCircuit(Ticks.FromSeconds(EVOCATION_DISABLE_SECONDS), new EntitySourceReference(entity));
                entity.PlaySound(VanillaSoundID.powerOff);
            }
            else
            {
                var sourcePosition = GetLaserPosition(entity);
                masterSpark.Position = sourcePosition;
                masterSpark.SetFlipX(entity.IsFacingLeft());
                masterSpark.SetFaction(entity.GetFaction());
            }
        }
        else
        {
            switch (entity.State)
            {
                case STATE_IDLE:
                    UpdateStateIdle(entity);
                case STATE_ATTACK:
                    UpdateStateAttack(entity);
            }
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        var crystalAlpha = 0.0;
        if (!entity.IsAIFrozen())
        {
            crystalAlpha = GetCrystalAlpha(entity);
        }
        entity.SetAnimationFloat("CrystalAlpha", crystalAlpha);
        entity.SetAnimationBool("Disabled", entity.IsAIFrozen());
    }
    function UpdateStateIdle(entity:Entity):Void
    {
        var timer = GetStateTimer(entity);
        if (timer.RunToExpiredAndNotNull(entity.GetAttackSpeed()))
        {
            if (detector.DetectExists(DetectionParams.fromEntity(entity)))
            {
                entity.State = STATE_ATTACK;
                timer.ResetSeconds(ATTACK_CHARGE_SECONDS);
                entity.PlaySound(VanillaSoundID.boltCharge, 1, 0.5);
            }
            else
            {
                timer.SetSeconds(ATTACK_RECHECK_SECONDS);
            }
        }
        SetCrystalAlpha(entity, Mathf.Clamp01(GetCrystalAlpha(entity) - 0.05));
    }
    function UpdateStateAttack(entity:Entity):Void
    {
        var timer = GetStateTimer(entity);
        if (timer.RunToExpiredAndNotNull(entity.GetAttackSpeed()))
        {
            if (detector.DetectExists(DetectionParams.fromEntity(entity)))
            {
                Attack(entity);
            }
            timer.ResetSeconds(ATTACK_COOLDOWN_SECONDS);
            entity.State = STATE_IDLE;
        }
        SetCrystalAlpha(entity, Mathf.Clamp01(GetCrystalAlpha(entity) + 0.1));
    }
    public static function Attack(entity:Entity):Void
    {
        var sourcePosition = GetLaserPosition(entity);
        var laserScale = GetLaserScale(entity);
        var param = entity.GetSpawnParams();
        param.SetProperty(VanillaEntityProps.DAMAGE, entity.GetDamage());
        param.SetProperty(EngineEntityProps.FLIP_X, entity.IsFacingLeft());
        param.SetProperty(EngineEntityProps.DISPLAY_SCALE, laserScale);
        param.SetProperty(EngineEntityProps.SCALE, laserScale);

        entity.Spawn(VanillaEffectID.amethystPylonLaser, sourcePosition, param);
    }
    public static function GetLaserPosition(entity:Entity):Vector3
    {
        var laserScale = GetLaserScale(entity);
        var offset = entity.GetShotOffset();
        offset.x *= entity.GetFacingX();
        offset.y += (laserScale.y - 1) * Y_OFFSET_PER_LASER_SCALE;
        return entity.Position + offset;
    }
    public static function GetMasterSparkID(entity:Entity):Null<EntityID> return entity.GetBehaviourField(PROP_MASTER_SPARK_ID);
    public static function SetMasterSparkID(entity:Entity, timer:Null<EntityID>):Void entity.SetBehaviourField(PROP_MASTER_SPARK_ID, timer);
    public static function GetStateTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_STATE_TIMER);
    public static function SetStateTimer(entity:Entity, timer:Null<FrameTimer>):Void entity.SetBehaviourField(PROP_STATE_TIMER, timer);
    public static function GetCrystalAlpha(entity:Entity):Float return entity.GetBehaviourField(PROP_CRYSTAL_ALPHA);
    public static function SetCrystalAlpha(entity:Entity, value:Float):Void entity.SetBehaviourField(PROP_CRYSTAL_ALPHA, value);
    public static function GetLaserScale(entity:Entity):Vector3 return Mathf.Clamp(entity.GetDamage() / LASER_DAMAGE_SCALE_1, LASER_SCALE_MIN, LASER_SCALE_MAX) * Vector3.one;

    public static inline var ATTACK_COOLDOWN_SECONDS:Float = 65 / 30;
    public static inline var ATTACK_CHARGE_SECONDS:Float = 25 / 30;
    public static inline var ATTACK_RECHECK_SECONDS:Float = 7 / 30;
    public static inline var EVOCATION_DISABLE_SECONDS:Float = 30;
    public static inline var LASER_DAMAGE_SCALE_1:Float = 20;
    public static inline var LASER_SCALE_MIN:Float = 0.5;
    public static inline var LASER_SCALE_MAX:Float = 2.5;
    public static inline var Y_OFFSET_PER_LASER_SCALE:Float = -7;
    public static inline var STATE_IDLE:Int = VanillaContraptionStates.IDLE;
    public static inline var STATE_ATTACK:Int = VanillaContraptionStates.AMETHYST_PYLON_ATTACK;
    public static var PROP_MASTER_SPARK_ID:VanillaEntityPropertyMeta<EntityID> = new VanillaEntityPropertyMeta<EntityID>("master_spark_id");
    public static var PROP_STATE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("state_timer");
    public static var PROP_CRYSTAL_ALPHA:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("crystal_alpha");


    var detector:Detector;
}
