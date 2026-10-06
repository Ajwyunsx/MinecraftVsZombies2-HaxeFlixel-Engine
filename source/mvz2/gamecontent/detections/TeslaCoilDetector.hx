// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/TeslaCoilDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityProps;

class TeslaCoilDetector extends Detector
{
    public function new(attackHeight:Float)
    {
        this.attackHeight = attackHeight;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var range = self.GetRange();
        var sizeX = range * 2;
        var sizeY = attackHeight;
        var sizeZ = range * 2;
        var centerX = self.Position.x;
        var centerY = self.Position.y + sizeY * 0.5;
        var centerZ = self.Position.z;
        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        if (!super.ValidateCollider(param, collider))
            return false;
        var self = param.entity;

        var range = self.GetRange();
        var center = self.GetCenter();

        return collider.CheckSphere(center, range);
    }
    private var attackHeight:Float;
}
