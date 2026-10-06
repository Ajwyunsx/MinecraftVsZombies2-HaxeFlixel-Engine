// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/LawnDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2logic.level.LevelPositions;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;

class LawnDetector extends Detector
{
    public function new()
    {
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var minX = 0;
        var maxX = LevelPositions.LEVEL_WIDTH;
        var minZ = 0;
        var maxZ = LevelPositions.LAWN_HEIGHT;
        var sizeY:Float = 800;
        var center = self.GetCenter();
        center.x = (minX + maxX) * 0.5;
        center.y = sizeY * 0.5;
        center.z = (minZ + maxZ) * 0.5;
        return new Bounds(center, new Vector3(maxX - minX, sizeY, maxZ - minZ));
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        if (colliderFilter != null && !colliderFilter(param, collider))
            return false;
        return super.ValidateCollider(param, collider);
    }
    public var colliderFilter:DetectionParams->IEntityCollider->Bool = null;
}
