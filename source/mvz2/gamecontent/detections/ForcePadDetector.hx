// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/ForcePadDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaColliderExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.collisions.FactionTarget;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityProps;

class ForcePadDetector extends Detector
{
    public function new(mask:Int, affectHeight:Float, sizeMultiplier:Float)
    {
        canDetectInvisible = true;
        this.mask = mask;
        factionTarget = FactionTarget.Any;
        this.affectHeight = affectHeight;
        this.sizeMultiplier = sizeMultiplier;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var padSize = self.GetScaledSize() * sizeMultiplier;
        var sizeX = padSize.x;
        var sizeY = affectHeight;
        var sizeZ = padSize.z;
        var source = self.Position;
        var centerX = source.x;
        var centerY = source.y + sizeY * 0.5;
        var centerZ = source.z;
        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        if (!collider.IsForMain())
            return false;
        return super.ValidateCollider(param, collider);
    }
    public override function ValidateTarget(self:DetectionParams, target:Entity):Bool
    {
        if (!super.ValidateTarget(self, target))
            return false;
        if (target.IgnoreForcePad())
            return false;
        return true;
    }
    private var affectHeight:Float;
    private var sizeMultiplier:Float;
}
