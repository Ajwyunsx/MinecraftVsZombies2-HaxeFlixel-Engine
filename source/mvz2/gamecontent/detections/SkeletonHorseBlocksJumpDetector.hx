// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/SkeletonHorseBlocksJumpDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.contraptions.VanillaContraptionProps;
import mvz2.vanilla.detection.Detection;
import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
using mvz2.vanilla.contraptions.VanillaContraptionProps;

class SkeletonHorseBlocksJumpDetector extends Detector
{
    // PORT-NOTE: C# 中 Detector 派生类使用隐式无参构造函数；Haxe 不会为缺少构造函数的类合成构造函数，
    //   故此处显式声明无参构造，保证 `new SkeletonHorseBlocksJumpDetector()` 可用（与 C# 行为一致）。
    public function new() {}
    override function GetDetectionBounds(self:Entity):Bounds
    {
        return self.GetBounds();
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        if (!super.ValidateCollider(param, collider))
            return false;
        var bounds = collider.GetBoundingBox();
        // C#: param.entity.IsInTheFrontOf(bounds.center.x)
        if (Detection.IsInTheFrontOfEntity(param.entity, bounds.center.x))
            return false;
        var target = collider.Entity;
        if (!target.BlocksJump())
            return false;
        return true;
    }
}
