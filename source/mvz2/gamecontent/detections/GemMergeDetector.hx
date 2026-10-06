// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/GemMergeDetector.cs
package mvz2.gamecontent.detections;

import mvz2.gamecontent.pickups.MergePickup;
import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.collisions.FactionTarget;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;

class GemMergeDetector extends Detector
{
    public function new()
    {
        canDetectInvisible = true;
        mask = EntityCollisionHelper.MASK_PICKUP;
        factionTarget = FactionTarget.Any;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var size = MergePickup.GetMergeRange(self);
        var sizeX = size;
        var sizeY = size;
        var sizeZ = size;
        var centerX = self.Position.x;
        var centerY = self.Position.y + sizeY * 0.5;
        var centerZ = self.Position.z;
        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        var gemID = param.entity.GetDefinitionID();
        return collider.Entity.IsEntityOf(gemID);
    }
}
