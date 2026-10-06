// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/WitherDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LevelPositions;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

class WitherDetector extends Detector
{
    public function new(mode:Int)
    {
        this.mode = mode;
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
            case MODE_EAT:
            {
                sizeX = 320;
                sizeY = 160;
                sizeZ = self.Level.GetGridTopZ() - self.Level.GetGridBottomZ();

                var column = self.GetMirroredColumn(0, true);
                var x = self.Level.GetEntityColumnX(column);
                centerX = x + sizeX * 0.5 * self.GetFacingX();
                centerY = 80;
                centerZ = self.Level.GetLawnCenterZ();
            }
            default:
            {
                sizeX = LevelPositions.RIGHT_BORDER - LevelPositions.LEFT_BORDER;
                sizeY = 800;
                sizeZ = self.Level.GetGridTopZ() - self.Level.GetGridBottomZ();
                centerX = (LevelPositions.LEFT_BORDER + LevelPositions.RIGHT_BORDER) * 0.5;
                centerY = 400;
                centerZ = self.Level.GetLawnCenterZ();
            }
        }
        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
    private var mode:Int;
    public static inline var MODE_SKULL:Int = 0;
    public static inline var MODE_CHARGE:Int = 1;
    public static inline var MODE_EAT:Int = 2;
}
