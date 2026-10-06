// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter5/WoodenFanBlowBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.buffs.enemies.BlownByWoodenFanBuff;
import mvz2.gamecontent.detections.WoodenFanDetector;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.IBeBlownBehaviour;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.auras.IBuffTarget;
import pvzengine.buffs.Buff;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.collisions.FactionTarget;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.BooleanModifier;
import mvz2.vanilla.detection.Detector.DetectionParams;

@:autoBuffDefinition(VanillaBuffNames.Contraption_woodenFanBlow)
class WoodenFanBlowBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        detector = new WoodenFanDetector(false);
        cast(detector, WoodenFanDetector).mask = EntityCollisionHelper.MASK_ALL;
        cast(detector, WoodenFanDetector).factionTarget = cast FactionTarget.Any;
        cast(detector, WoodenFanDetector).canDetectInvisible = true;
        evokedDetector = new WoodenFanDetector(true);
        cast(evokedDetector, WoodenFanDetector).mask = EntityCollisionHelper.MASK_ALL;
        cast(evokedDetector, WoodenFanDetector).factionTarget = cast FactionTarget.Any;
        cast(evokedDetector, WoodenFanDetector).canDetectInvisible = true;
        AddAura(new Aura());
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var sourceEntity = buff.GetEntity();
        if (sourceEntity == null)
            return;
        var evoked = IsEvoked(buff);
        var level = sourceEntity.Level;

        // 吹动水面
        var det = evoked ? evokedDetector : detector;
        var results:Array<Entity> = [];
        det.DetectEntities(DetectionParams.fromEntity(sourceEntity), results);
        for (ent in results)
        {
            var behaviours = ent.Definition.GetBehaviours();
            for (behaviour in behaviours)
            {
                if (!Std.isOfType(behaviour, IBeBlownBehaviour))
                    continue;
                var blownBehaviour:IBeBlownBehaviour = cast behaviour;
                blownBehaviour.BeBlown(ent, sourceEntity);
            }
        }
    }
    public static function IsInRange(entity:Entity, source:Entity, evoked:Bool):Bool
    {
        return evoked || source.GetLane() == entity.GetLane();
    }
    public static function IsEvoked(buff:Buff):Bool return buff.GetProperty(PROP_EVOKED);
    public static function SetEvoked(buff:Buff, value:Bool):Void buff.SetProperty(PROP_EVOKED, value);
    public static var PROP_EVOKED:VanillaBuffPropertyMeta<Bool> = new VanillaBuffPropertyMeta<Bool>("evoked");
    var detector:Detector;
    var evokedDetector:Detector;
}

// C#: WoodenFanBlowBuff 的嵌套类 Aura
class Aura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Enemy.blownByWoodenFan, 3);
        detector = new WoodenFanDetector(false);
        cast(detector, WoodenFanDetector).mask = EntityCollisionHelper.MASK_ENEMY;
        cast(detector, WoodenFanDetector).factionTarget = cast FactionTarget.Hostile;
        cast(detector, WoodenFanDetector).canDetectInvisible = true;
        evokedDetector = new WoodenFanDetector(true);
        cast(evokedDetector, WoodenFanDetector).mask = EntityCollisionHelper.MASK_ENEMY;
        cast(evokedDetector, WoodenFanDetector).factionTarget = cast FactionTarget.Hostile;
        cast(evokedDetector, WoodenFanDetector).canDetectInvisible = true;
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var sourceBuff = cast(auraEffect.Source, Buff);
        if (sourceBuff == null)
            return;
        var sourceEntity = sourceBuff.GetEntity();
        if (sourceEntity == null)
            return;
        var evoked = WoodenFanBlowBuff.IsEvoked(sourceBuff);
        var det = evoked ? evokedDetector : detector;
        detectBuffer.resize(0);
        det.DetectEntities(DetectionParams.fromEntity(sourceEntity), detectBuffer);
        for (ent in detectBuffer)
        {
            results.push(ent);
        }
    }
    public override function UpdateTargetBuff(effect:AuraEffect, target:IBuffTarget, buff:Buff):Void
    {
        super.UpdateTargetBuff(effect, target, buff);
        var sourceBuff = cast(effect.Source, Buff);
        if (sourceBuff == null)
            return;
        var sourceEntity = sourceBuff.GetEntity();
        if (sourceEntity == null)
            return;
        BlownByWoodenFanBuff.SetSourceID(buff, sourceEntity.ID);
    }
    var detector:Detector;
    var evokedDetector:Detector;
    var detectBuffer:Array<Entity> = [];
}
