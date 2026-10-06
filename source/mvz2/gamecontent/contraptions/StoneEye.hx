// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter6/StoneEye.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.detections.StoneEyeDetector;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.auras.IBuffTarget;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.stoneEye)
class StoneEye extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new StoneEye_Aura());
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetModelProperty("Active", !entity.IsAIFrozen());
        entity.SetAnimationFloat("RayRange", GetRealRange(entity));
    }
    public static function GetRealRange(entity:Entity):Float
    {
        return entity.GetRange() + 40 - RANGE_OFFSET;
    }
    public static inline var RANGE_OFFSET:Float = 20;
    public static var rayOffset:Vector3 = new Vector3(RANGE_OFFSET, 24, 0);
}

// PORT-NOTE: C# 的嵌套类 StoneEye.Aura 提升为模块级类 StoneEye_Aura（Haxe 不支持嵌套类）。
class StoneEye_Aura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Entity.stoneEyeSlowing, 2);
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var entity = auraEffect.Source.GetEntity();
        if (entity == null)
            return;
        if (entity.IsAIFrozen())
            return;
        var facingX = entity.GetFacingX();
        detectorBuffer = [];
        rayDetector.DetectEntities(DetectionParams.fromEntity(entity), detectorBuffer);
        for (e in detectorBuffer)
            results.push(e);
    }
    public static var rayDetector:Detector = new StoneEyeDetector(StoneEye.rayOffset);
    public var detectorBuffer:Array<Entity> = [];
}
