// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/FireBreathDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.NamespaceID;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;

class FireBreathDetector extends Detector
{
    public function new(fireBreathID:NamespaceID)
    {
        this.fireBreathID = fireBreathID;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var fireBreathDef = GetEntityDefinition(fireBreathID);
        if (fireBreathDef == null)
            return new Bounds(Vector3.zero, Vector3.zero);
        var fireSize = fireBreathDef.GetSize();
        var fireBoundsPivot = fireBreathDef.GetBoundsPivot();

        var positionOffset = Vector3.Scale(Vector3.one * 0.5 - fireBoundsPivot, fireSize);
        positionOffset.x *= self.GetFacingX();
        return new Bounds(self.Position + positionOffset, fireSize);
    }
    override function ValidateCollider(self:DetectionParams, collider:IEntityCollider):Bool
    {
        if (!super.ValidateCollider(self, collider))
            return false;
        if (!ValidateTarget(self, collider.Entity))
            return false;
        var targetBounds = collider.GetBoundingBox();
        if (!TargetInLawnX(targetBounds.center.x))
            return false;
        return true;
    }
    public var fireBreathID:NamespaceID;
    public static var defaultPivot:Vector3 = new Vector3(0.5, 0, 0.5);

}
