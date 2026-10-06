// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/GravityPadDetector.cs
package mvz2.gamecontent.detections;

import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaColliderExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.collisions.FactionTarget;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import unity.Bounds;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaColliderExt;

class GravityPadDetector extends Detector
{
    public function new(forEnemy:Bool, affectHeight:Float)
    {
        canDetectInvisible = true;
        if (forEnemy)
        {
            mask = EntityCollisionHelper.MASK_ENEMY;
            factionTarget = cast FactionTarget.Hostile;
        }
        else
        {
            mask = EntityCollisionHelper.MASK_PROJECTILE;
            factionTarget = cast FactionTarget.Friendly;
        }
        this.affectHeight = affectHeight;
    }
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var padSize = self.GetScaledSize();
        var sizeX = padSize.x;
        var sizeY = affectHeight;
        var sizeZ = padSize.z;
        var source = self.Position;
        var centerX = source.x;
        var centerY = source.y + sizeY * 0.5;
        var centerZ = source.z;
        return new Bounds(new Vector3(centerX, centerY, centerZ), new Vector3(sizeX, sizeY, sizeZ));
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        if (!collider.IsForMain())
            return false;
        var target = collider.Entity;
        if (target == null)
            return false;
        if (target.IsDead)
            return false;
        if (!target.IsFactionTargetFaction(param.faction, factionTarget))
            return false;
        if (target.Type == EntityTypes.PROJECTILE)
        {
            return target.Position.y > param.entity.Position.y + MIN_HEIGHT;
        }
        return true;
    }
    public static inline var MIN_HEIGHT:Float = 5;
    public var affectHeight:Float;
}
