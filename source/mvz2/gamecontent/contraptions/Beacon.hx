// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter5/Beacon.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.level.BeaconMeteorBuff;
import mvz2.gamecontent.detections.BeaconDetector;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.EngineEntityExt;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import tools.RandomGenerator;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicContraptionProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.beacon)
class Beacon extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        detector = new BeaconDetector();
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var shootTimer = new FrameTimer(GetTimerTime(entity));
        SetShootTimer(entity, shootTimer);
        SetEvocationTimer(entity, new FrameTimer(60));
    }

    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (!entity.IsEvoked())
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
        else
        {
            var evoTimer = GetEvocationTimer(entity);
            if (evoTimer.RunToExpiredAndNotNull())
            {
                entity.SetEvoked(false);
            }
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        var beamOn = entity.IsEvoked() && !entity.IsAIFrozen();
        entity.SetAnimationBool("BeamOn", beamOn);
        if (beamOn != entity.Level.HasLoopSoundEntity(VanillaSoundID.tractorBeam, entity.ID))
        {
            if (beamOn)
            {
                entity.Level.AddLoopSoundEntity(VanillaSoundID.tractorBeam, entity.ID);
            }
            else
            {
                entity.Level.RemoveLoopSoundEntity(VanillaSoundID.tractorBeam, entity.ID);
            }
        }
    }
    public function OnShootTick(entity:Entity):Void
    {
        var shotSpeed = entity.GetShotVelocity().magnitude;
        for (direction in shootDirections)
        {
            var dir = direction;
            dir.x *= entity.GetFacingX();
            var shootParams = entity.GetShootParams();
            shootParams.velocity = dir * shotSpeed;
            entity.ShootProjectile(shootParams);
        }
        entity.TriggerAnimation("Shoot");
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.SetEvoked(true);
        var timer = GetEvocationTimer(entity);
        if (timer != null)
            timer.Reset();


        // 转化所有敌对的陨石Buff。
        var faction = entity.GetFaction();
        for (enemyBuff in entity.Level.GetBuffs(BeaconMeteorBuff))
        {
            if (!EngineEntityExt.IsHostile(faction, BeaconMeteorBuff.GetFaction(enemyBuff)))
                continue;
            BeaconMeteorBuff.SetFaction(enemyBuff, faction);
            BeaconMeteorBuff.SetDamage(enemyBuff, entity.GetDamage() * EVOCATION_DAMAGE_MULTIPLIER);
            BeaconMeteorBuff.SetHSVOffset(enemyBuff, Vector3.zero);
            BeaconMeteorBuff.SetVariant(enemyBuff, BeaconMeteorBuff.VARIANT_DEFAULT);
        }

        // 添加陨石BUFF。
        var buff = entity.Level.NewBuff(BeaconMeteorBuff);
        BeaconMeteorBuff.SetFaction(buff, faction);
        BeaconMeteorBuff.SetDamage(buff, entity.GetDamage() * EVOCATION_DAMAGE_MULTIPLIER);
        BeaconMeteorBuff.SetCount(buff, EVOCATION_METEOR_COUNT);
        BeaconMeteorBuff.SetRNG(buff, new RandomGenerator(entity.RNG.Next()));
        entity.Level.AddBuff(buff);
    }
    public static function GetShootTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_SHOOT_TIMER);
    public static function SetShootTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_SHOOT_TIMER, timer);
    public static function GetEvocationTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_EVOCATION_TIMER);
    public static function SetEvocationTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_EVOCATION_TIMER, timer);
    function GetTimerTime(entity:Entity):Int
    {
        if (entity.Level.IsIZombie())
        {
            return ATTACK_INTERVAL_MAX;
        }
        return entity.RNG.Next(ATTACK_INTERVAL_MIN, ATTACK_INTERVAL_MAX + 1);
    }
    var detector:Detector;
    static inline var ATTACK_INTERVAL_MIN:Int = 40;
    static inline var ATTACK_INTERVAL_MAX:Int = 45;
    public static inline var EVOCATION_DAMAGE_MULTIPLIER:Float = 45;
    public static inline var EVOCATION_METEOR_COUNT:Int = 10;

    public static var shootDirections:Array<Vector3> = [
        new Vector3(-1, 0, 0), // Back
        new Vector3(0, 0, 1), // Up
        new Vector3(0, 0, -1), // Down
        new Vector3(0.866025, 0, 0.5).normalized, // Front-Up
        new Vector3(0.866025, 0, -0.5).normalized, // Front-Down
    ];
    public static var PROP_SHOOT_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("shoot_timer");
    public static var PROP_EVOCATION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("evocation_timer");
}
