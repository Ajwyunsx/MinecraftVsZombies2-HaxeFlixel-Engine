// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/TheGiantArmDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;

class TheGiantArmDetector extends Detector
{
    public function new(outer:Bool)
    {
        this.outer = outer;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var sizeX = 80 + self.GetScaledSize().x * 0.5;
        var sizeY:Float = 80;
        var sizeZ:Float = 160;
        var centerX = self.Position.x + sizeX * 0.5 * self.GetFacingX();
        var centerY = self.Position.y + sizeY * 0.5;
        var centerZ = outer ? self.Position.z - 40 - sizeZ * 0.5 : self.Position.z - 40 + sizeZ * 0.5;
        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
    public var outer:Bool;
}
