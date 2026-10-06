// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/SpikeBlockDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaColliderExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaColliderExt;

class SpikeBlockDetector extends Detector
{
    public function new(?evoked:Bool = false)
    {
        this.evoked = evoked;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var bounds = self.GetBounds();
        if (evoked)
        {
            var size = bounds.size;
            size.x = 1600;
            size.y = 800;
            bounds.size = size;

            var center = bounds.center;
            center.y = self.Position.y + size.y * 0.5;
            bounds.center = center;
        }
        return bounds;
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        if (!collider.IsForMain())
            return false;
        if (evoked && collider.Entity.GetRelativeY() > param.entity.GetSize().y)
            return false;
        if (!super.ValidateCollider(param, collider))
            return false;
        return true;
    }
    private var evoked:Bool;
}
