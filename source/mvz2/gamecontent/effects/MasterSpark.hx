// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter6/MasterSpark.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.detections.CollisionDetector;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.collisions.IEntityCollider;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import tools.Ticks;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
import mvz2.vanilla.detection.Detector.DetectionParams;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.masterSpark)
class MasterSpark extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(EngineEntityProps.DISPLAY_SCALE, NumberOperator.Multiply, PROP_SIZE_MULTIPLIER));
        AddModifier(new Vector3Modifier(EngineEntityProps.SIZE, NumberOperator.Multiply, PROP_SIZE_MULTIPLIER));
        AddModifier(new Vector3Modifier(LogicEntityProps.HSV_OFFSET, NumberOperator.Add, PROP_HSV_OFFSET));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.PlaySound(VanillaSoundID.touhouLaser);
        SetSizeMultiplier(entity, new Vector3(1, 0.01, 0.01));
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (!entity.Parent.ExistsAndAlive() || entity.Parent.IsAIFrozen())
        {
            entity.Remove();
            return;
        }

        var hsv = GetHSVOffset(entity);
        hsv.x += HUE_SPEED;
        SetHSVOffset(entity, hsv);

        if (entity.GetEntityTime() < EXPAND_TIME)
        {
            SetSizeMultiplier(entity, new Vector3(1, 0.01, 0.01));
        }
        else if (IsShrinking(entity))
        {
            var multiplier = GetSizeMultiplier(entity);
            multiplier = Vector3.Lerp(multiplier, new Vector3(1, 0, 0), entity.Timeout / SHRINK_TIME);
            SetSizeMultiplier(entity, multiplier);
        }
        else
        {
            if (!IsSoundPlayed(entity))
            {
                SetSoundPlayed(entity, true);
                entity.PlaySound(VanillaSoundID.masterSpark);
            }
            entity.Level.ShakeScreen(1, 0, 15);
            var multiplier = GetSizeMultiplier(entity);
            // PORT-NOTE: C# Ticks.SmoothDamp 对 Vector3 的重载在 Haxe shim 中名为 SmoothDampVector。
            multiplier = Ticks.SmoothDampVector(multiplier, Vector3.one, 0.75);
            SetSizeMultiplier(entity, multiplier);

            detectBuffer.resize(0);
            laserDetector.DetectMultiple(DetectionParams.fromEntity(entity), detectBuffer);
            var damageEffects = entity.GetDamageEffects();
            var damage = entity.GetDamage();
            var effects = damageEffects == null ? new DamageEffectList([]) : new DamageEffectList(damageEffects);
            for (target in detectBuffer)
            {
                target.TakeDamage(damage, effects, entity);
            }
        }
    }
    public static function IsShrinking(entity:Entity):Bool
    {
        return entity.Timeout < SHRINK_TIME;
    }
    public static function IsSoundPlayed(entity:Entity):Bool return entity.GetBehaviourField(PROP_SOUND_PLAYED);
    public static function SetSoundPlayed(entity:Entity, value:Bool):Void entity.SetBehaviourField(PROP_SOUND_PLAYED, value);
    public static function GetSizeMultiplier(entity:Entity):Vector3 return entity.GetBehaviourField(PROP_SIZE_MULTIPLIER);
    public static function SetSizeMultiplier(entity:Entity, value:Vector3):Void entity.SetBehaviourField(PROP_SIZE_MULTIPLIER, value);
    public static function GetHSVOffset(entity:Entity):Vector3 return entity.GetBehaviourField(PROP_HSV_OFFSET);
    public static function SetHSVOffset(entity:Entity, value:Vector3):Void entity.SetBehaviourField(PROP_HSV_OFFSET, value);

    public static var PROP_SOUND_PLAYED:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("sound_played");
    public static var PROP_SIZE_MULTIPLIER:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("size_multiplier");
    public static var PROP_HSV_OFFSET:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("hsv_offset");
    public static inline var EXPAND_TIME:Int = 30;
    public static inline var SHRINK_TIME:Int = 15;
    public static inline var HUE_SPEED:Float = 10;
    public static var laserDetector:Detector = new CollisionDetector(true);
    // PORT-NOTE: C# 用 HashSet<IEntityCollider> 去重；Haxe 侧 Detector.DetectMultiple 只接收 Array，故改为 Array。
    public var detectBuffer:Array<IEntityCollider> = [];
}
