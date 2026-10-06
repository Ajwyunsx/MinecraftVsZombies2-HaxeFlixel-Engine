// Ported from: Assets/Scripts/Vanilla/Frameworks/Detection/Detection.cs
package mvz2.vanilla.detection;

import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.collisions.Hitbox;
import pvzengine.collisions.IEntityCollider;
import pvzengine.collisions.level.OverlapParams;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import tools.geometrical.Geometry;
import unity.Bounds;
import unity.Vector3;

class Detection
{
    // C#: extension method Intersects(this Hitbox self, Hitbox other)
    public static function Intersects(self:Hitbox, other:Hitbox):Bool
    {
        var selfBounds = self.GetBounds();
        var otherBounds = other.GetBounds();
        return selfBounds.IntersectsOptimized(otherBounds);
    }
    public static function IntersectsByBounds(center1:Vector3, size1:Vector3, center2:Vector3, size2:Vector3):Bool
    {
        var bounds1 = new Bounds(center1, size1);
        var bounds2 = new Bounds(center2, size2);
        return bounds1.IntersectsOptimized(bounds2);
    }
    public static function CanDetect(entity:Entity):Bool
    {
        return !VanillaEntityProps.IsInvisible(entity);
    }

    // #region X前方（原文件注释为乱码）
    // C#: extension method IsInTheFrontOf(this float x1, float x2, bool x2FaceLeft)
    public static function IsInTheFrontOf(x1:Float, x2:Float, x2FaceLeft:Bool):Bool
    {
        if (x2FaceLeft)
        {
            return x1 < x2;
        }
        else
        {
            return x1 > x2;
        }
    }
    // C#: extension method IsInTheFrontOf(this Entity entity, float x)
    // PORT-NOTE: Haxe has no method overloading; renamed overload to IsInTheFrontOfEntity.
    public static function IsInTheFrontOfEntity(entity:Entity, x:Float):Bool
    {
        if (entity.IsFacingLeft())
        {
            return entity.Position.x < x;
        }
        else
        {
            return entity.Position.x > x;
        }
    }
    // C#: extension method IsInTheFrontOfRange(this Entity entity, float x, float length)
    public static function IsInTheFrontOfRange(entity:Entity, x:Float, length:Float):Bool
    {
        if (entity.IsFacingLeft())
        {
            return entity.Position.x < x && entity.Position.x > x + length;
        }
        else
        {
            return entity.Position.x > x && entity.Position.x < x + length;
        }
    }
    // #endregion

    // #region 实体前方
    // C#: extension method IsAheadOf(this Entity entity, Entity target, float minDistance = 0)
    public static function IsAheadOf(entity:Entity, target:Entity, minDistance:Float = 0):Bool
    {
        if (target.IsFacingLeft())
        {
            return entity.Position.x < target.Position.x - minDistance;
        }
        else
        {
            return entity.Position.x > target.Position.x + minDistance;
        }
    }
    // C#: extension method IsAheadOfRange(this Entity entity, Entity target, float minDistance, float maxDistance)
    public static function IsAheadOfRange(entity:Entity, target:Entity, minDistance:Float, maxDistance:Float):Bool
    {
        if (target.IsFacingLeft())
        {
            return entity.Position.x < target.Position.x - minDistance && entity.Position.x > target.Position.x - maxDistance;
        }
        else
        {
            return entity.Position.x > target.Position.x + minDistance && entity.Position.x < target.Position.x + maxDistance;
        }
    }
    // #endregion

    // #region 列前方
    // C#: extension method IsAheadOfColumn(this Entity entity, int column)
    public static function IsAheadOfColumn(entity:Entity, column:Int):Bool
    {
        if (entity.IsFacingLeft())
        {
            return entity.GetColumn() < column;
        }
        else
        {
            return entity.GetColumn() > column;
        }
    }
    // C#: extension method IsAheadOfOrAtColumn(this Entity entity, int column)
    public static function IsAheadOfOrAtColumn(entity:Entity, column:Int):Bool
    {
        return !IsBehindOfColumn(entity, column);
    }
    // #endregion

    // #region X后方
    // C#: extension method IsInTheRearOf(this float x1, float x2, bool x2FaceLeft)
    public static function IsInTheRearOf(x1:Float, x2:Float, x2FaceLeft:Bool):Bool
    {
        if (x2FaceLeft)
        {
            return x1 > x2;
        }
        else
        {
            return x1 < x2;
        }
    }
    // C#: extension method IsInTheRearOf(this Entity entity, float x)
    // PORT-NOTE: Haxe has no method overloading; renamed overload to IsInTheRearOfEntity.
    public static function IsInTheRearOfEntity(entity:Entity, x:Float):Bool
    {
        if (entity.IsFacingLeft())
        {
            return entity.Position.x > x;
        }
        else
        {
            return entity.Position.x < x;
        }
    }
    // C#: extension method IsInTheRearOfRange(this Entity entity, float x, float length)
    public static function IsInTheRearOfRange(entity:Entity, x:Float, length:Float):Bool
    {
        if (entity.IsFacingLeft())
        {
            return entity.Position.x > x && entity.Position.x < x + length;
        }
        else
        {
            return entity.Position.x < x && entity.Position.x > x + length;
        }
    }
    // #endregion

