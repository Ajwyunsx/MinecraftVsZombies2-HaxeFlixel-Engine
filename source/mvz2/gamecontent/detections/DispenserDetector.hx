// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/DispenserDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2logic.level.LevelPositions;
import pvzengine.NamespaceID;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;

class DispenserDetector extends Detector
{
    public function new() {}
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var direction = reversed ? -1 : 1;

        var shootOffset = self.GetShotOffset();
        shootOffset = self.ModifyShotOffset(shootOffset);
        shootOffset.x *= direction;
        var source = self.Position + shootOffset;

        var projID = projectileID != null ? projectileID : self.GetProjectileID();
        var projectileDefinition = GetEntityDefinition(projID);
        var projectileSize = Vector3.one * 32;
        if (projectileDefinition != null)
        {
            projectileSize = projectileDefinition.GetSize();
            var projectileBoundsPivot = projectileDefinition.GetBoundsPivot();
            source += Vector3.Scale(VanillaEntityProps.SHOT_PIVOT_DEFAULT - self.GetShotPivot(), projectileSize);
        }
        var range = self.GetRange();

        var sizeX = range < 0 ? 800 : range;
        if (direction * self.GetFacingX() > 0)
        {
            var limitedRange = LevelPositions.GetAttackBorderX(true) - source.x;
            sizeX = Mathf.Min(sizeX, limitedRange);
        }
        var centerX = source.x + sizeX * 0.5 * self.GetFacingX() * direction;

        var sizeY:Float;
        var centerY:Float;
        if (ignoreHighEnemy)
        {
            if (ignoreLowEnemy)
            {
                sizeY = projectileSize.y;
                centerY = source.y;
            }
            else
            {
                sizeY = 1000;
                centerY = source.y + projectileSize.y - sizeY * 0.5;
            }
        }
        else
        {
            if (ignoreLowEnemy)
            {
                sizeY = 1000;
                centerY = source.y + sizeY * 0.5;
            }
            else
            {
                sizeY = 1000;
                centerY = source.y;
            }
        }

        var innerZExpansion = innerLaneExpansion * self.Level.GetGridHeight();
        var outerZExpansion = outerLaneExpansion * self.Level.GetGridHeight();
        var sizeZ = projectileSize.z + innerZExpansion + outerZExpansion;
        var centerZ = source.z - innerZExpansion * 0.5 + outerZExpansion * 0.5;


        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
    override function ValidateCollider(self:DetectionParams, collider:IEntityCollider):Bool
    {
        if (!ValidateTarget(self, collider.Entity))
            return false;
        if (colliderFilter != null && !colliderFilter(self, collider))
            return false;
        return true;
    }
    public var ignoreLowEnemy:Bool = false;
    public var ignoreHighEnemy:Bool = false;
    public var reversed:Bool = false;
    public var innerLaneExpansion:Int = 0;
    public var outerLaneExpansion:Int = 0;
    public var projectileID:Null<NamespaceID> = null;
    public var colliderFilter:DetectionParams->IEntityCollider->Bool = null;
}
