// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter6/PsychicShackle.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.detections.BoxDetector;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.grids.LogicGridExt;
import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.auras.IBuffTarget;
import pvzengine.collisions.FactionTarget;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.SpawnParams;
import pvzengine.level.LevelEngine;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
import mvz2.vanilla.detection.Detector.DetectionParams;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.psychicShackle)
class PsychicShackle extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new PsychicShackleAura());
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        UpdateUnlock(entity);

        entity.SetModelProperty("ShadowSprite", GetShadowSprite(entity));
    }
    private function GetShadowSprite(entity:Entity):Null<SpriteReference>
    {
        var id = GetRequiredEntityID(entity);
        if (id == null)
            return null;
        var spriteID = new NamespaceID(id.SpaceName, 'model_icon/entity.${id.Path}');
        var spriteRef = new SpriteReference(spriteID);
        return spriteRef;
    }
    private function UpdateUnlock(entity:Entity):Void
    {
        var grid = entity.GetGrid();
        if (grid != null)
        {
            var id = GetRequiredEntityID(entity);
            if (id == null)
                return;
            for (ent in grid.GetEntities())
            {
                if (ent.IsEntityOf(id))
                {
                    entity.PlaySound(VanillaSoundID.chainsBreak);
                    entity.Remove();
                    return;
                }
            }
        }
    }
    public static function Spawn(level:LevelEngine, position:Vector3, requiredID:NamespaceID, source:Null<Entity>):Null<Entity>
    {
        var param = new SpawnParams();
        param.SetProperty(PROP_REQUIRED_ENTITY_ID, requiredID);
        return level.Spawn(VanillaEffectID.psychicShackle, position, source, param);
    }
    public static function GetRequiredEntityID(entity:Entity):Null<NamespaceID> return entity.GetProperty(PROP_REQUIRED_ENTITY_ID);
    public static function SetRequiredEntityID(entity:Entity, value:Null<NamespaceID>):Void entity.SetProperty(PROP_REQUIRED_ENTITY_ID, value);
    public static var PROP_REQUIRED_ENTITY_ID:VanillaEntityPropertyMeta<NamespaceID> = new VanillaEntityPropertyMeta<NamespaceID>("required_entity_id");
}

// PORT-NOTE: C# 的嵌套类 PsychicShackle.ShackleAura 提升为模块级类（Haxe 不支持嵌套类）。
class PsychicShackleAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Contraption.psychicShackled, 4);
        detector = new BoxDetector(new Vector3(200, 80, 200), Vector3.zero, true);
        detector.factionTarget = cast FactionTarget.Any;
        detector.mask = EntityCollisionHelper.MASK_PLANT;
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var source = auraEffect != null && auraEffect.Source != null ? auraEffect.Source.GetEntity() : null;
        if (source == null)
            return;

        detectBuffer.resize(0);
        detector.DetectEntities(DetectionParams.fromEntity(source), detectBuffer);
        for (other in detectBuffer)
        {
            if (!other.CanDeactive())
                continue;
            results.push(other);
        }
    }
    public var detector:Detector;
    private var detectBuffer:Array<Entity> = [];
}
