// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Behaviours/ContraptionShooterBehaviour.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.detections.DispenserDetector;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.PropertyRegions;
import pvzengine.entities.Entity;
import tools.FrameTimer;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicContraptionProps;

// abstract
class ContraptionShooterBehaviour extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        detector = GetDetector();
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetShootTimer(entity, new FrameTimer(GetTimerTime(entity)));
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (!entity.IsEvoked())
        {
            Tick(entity);
        }
    }
    public function Tick(entity:Entity):Void
    {
        var shootTimer = GetShootTimer(entity);
        if (shootTimer.RunToExpiredAndNotNull(entity.GetAttackSpeed()))
        {
            var target = detector.Detect(DetectionParams.fromEntity(entity));
            if (target != null)
            {
                OnTickEnd(entity);
            }
            shootTimer.ResetTime(GetTimerTime(entity));
        }
    }
    public function OnTickEnd(entity:Entity):Void
    {
        Shoot(entity);
    }
    public function Shoot(entity:Entity):Null<Entity>
    {
        entity.TriggerAnimation("Shoot");
        return entity.ShootProjectile();
    }
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
    public static function GetShootTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_SHOOT_TIMER);
    public static function SetShootTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_SHOOT_TIMER, timer);
    public static inline var PROP_REGION:String = "contraption_shooter";
    @:propertyRegistry(PROP_REGION)
    public static var PROP_SHOOT_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("ShootTimer");
    var detector:Detector;
    static inline var ATTACK_INTERVAL_MIN:Int = 40;
    static inline var ATTACK_INTERVAL_MAX:Int = 45;
}
