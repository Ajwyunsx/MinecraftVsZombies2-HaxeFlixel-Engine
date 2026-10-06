// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter3/TeslaCoil.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.TeslaCoilDetector;
import mvz2.gamecontent.effects.ElectricArc;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.contraptions.VanillaContraptionStates;
import mvz2.vanilla.detection.Detection;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.collisions.IEntityCollider;
import pvzengine.collisions.OverlapParams;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.grids.LawnGrid;
import tools.FrameTimer;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.teslaCoil)
class TeslaCoil extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        detector = new TeslaCoilDetector(ATTACK_HEIGHT);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetAttackTimer(entity, new FrameTimer(ATTACK_COOLDOWN));
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.PlaySound(VanillaSoundID.lightningAttack);
        var pos = entity.Position;
        pos.y += 240;
        entity.SpawnWithParams(VanillaEffectID.thunderCloud, pos);
        CreateArc(entity, entity.Position + ARC_OFFSET, pos);
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (entity.State == STATE_IDLE)
        {
            var timer = GetAttackTimer(entity);
            if (timer != null && timer.RunToExpired(entity.GetAttackSpeed()))
            {
                if (detector.DetectExists(DetectionParams.fromEntity(entity)))
                {
                    entity.State = STATE_ATTACK;
                    timer.ResetTime(ATTACK_CHARGE);
                    entity.PlaySound(VanillaSoundID.teslaPower);
                }
                else
                {
                    timer.Frame = 7;
                }
            }
        }
        else if (entity.State == STATE_ATTACK)
        {
            var timer = GetAttackTimer(entity);
            if (timer != null && timer.RunToExpired(entity.GetAttackSpeed()))
            {
                var target = detector.DetectEntityWithTheMost(DetectionParams.fromEntity(entity), t -> GetTargetPriority(entity, t));
                if (target != null)
                {
                    var faction = entity.GetFaction();
                    var damage = entity.GetDamage();
                    var sourcePosition = entity.Position + ARC_OFFSET;
                    var targetPosition = target.Position;
                    var groundY = entity.Level.GetGroundY(targetPosition.x, targetPosition.z);
                    if (targetPosition.y <= groundY)
                    {
                        targetPosition.y = groundY;
                    }
                    Shock(entity, damage, faction, SHOCK_RADIUS, targetPosition);
                    CreateArc(entity, sourcePosition, targetPosition);
                    entity.PlaySound(VanillaSoundID.teslaAttack);
                }
                timer.ResetTime(ATTACK_COOLDOWN);
                entity.State = STATE_IDLE;
            }
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetAnimationBool("Attacking", entity.State == STATE_ATTACK);
        entity.SetAnimationBool("ShowArc", entity.State != STATE_ATTACK && !entity.IsAIFrozen());
        entity.SetAnimationFloat("AttackSpeed", entity.GetAttackSpeed());
    }
    function GetTargetPriority(self:Entity, target:Entity):Float
    {
        var target2Self = target.Position - self.Position;
        target2Self.y = 0;
        var distance = target2Self.magnitude;
        var priority = -distance;
        if (target.Position.y > self.Position.y + 40)
        {
            priority += 300;
        }
        return priority;
    }
    public static function Shock(source:Entity, damage:Float, faction:Int, shockRadius:Float, targetPosition:Vector3, ?damageEffects:DamageEffectList):Void
    {
        damageEffects = damageEffects != null ? damageEffects : new DamageEffectList([VanillaDamageEffects.LIGHTNING, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN, VanillaDamageEffects.MUTE]);
        var level = source.Level;
        detectBuffer = [];
        gridDetectBuffer.clear();
        var overlapParam = OverlapParams.Hostile(faction, EntityCollisionHelper.MASK_VULNERABLE);
        level.OverlapSphereNonAlloc(targetPosition, shockRadius, overlapParam, detectBuffer);
        if (targetPosition.y <= level.GetGroundY(targetPosition.x, targetPosition.z) && level.IsConductiveAt(targetPosition.x, targetPosition.z))
        {
            level.GetConnectedConductiveGrids(targetPosition, 1, 1, gridDetectBuffer);
            for (grid in gridDetectBuffer.keys())
            {
                var column = grid.Column;
                var lane = grid.Lane;
                Detection.OverlapGridGroundNonAlloc(level, column, lane, overlapParam, detectBuffer);
                var x = level.GetColumnCenterX(column);
                var z = level.GetLaneCenterZ(lane);
                var y = level.GetGroundY(x, z);
                source.Spawn(VanillaEffectID.waterLightningParticles, new Vector3(x, y, z));
            }
        }
        for (collider in detectBuffer)
        {
            collider.TakeDamage(damage, damageEffects, source);
        }
    }
    public static function CreateArc(source:Entity, sourcePosition:Vector3, targetPosition:Vector3):Void
    {
        // C#: source.Spawn(...)?.Let(e => { ... })
        var e = source.Spawn(VanillaEffectID.electricArc, sourcePosition);
        if (e != null)
        {
            ElectricArc.Connect(e, targetPosition);
            ElectricArc.SetPointCount(e, 20);
            ElectricArc.UpdateArc(e);
            e.Timeout = 30;
        }
    }
    public static function GetAttackTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourFieldNS(ID, PROP_ATTACK_TIMER);
    public static function SetAttackTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourFieldNS(ID, PROP_ATTACK_TIMER, timer);

    public static inline var ATTACK_COOLDOWN:Int = 65;
    public static inline var ATTACK_CHARGE:Int = 25;
    public static var PROP_ATTACK_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("AttackTimer");
    public static inline var ATTACK_HEIGHT:Float = 160;
    public static var ARC_OFFSET:Vector3 = new Vector3(0, 96, 0);
    public static inline var SHOCK_RADIUS:Float = 20;

    public static inline var STATE_IDLE:Int = VanillaContraptionStates.IDLE;
    public static inline var STATE_ATTACK:Int = VanillaContraptionStates.TESLA_COIL_ATTACK;

    var detector:Detector;
    static var detectBuffer:Array<IEntityCollider> = [];
    static var gridDetectBuffer:Map<LawnGrid, Bool> = new Map();
    static var ID:NamespaceID = VanillaContraptionID.teslaCoil;
}
