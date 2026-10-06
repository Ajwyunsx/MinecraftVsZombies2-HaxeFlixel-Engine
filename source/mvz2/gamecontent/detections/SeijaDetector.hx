// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/SeijaDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

class SeijaDetector extends Detector
{
    public function new(mode:Int)
    {
        this.mode = mode;
        if (mode == MODE_CAMERA)
        {
            mask = EntityCollisionHelper.MASK_PLANT;
        }
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
                sizeX = 40;
                sizeY = 40;
                sizeZ = 40;
                centerX = source.x + sizeX * 0.5 * self.GetFacingX();
                centerY = source.y + sizeY * 0.5;
                centerZ = source.z;
            }
            case MODE_PLACE_BOMB:
            {
                sizeX = 240;
                sizeY = 240;
                sizeZ = 240;
                centerX = source.x;
                centerY = source.y;
                centerZ = source.z;
            }
            case MODE_GAP_BOMB:
            {
                sizeX = 240;
                sizeY = 240;
                sizeZ = 240;
                var column = self.GetMirroredColumn(1, false);
                centerX = self.Level.GetEntityColumnX(column);
                centerZ = source.z;
                centerY = self.Level.GetGroundY(centerX, centerZ);
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
        if (mode == MODE_CAMERA)
        {
            var target = collider.Entity;
            if (!target.CanDeactive())
                return false;
            if (target.IsAIFrozen())
                return false;
        }
        return super.ValidateCollider(param, collider);
    }
    private var mode:Int;
    public static inline var MODE_DETECT:Int = 0;
    public static inline var MODE_SMASH:Int = 1;
    public static inline var MODE_PLACE_BOMB:Int = 2;
    public static inline var MODE_GAP_BOMB:Int = 3;
    public static inline var MODE_CAMERA:Int = 4;
}
