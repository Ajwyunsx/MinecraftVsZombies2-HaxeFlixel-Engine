// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/CameraFlashDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import unity.Bounds;
using pvzengine.entities.EngineEntityExt;

class CameraFlashDetector extends Detector
{
    public function new()
    {
        canDetectInvisible = true;
        mask = EntityCollisionHelper.MASK_PLANT | EntityCollisionHelper.MASK_PROJECTILE;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        return self.GetBounds();
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        var target = collider.Entity;
        if (target.Type == EntityTypes.PROJECTILE)
        {
            if (target == null)
                return false;
            if (param.entity == target && !includeSelf)
                return false;
            if (target.IsDead)
                return false;
            if (!target.IsFactionTargetFaction(param.faction, factionTarget))
                return false;
            return true;
        }
        return super.ValidateCollider(param, collider);
    }
}
