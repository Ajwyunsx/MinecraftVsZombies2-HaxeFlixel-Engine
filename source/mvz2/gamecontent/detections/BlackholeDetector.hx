// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/BlackholeDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityProps;

class BlackholeDetector extends Detector
{
    public function new()
    {
        canDetectInvisible = true;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var radius = self.GetRange();
        var sizeX = radius * 2;
        var sizeY = radius * 2;
        var sizeZ = radius * 2;
        var center = self.GetCenter();
        return new Bounds(center, new Vector3(sizeX, sizeY, sizeZ));
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        if (!super.ValidateCollider(param, collider))
            return false;
        var self = param.entity;
        var center = self.GetCenter();
        var radius = self.GetRange();
        return collider.CheckSphere(center, radius);
    }
}