    // #region 实体后方
    // C#: extension method IsBehindOf(this Entity entity, Entity target, float minDistance = 0)
    public static function IsBehindOf(entity:Entity, target:Entity, minDistance:Float = 0):Bool
    {
        if (target.IsFacingLeft())
        {
            return entity.Position.x > target.Position.x - minDistance;
        }
        else
        {
            return entity.Position.x < target.Position.x + minDistance;
        }
    }
    // C#: extension method IsBehindOfRange(this Entity entity, Entity target, float minDistance, float maxDistance)
    public static function IsBehindOfRange(entity:Entity, target:Entity, minDistance:Float, maxDistance:Float):Bool
    {
        if (target.IsFacingLeft())
        {
            return entity.Position.x > target.Position.x - minDistance && entity.Position.x < target.Position.x - maxDistance;
        }
        else
        {
            return entity.Position.x < target.Position.x + minDistance && entity.Position.x > target.Position.x + maxDistance;
        }
    }
    // #endregion

    // #region 列后方
    // C#: extension method IsBehindOfColumn(this Entity entity, int column)
    public static function IsBehindOfColumn(entity:Entity, column:Int):Bool
    {
        if (entity.IsFacingLeft())
        {
            return entity.GetColumn() > column;
        }
        else
        {
            return entity.GetColumn() < column;
        }
    }
    // C#: extension method IsBehindOfOrAtColumn(this Entity entity, int column)
    public static function IsBehindOfOrAtColumn(entity:Entity, column:Int):Bool
    {
        return !IsAheadOfColumn(entity, column);
    }
    // #endregion

    // #region X related
    public static function IsXCoincide(x1:Float, xLength1:Float, x2:Float, xLength2:Float):Bool
    {
        var extent1 = xLength1 / 2;
        var extent2 = xLength2 / 2;
        return Geometry.DoRangesIntersect(x1 - extent1, x1 + extent1, x2 - extent2, x2 + extent2);
    }
    // #endregion

    // #region Y related
    // C#: extension method CoincidesYDown(this Bounds bounds, float y)
    public static function CoincidesYDown(bounds:Bounds, y:Float):Bool
    {
        return bounds.min.y < y;
    }
    // C#: extension method CoincidesYUp(this Bounds bounds, float y)
    public static function CoincidesYUp(bounds:Bounds, y:Float):Bool
    {
        return bounds.max.y > y;
    }
    public static function IsYCoincide(y1:Float, yLength1:Float, y2:Float, yLength2:Float):Bool
    {
        return Geometry.DoRangesIntersect(y1, y1 + yLength1, y2, y2 + yLength2);
    }
    // #endregion

    // #region Z related
    public static function IsInSameRow(self:Entity, other:Entity):Bool
    {
        return self.GetLane() == other.GetLane();
    }
    public static function IsZCoincide(z1:Float, zLength1:Float, z2:Float, zLength2:Float):Bool
    {
        var extent1 = zLength1 / 2;
        var extent2 = zLength2 / 2;
        return Geometry.DoRangesIntersect(z1 - extent1, z1 + extent1, z2 - extent2, z2 + extent2);
    }
    // #endregion

    // C#: extension method OverlapGridGroundNonAlloc(this LevelEngine level, int column, int lane, OverlapParams param, List<IEntityCollider> results)
    public static function OverlapGridGroundNonAlloc(level:LevelEngine, column:Int, lane:Int, param:OverlapParams, results:Array<IEntityCollider>):Void
    {
        var sizeX = level.GetGridWidth();
        var sizeY = 200;
        var sizeZ = level.GetGridHeight();
        var minX = level.GetColumnX(column);
        var minZ = level.GetEntityLaneZ(lane) - sizeZ * 0.5;
        var centerX = minX + sizeX * 0.5;
        var centerZ = minZ + sizeZ * 0.5;
        var centerY = level.GetGroundY(centerX, centerZ) - sizeY * 0.5;
        var center = new Vector3(centerX, centerY, centerZ);
        var size = new Vector3(sizeX, sizeY, sizeZ);
        level.OverlapBoxNonAlloc(center, size, param, results);
    }
}
