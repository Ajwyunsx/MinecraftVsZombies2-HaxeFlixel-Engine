// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/SphereDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;

class SphereDetector extends Detector
{
    public function new(radius:Float)
    {
        this.radius = radius;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
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
        return collider.CheckSphere(center, radius);
    }
    private var radius:Float;
}
