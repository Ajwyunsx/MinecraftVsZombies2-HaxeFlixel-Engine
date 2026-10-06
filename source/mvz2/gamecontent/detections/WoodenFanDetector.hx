// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/WoodenFanDetector.cs
package mvz2.gamecontent.detections;

import mvz2.gamecontent.contraptions.WoodenFan;
import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2logic.level.LevelPositions;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;

class WoodenFanDetector extends Detector
{
    public function new(evoked:Bool)
    {
        this.evoked = evoked;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var minX = LevelPositions.LEVEL_LEFTMOST;
        var maxX = LevelPositions.LEVEL_RIGHTMOST;
        var minY = self.Position.y - WoodenFan.AFFECT_HEIGHT;
        var maxY = self.Position.y + WoodenFan.AFFECT_HEIGHT;
        var sizeX = maxX - minX;
        var sizeY = maxY - minY;
        var sizeZ = evoked ? LevelPositions.LAWN_HEIGHT : self.Level.GetGridHeight();
        var center = self.GetCenter();
        center.x = (minX + maxX) * 0.5;
        center.y = (minY + maxY) * 0.5;
        if (evoked)
        {
            var minZ = self.Level.GetGridBottomZ();
            var maxZ = self.Level.GetGridTopZ();
            center.z = (minZ + maxZ) * 0.5;
        }
        return new Bounds(center, new Vector3(sizeX, sizeY, sizeZ));
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        // 原文件注释为乱码：目标Z轴边缘不能被忽略
        var self = param.entity;
        var minZ:Float;
        var maxZ:Float;
        if (evoked)
        {
            minZ = self.Level.GetGridBottomZ();
            maxZ = self.Level.GetGridTopZ();
        }
        else
        {
            var sizeZ = self.Level.GetGridHeight();
            var centerZ = self.GetCenter().z;
            minZ = centerZ - sizeZ * 0.5;
            maxZ = centerZ + sizeZ * 0.5;
        }

        var bounds = collider.GetBoundingBox();
        if (bounds.center.z < minZ || bounds.center.z > maxZ)
            return false;
        return super.ValidateCollider(param, collider);
    }
    private var evoked:Bool;
}
