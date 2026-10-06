// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter3/SpikesBehaviour.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.SpikeBlockDetector;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.IDestroyBySpikesEntityBehaviour;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.PropertyRegions;
import pvzengine.collisions.IEntityCollider;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import tools.FrameTimer;
import unity.Vector3;
using mvz2logic.entities.LogicContraptionProps;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

// abstract
class SpikesBehaviour extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        detector = new SpikeBlockDetector();
        detectorEvoked = new SpikeBlockDetector(true);
        cast(detectorEvoked, SpikeBlockDetector).canDetectInvisible = true;
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var attackTimer = new FrameTimer(AttackCooldown);
        attackTimer.Frame = 1; // 为了让尖刺能够在放下之后立即扎车
        SetAttackTimer(entity, attackTimer);
        SetEvocationTimer(entity, new FrameTimer(EvocationDuration));
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (!entity.IsEvoked())
        {
            var timer = GetAttackTimer(entity);
            if (timer.RunToExpiredAndNotNull(entity.GetAttackSpeed()) && entity.IsTimeInterval(DetectInterval))
            {
                detectBuffer = [];
                detector.DetectMultiple(DetectionParams.fromEntity(entity), detectBuffer);
                var damaged = false;
                if (detectBuffer.length > 0)
                {
                    for (target in detectBuffer)
                    {
                        target.TakeDamage(entity.GetDamage(), new DamageEffectList([VanillaDamageEffects.GROUND_SPIKES]), entity);
                        if (target.TryDestroyBySpikes(entity))
                        {
                            // C#: entity.TakeDamage(...)?.Let(o => { ... })
                            var o = entity.TakeDamage(entity.GetTakenCrushDamage(), new DamageEffectList([VanillaDamageEffects.GRIND]), target.Entity);
                            if (o != null)
                            {
                                if (o.BodyResult != null && o.BodyResult.Fatal)
                                {
                                    entity.PlaySound(VanillaSoundID.smash);
                                }
                            }
                        }
                    }
                    entity.TriggerAnimation("Attack");
                    damaged = true;
                }
                if (damaged)
                {
                    timer.Reset();
                }
            }
        }
        else
        {
            detectBuffer = [];
            detectorEvoked.DetectMultiple(DetectionParams.fromEntity(entity), detectBuffer);

            // 造成伤害
            var attackTimer = GetAttackTimer(entity);
            if (attackTimer.RunToExpiredAndNotNull(entity.GetAttackSpeed()))
            {
                attackTimer.Reset();
                for (target in detectBuffer)
                {
                    target.TakeDamage(entity.GetDamage(), new DamageEffectList([VanillaDamageEffects.GROUND_SPIKES]), entity);
                }
                entity.TriggerAnimation("Attack");
            }
            // 拉近敌人
            for (target in detectBuffer)
            {
                var targetEnt = target.Entity;
                if (targetEnt.Type == EntityTypes.ENEMY)
                {
                    targetEnt.Position += (entity.Position - targetEnt.Position).normalized * PULL_SPEED;
                }
            }
            // 产生特效
            var rng = entity.RNG;
            var level = entity.Level;
            var z = entity.Position.z;
            var padding = level.GetGridWidth() * 0.25;
            var minX = level.GetGridLeftX() + padding;
            var maxX = level.GetGridRightX() - padding;
            for (i in 0...5)
            {
                var x = rng.Next(minX, maxX);
                var y = level.GetGroundY(x, z);
                var pos = new Vector3(x, y, z);
                entity.Spawn(SpikeParticleID, pos);
            }
            // 结束
            var evocationTimer = GetEvocationTimer(entity);
            if (evocationTimer.RunToExpiredAndNotNull())
            {
                if (attackTimer != null)
                    attackTimer.ResetTime(AttackCooldown);
                entity.SetEvoked(false);
            }
        }
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.SetEvoked(true);
        var evocationTimer = GetEvocationTimer(entity);
        if (evocationTimer != null)
            evocationTimer.ResetTime(EvocationDuration);
        var attackTimer = GetAttackTimer(entity);
        if (attackTimer != null)
            attackTimer.ResetTime(EvocationAttackCooldown);
    }
    public static function GetAttackTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_ATTACK_TIMER);
    public static function SetAttackTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_ATTACK_TIMER, timer);
    public static function GetEvocationTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_EVOCATION_TIMER);
    public static function SetEvocationTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_EVOCATION_TIMER, timer);
    public static inline var PULL_SPEED:Float = 10;
    static inline var PROP_REGION:String = "spikes_behaviour";
    @:entityPropertyRegistry(PROP_REGION)
    public static var PROP_ATTACK_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("AttackTimer");
    @:entityPropertyRegistry(PROP_REGION)
    public static var PROP_EVOCATION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("EvocationTimer");
    @:entityPropertyRegistry(PROP_REGION)
    public static var PROP_EVOCATION_ATTACK_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("EvocationAttackTimer");
    public var AttackCooldown(get, never):Int;
    public var EvocationDuration(get, never):Int;
    public var EvocationAttackCooldown(get, never):Int;
    public var DetectInterval(get, never):Int;
    public var SpikeParticleID(get, never):NamespaceID;
    function get_AttackCooldown():Int return 30;
    function get_EvocationDuration():Int return 120;
    function get_EvocationAttackCooldown():Int return 4;
    function get_DetectInterval():Int return 4;
    function get_SpikeParticleID():NamespaceID return VanillaEffectID.spikeParticles;
    var detector:Detector;
    var detectorEvoked:Detector;
    var detectBuffer:Array<IEntityCollider> = [];
}
