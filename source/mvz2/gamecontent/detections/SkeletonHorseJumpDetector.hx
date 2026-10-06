// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/SkeletonHorseJumpDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.contraptions.VanillaContraptionProps;
import mvz2.vanilla.detection.Detection;
import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.contraptions.VanillaContraptionProps;
using mvz2.vanilla.entities.VanillaEntityExt;

class SkeletonHorseJumpDetector extends Detector
{
    // PORT-NOTE: C# 中 Detector 派生类使用隐式无参构造函数；Haxe 不会为缺少构造函数的类合成构造函数，
    //   故此处显式声明无参构造，保证 `new SkeletonHorseJumpDetector()` 可用（与 C# 行为一致）。
    public function new() {}
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var sizeX:Float = 40;
        var sizeY:Float = 40;
        var sizeZ:Float = 40;
        var centerX = self.Position.x + self.GetFacingX() * sizeX * 0.5;
        var centerY = self.Position.y + sizeY * 0.5;
        var centerZ = self.Position.z;
        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        if (!super.ValidateCollider(param, collider))
            return false;
        var target = collider.Entity;
        if (target.IsFloor())
            return false;
        var bounds = collider.GetBoundingBox();
        // C#: param.entity.IsInTheFrontOf(bounds.center.x)
        if (Detection.IsInTheFrontOfEntity(param.entity, bounds.center.x))
            return false;
        return true;
    }
}
