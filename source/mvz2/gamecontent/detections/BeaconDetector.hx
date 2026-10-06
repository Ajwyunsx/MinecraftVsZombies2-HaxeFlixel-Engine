// Ported from: Assets/Scripts/Vanilla/GameContent/Detections/BeaconDetector.cs
package mvz2.gamecontent.detections;

import mvz2.gamecontent.contraptions.Beacon;
import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2logic.level.LevelPositions;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import unity.Bounds;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;

class BeaconDetector extends Detector
{
    public function new() {}
    override function GetDetectionBounds(self:Entity):Bounds
    {
        var source = self.GetShootPoint();

        var projectileSize = GetProjectileSize(self, Vector3.one * 32);

        var minX = 0;
        var maxX = LevelPositions.LEVEL_WIDTH;
        var minZ = 0;
        var maxZ = LevelPositions.LAWN_HEIGHT;
        var sizeY:Float = 800;
        sizeY = 1000;
        var center = self.GetCenter();
        center.x = (minX + maxX) * 0.5;
        center.y = source.y + projectileSize.y - sizeY * 0.5;
        center.z = (minZ + maxZ) * 0.5;
        return new Bounds(center, new Vector3(maxX - minX, sizeY, maxZ - minZ));
    }
    override function ValidateCollider(param:DetectionParams, collider:IEntityCollider):Bool
    {
        var self = param.entity;
        if (!ValidateTarget(param, collider.Entity))
            return false;
        var shootOffset = self.GetShotOffset();
        shootOffset = self.ModifyShotOffset(shootOffset);
        var source = self.Position + shootOffset;
        var range = self.GetRange();

        var projectileSize = GetProjectileSize(self, Vector3.one * 32);
        var radius = Mathf.Max(Mathf.Max(projectileSize.x, projectileSize.y), projectileSize.z) * 0.5;

        var targetBounds = collider.GetBoundingBox();
        for (direction in Beacon.shootDirections)
        {
            // PORT-NOTE: C# 的 Vector3 为值类型，`var dir = direction;` 是副本；
            // Haxe 的 unity.Vector3 底层为引用对象，需显式复制以免修改到 Beacon.shootDirections。
            var dir = new Vector3(direction.x, direction.y, direction.z);
            dir.x *= self.GetFacingX();
            var destination = dir * range + source;
            // PORT-NOTE: 原代码使用外部程序集 Tools.Geometrical 的 Capsule 与
            // Geometry.CollideBetweenCubeAndCapsule，此处以等价的「线段到包围盒最近点距离」判定实现。
            if (CollideBetweenCubeAndCapsule(source, destination, radius, targetBounds))
            {
                return true;
            }
        }
        return false;
    }
    // PORT-NOTE: Tools.Geometrical.Geometry.CollideBetweenCubeAndCapsule 的最小实现。
    static function CollideBetweenCubeAndCapsule(pos1:Vector3, pos2:Vector3, radius:Float, bounds:Bounds):Bool
    {
        var closest = ClosestPointOnSegment(pos1, pos2, bounds.center);
        var point = bounds.ClosestPoint(closest);
        return Vector3.Distance(closest, point) <= radius;
    }
    static function ClosestPointOnSegment(a:Vector3, b:Vector3, point:Vector3):Vector3
    {
        var ab = b - a;
        var abSqr = Vector3.Dot(ab, ab);
        if (abSqr <= 0)
            return a;
        var t = Mathf.Clamp01(Vector3.Dot(point - a, ab) / abSqr);
        return a + ab * t;
    }
}
