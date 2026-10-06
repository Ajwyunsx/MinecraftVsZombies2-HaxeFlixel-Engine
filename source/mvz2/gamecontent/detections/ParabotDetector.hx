// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/ParabotDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;

class ParabotDetector extends Detector
{
    public function new(range:Float)
    {
        this.range = range;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var sizeX = range * 2;
        var sizeY = range * 2;
        var sizeZ = range * 2;
        var center = self.GetCenter();
        return new Bounds(center, new Vector3(sizeX, sizeY, sizeZ));
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        if (!super.ValidateCollider(param, collider))
            return false;
        var targetBounds = collider.GetBoundingBox();
        var center = targetBounds.center;
        return Vector3.Distance(param.entity.GetCenter(), center) < range;
    }
    public var range:Float;
}
