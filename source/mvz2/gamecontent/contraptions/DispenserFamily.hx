// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Common/DispenserFamily.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.detections.DispenserDetector;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import pvzengine.PropertyRegions;
import pvzengine.entities.Entity;
import tools.FrameTimer;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;

// abstract
class DispenserFamily extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        detector = GetDetector();
    }

    public function InitShootTimer(entity:Entity):Void
    {
        var shootTimer = new FrameTimer(GetTimerTime(entity));
        SetShootTimer(entity, shootTimer);
    }

    public function ShootTick(entity:Entity):Void
    {
        var shootTimer = GetShootTimer(entity);
        if (shootTimer.RunToExpiredAndNotNull(entity.GetAttackSpeed()))
        {
            var target = detector.Detect(DetectionParams.fromEntity(entity));
            if (target != null)
            {
                OnShootTick(entity);
            }
            shootTimer.ResetTime(GetTimerTime(entity));
        }
    }
    public function OnShootTick(entity:Entity):Void
    {
        Shoot(entity);
    }
    public function Shoot(entity:Entity):Null<Entity>
    {
        entity.TriggerAnimation("Shoot");
        return entity.ShootProjectile();
    }
    public static function GetShootTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_SHOOT_TIMER);
    public static function SetShootTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_SHOOT_TIMER, timer);
    function GetTimerTime(entity:Entity):Int
    {
        if (entity.Level.IsIZombie())
        {
            return ATTACK_INTERVAL_MAX;
        }
        return entity.RNG.Next(ATTACK_INTERVAL_MIN, ATTACK_INTERVAL_MAX + 1);
    }
    function GetDetector():Detector
    {
        var d = new DispenserDetector();
        d.ignoreHighEnemy = true;
        return d;
    }
    var detector:Detector;
    static inline var ATTACK_INTERVAL_MIN:Int = 40;
    static inline var ATTACK_INTERVAL_MAX:Int = 45;
    static inline var PROP_REGION:String = "dispenser_family";
    @:entityPropertyRegistry(PROP_REGION)
    public static var PROP_SHOOT_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("ShootTimer");
}
