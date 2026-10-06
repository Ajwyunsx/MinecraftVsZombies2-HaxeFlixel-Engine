// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/SkywardBeaconDetector.cs
package mvz2.gamecontent.detections;

import mvz2.gamecontent.contraptions.SkywardBeacon;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.detection.Detector;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;

class SkywardBeaconDetector extends Detector
{
    public function new() {}
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var targetPosition = SkywardBeacon.GetStrikePosition(self);
        var beamDef = GetEntityDefinition(VanillaEffectID.skywardBeam);
        // C#: beamDef?.GetSize() ?? new Vector3(64, 800, 64)
        var size = new Vector3(64, 800, 64);
        if (beamDef != null)
        {
            size = beamDef.GetSize();
        }
        var center = targetPosition;
        center.y = size.y * 0.5;
        return new Bounds(center, size);
    }
}
