// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/MutantZombieDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.enemies.VanillaEnemyProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

class MutantZombieDetector extends Detector
{
    public function new(rangeAddition:Float)
    {
        this.rangeAddition = rangeAddition;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var sizeX = self.GetRange() + rangeAddition;
        var sizeY = self.GetMaxAttackHeight();
        var sizeZ:Float = 80;
        var pos = self.Position;
        var centerX = pos.x + self.GetFacingX() * sizeX * 0.5;
        var centerY = pos.y + sizeY * 0.5;
        var centerZ = pos.z;
        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
    private var rangeAddition:Float;
}
