// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/TheGiantEyeDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;

class TheGiantEyeDetector extends Detector
{
    public function new(outer:Bool)
    {
        this.outer = outer;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var sizeX:Float = 800;
        var sizeY:Float = 800;
        var sizeZ:Float = 800;
        var centerX = self.Position.x + sizeX * 0.5 * self.GetFacingX();
        var centerY = self.GetCenter().y;
        var centerZ = outer ? self.Position.z - sizeZ * 0.5 : self.Position.z + sizeZ * 0.5;
        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
    public var outer:Bool;
}
