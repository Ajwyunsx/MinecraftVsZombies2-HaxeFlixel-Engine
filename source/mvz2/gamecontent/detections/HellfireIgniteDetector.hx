// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/HellfireIgniteDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;

class HellfireIgniteDetector extends Detector
{
    public function new(extraHeight:Float)
    {
        canDetectInvisible = true;
        this.extraHeight = extraHeight;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var bounds = self.GetBounds();
        bounds.max += Vector3.up * extraHeight;
        return bounds;
    }
    private var extraHeight:Float;
}
