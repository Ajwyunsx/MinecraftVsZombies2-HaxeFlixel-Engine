// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/LockedChestDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

class LockedChestDetector extends Detector
{
    public function new(mode:Int, ?canDetectInvisible:Bool = false)
    {
        this.mode = mode;
        this.canDetectInvisible = canDetectInvisible;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var source = self.Position;
        var sizeX:Float = 0;
        var sizeY:Float = 0;
        var sizeZ:Float = 0;
        var centerX = source.x;
        var centerY = source.y;
        var centerZ = source.z;
        switch (mode)
        {
            case MODE_SMASH:
            {
                sizeX = 200;
                sizeY = 40;
                sizeZ = 40;
                centerX = source.x;
                centerZ = source.z;
                centerY = source.y + 20;
            }
            case MODE_CAMERA:
            {
                sizeX = 160;
                sizeY = 800;
                sizeZ = 240;
                centerX = source.x + self.GetFacingX() * 240;
                centerZ = source.z;
                centerY = self.Level.GetGroundY(centerX, centerZ);
            }
            default:
            {
                sizeX = 240;
                sizeY = 64;
                sizeZ = 40;
                centerX = source.x + sizeX * 0.5 * self.GetFacingX();
                centerY = source.y + sizeY * 0.5;
                centerZ = source.z;
            }
        }
        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        switch (mode)
        {
            case MODE_CAMERA:
            {
                var target = collider.Entity;
                if (!target.CanDeactive())
                    return false;
                if (target.IsAIFrozen())
                    return false;
            }
        }
        return super.ValidateCollider(param, collider);
    }
    private var mode:Int;
    public static inline var MODE_CAMERA:Int = 0;
    public static inline var MODE_SMASH:Int = 1;
}
