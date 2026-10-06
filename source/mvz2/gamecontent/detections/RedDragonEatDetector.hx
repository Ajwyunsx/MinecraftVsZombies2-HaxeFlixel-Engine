// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/RedDragonEatDetector.cs
package mvz2.gamecontent.detections;

import mvz2.gamecontent.bosses.RedDragon;
import mvz2.gamecontent.bosses.RedDragon.RedDragonHelpers3;
import mvz2.vanilla.detection.Detector;
import pvzengine.collisions.FactionTarget;
import pvzengine.entities.Entity;
import unity.Bounds;

class RedDragonEatDetector extends Detector
{
    public function new()
    {
        factionTarget = FactionTarget.Any;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        return RedDragonHelpers3.GetEatDetectionHitbox(self);
    }
}
