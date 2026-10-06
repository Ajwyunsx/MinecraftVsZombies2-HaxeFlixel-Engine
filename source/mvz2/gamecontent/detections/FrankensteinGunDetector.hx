// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/FrankensteinGunDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.EngineEntityProps;
import pvzengine.NamespaceID;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;

class FrankensteinGunDetector extends Detector
{
    public function new(projectileID:NamespaceID)
    {
        this.projectileID = projectileID;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var projectileDef = GetEntityDefinition(projectileID);
        // C#: projectileDef?.GetProperty<Vector3>(EngineEntityProps.SIZE) ?? Vector3.one * 32
        var projectileSize = Vector3.one * 32;
        if (projectileDef != null)
        {
            projectileSize = projectileDef.GetProperty(EngineEntityProps.SIZE);
        }

        var source = self.Position;

        var sizeX:Float = 800;
        var sizeY:Float = 1000;
        var sizeZ = projectileSize.z;
        var centerX = source.x + sizeX * 0.5 * self.GetFacingX();
        var centerY = source.y;
        var centerZ = source.z;
        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
    override function ValidateCollider(self:DetectionParams, collider:IEntityCollider):Bool
    {
        if (!super.ValidateCollider(self, collider))
            return false;
        var target = collider.Entity;
        if (!TargetInLawn(target))
            return false;
        return true;
    }
    private var projectileID:NamespaceID;
}
