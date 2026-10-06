// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/MagichestDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

class MagichestDetector extends Detector
{
    public function new(?rangeAddition:Float = 0)
    {
        mask = EntityCollisionHelper.MASK_ENEMY;
        this.rangeAddition = rangeAddition;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var sizeX = self.GetRange() + rangeAddition;
        var sizeY:Float = 48;
        var sizeZ:Float = 48;
        var source = self.Position;
        var centerX = source.x + sizeX * 0.5 * self.GetFacingX();
        var centerY = source.y + sizeY * 0.5;
        var centerZ = source.z;
        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
    override function ValidateCollider(self:DetectionParams, collider:IEntityCollider):Bool
    {
        if (!super.ValidateCollider(self, collider))
            return false;
        var target = collider.Entity;
        if (!TargetInLawn(target))
            return false;
        return true;
    }
    private var rangeAddition:Float;
}
