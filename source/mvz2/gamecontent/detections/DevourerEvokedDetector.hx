// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/DevourerEvokedDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.level.LevelPositions;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;

class DevourerEvokedDetector extends Detector
{
    public function new()
    {
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var minX = LevelPositions.LEFT_BORDER;
        var maxX = LevelPositions.RIGHT_BORDER;
        var minZ = self.Level.GetGridBottomZ();
        var maxZ = self.Level.GetGridTopZ();
        var sizeY:Float = 800;
        var centerX = (minX + maxX) * 0.5;
        var centerY = sizeY * 0.5;
        var centerZ = (minZ + maxZ) * 0.5;
        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(maxX - minX, sizeY, maxZ - minZ));
    }
    public override function ValidateTarget(self:DetectionParams, target:Entity):Bool
    {
        if (!TargetInLawn(target))
            return false;
        if (target.GetRelativeY() > 48 + self.entity.GetRelativeY())
            return false;
        return super.ValidateTarget(self, target);
    }
}
