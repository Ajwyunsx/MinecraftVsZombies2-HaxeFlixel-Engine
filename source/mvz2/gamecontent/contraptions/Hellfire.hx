// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter4/Hellfire.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.contraptions.HellfireCursedBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.HellfireIgniteDetector;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.detection.Detector;
import pvzengine.collisions.FactionTarget;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.EntityID;
import pvzengine.buffs.BuffExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.EntityTypes;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.BooleanOperator;
import unity.Vector3;
using mvz2logic.entities.LogicEntityExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.hellfire)
class Hellfire extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(VanillaEntityProps.IS_FIRE, BooleanOperator.SetNot, PROP_EXTINGUISHED));
        AddModifier(new BooleanModifier(LogicEntityProps.IS_LIGHT_SOURCE, BooleanOperator.SetNot, PROP_EXTINGUISHED));
        AddTrigger(VanillaLevelCallbacks.APPLY_DAMAGE_SPECIAL_EFFECTS, ApplyDamageSpecialEffectsCallback, EntityTypes.PLANT);
        detector = new HellfireIgniteDetector(32);
        cast(detector, HellfireIgniteDetector).factionTarget = FactionTarget.Friendly;
        cast(detector, HellfireIgniteDetector).mask = EntityCollisionHelper.MASK_PROJECTILE;
        rekindleDetector = new HellfireIgniteDetector(32);
        cast(rekindleDetector, HellfireIgniteDetector).factionTarget = FactionTarget.Any;
        cast(rekindleDetector, HellfireIgniteDetector).mask = EntityCollisionHelper.MASK_ALL;
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);

        if (!IsExtinguished(entity))
        {
            UpdateIgnite(entity);
        }
        else
        {
            UpdateExtinguished(entity);
        }

        entity.SetAnimationBool("Evoked", IsCursed(entity));
        entity.SetModelProperty("Extinguished", IsExtinguished(entity));
    }
    public override function CanEvoke(entity:Entity):Bool
    {
        if (IsCursed(entity))
            return false;
        var meteor = GetMeteor(entity);
        if (meteor != null && meteor.Exists(entity.Level))
            return false;
        return super.CanEvoke(entity);
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var pos = entity.Position + new Vector3(0, 1280, 0);
        // C#: entity.SpawnWithParams(...)?.Let(e => { ... })
        var e = entity.SpawnWithParams(VanillaEffectID.cursedMeteor, pos);
        if (e != null)
        {
            e.SetParent(entity);
            SetMeteor(entity, new EntityID(e));
            e.PlaySound(VanillaSoundID.bombFalling);
        }
    }
    function ApplyDamageSpecialEffectsCallback(param:PostTakeDamageParams, result:CallbackResult):Void
    {
        var output = param.output;
        var hellfire = output.Entity;
        if (hellfire.HasBehaviour(this) && IsExtinguished(hellfire))
        {
            if (output.BodyResult != null && output.BodyResult.HasEffect(VanillaDamageEffects.FIRE))
            {
                Rekindle(hellfire);
            }
        }
    }
    function UpdateIgnite(hellfire:Entity):Void
    {
        var cursed = IsCursed(hellfire);
        igniteBuffer = [];
        detector.DetectEntities(DetectionParams.fromEntity(hellfire), igniteBuffer);
        for (target in igniteBuffer)
        {
            target.HellfireIgnite(hellfire, cursed);
        }
    }
    function UpdateExtinguished(hellfire:Entity):Void
    {
        igniteBuffer = [];
        rekindleDetector.DetectEntities(DetectionParams.fromEntity(hellfire), igniteBuffer);
        for (target in igniteBuffer)
        {
            if (target != hellfire && target.IsFire())
            {
                Rekindle(hellfire);
                return;
            }
        }
    }
    public static function Extinguish(entity:Entity):Void
    {
        if (IsExtinguished(entity))
            return;
        SetExtinguished(entity, true);
        entity.PlaySound(VanillaSoundID.fizz);
    }
    public static function Rekindle(entity:Entity):Void
    {
        if (!IsExtinguished(entity))
            return;
        SetExtinguished(entity, false);
        entity.PlaySound(VanillaSoundID.fire);
    }
    public static function Curse(entity:Entity):Void
    {
        SetCursed(entity, true);
        entity.AddBuff(HellfireCursedBuff);
    }
    public static function SetCursed(entity:Entity, value:Bool):Void entity.SetProperty(PROP_CURSED, value);
    public static function IsCursed(entity:Entity):Bool return entity.GetProperty(PROP_CURSED);
    public static function SetExtinguished(entity:Entity, value:Bool):Void entity.SetProperty(PROP_EXTINGUISHED, value);
    public static function IsExtinguished(entity:Entity):Bool return entity.GetProperty(PROP_EXTINGUISHED);
    public static function SetMeteor(entity:Entity, value:EntityID):Void entity.SetProperty(PROP_METEOR, value);
    public static function GetMeteor(entity:Entity):Null<EntityID> return entity.GetProperty(PROP_METEOR);
    public static var PROP_CURSED:VanillaBuffPropertyMeta<Bool> = new VanillaBuffPropertyMeta<Bool>("cursed");
    public static var PROP_EXTINGUISHED:VanillaBuffPropertyMeta<Bool> = new VanillaBuffPropertyMeta<Bool>("extinguished");
    public static var PROP_METEOR:VanillaBuffPropertyMeta<EntityID> = new VanillaBuffPropertyMeta<EntityID>("meteor");
    var detector:Detector;
    var rekindleDetector:Detector;
    var igniteBuffer:Array<Entity> = [];
}
