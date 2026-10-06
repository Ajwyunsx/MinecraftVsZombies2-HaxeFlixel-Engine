// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/AmethystPylonDetector.cs
package mvz2.gamecontent.detections;

import mvz2.gamecontent.contraptions.AmethystPylon;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.level.LevelPositions;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

class AmethystPylonDetector extends Detector
{
    public function new() {}
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var source = AmethystPylon.GetLaserPosition(self);
        var laserSizeDef = GetEntitySize(VanillaEffectID.amethystPylonLaser, new Vector3(2000, 26, 26));
        var laserSize = Vector3.Scale(laserSizeDef, AmethystPylon.GetLaserScale(self));
        var range = self.GetRange();

        var sizeX = range < 0 ? 800 : range;
        if (self.GetFacingX() > 0)
        {
            var limitedRange = LevelPositions.GetAttackBorderX(true) - source.x;
            sizeX = Mathf.Min(sizeX, limitedRange);
        }
        var sizeY = laserSize.y;
        var sizeZ = laserSize.z;
        var centerX = source.x + sizeX * 0.5 * self.GetFacingX();
        var centerY = source.y;
        var centerZ = source.z;

        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
}
