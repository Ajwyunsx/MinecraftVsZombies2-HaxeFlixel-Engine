// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/GridDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;

class GridDetector extends Detector
{
    public function new(canDetectInvisible:Bool)
    {
        this.canDetectInvisible = canDetectInvisible;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var column = self.GetColumn();
        var lane = self.GetLane();
        var level = self.Level;
        var sizeX = level.GetGridWidth();
        var sizeY:Float = 40;
        var sizeZ = level.GetGridHeight();
        var centerX = level.GetEntityColumnX(column);
        var centerZ = level.GetEntityLaneZ(lane);
        var centerY = level.GetGroundY(centerX, centerZ) + sizeY * 0.5;
        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
}
