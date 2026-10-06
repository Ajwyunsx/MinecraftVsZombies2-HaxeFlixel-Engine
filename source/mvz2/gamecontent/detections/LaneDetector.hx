// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/LaneDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector;
import mvz2logic.level.LevelPositions;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;

class LaneDetector extends Detector
{
    public function new(ySize:Float, zSize:Float)
    {
        this.ySize = ySize;
        this.zSize = zSize;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var minX = LevelPositions.LEFT_BORDER;
        var maxX = LevelPositions.RIGHT_BORDER;
        var sizeY = ySize;
        var sizeZ = zSize;
        var center = self.GetCenter();
        center.x = (minX + maxX) * 0.5;
        center.y = sizeY * 0.5;
        return new Bounds(center, new Vector3(maxX - minX, sizeY, sizeZ));
    }
    private var ySize:Float;
    private var zSize:Float;
}
