// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/CollisionDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector;
import pvzengine.entities.Entity;
import unity.Bounds;

class CollisionDetector extends Detector
{
    public function new(canDetectInvisible:Bool)
    {
        this.canDetectInvisible = canDetectInvisible;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        return self.GetBounds();
    }
}
