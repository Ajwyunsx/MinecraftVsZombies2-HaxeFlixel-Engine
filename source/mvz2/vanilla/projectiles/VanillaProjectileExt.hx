// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/VanillaProjectileExt.cs
// PORT-NOTE: 同文件的 C# STRUCT ShootParams 已由核心工作包移植为独立的 ShootParams.hx。
package mvz2.vanilla.projectiles;

import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.level.LevelPositions;
import pvzengine.NamespaceID;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import unity.Mathf;
import unity.Vector2;
import unity.Vector3;

// PORT-NOTE: C# 的扩展方法在本移植中为静态方法；调用点沿用扩展方法风格，故以 `using` 引入对应模块。
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2.vanilla.projectiles.VanillaProjectileProps;
using mvz2logic.entities.LogicEntityExt;
using pvzengine.entities.EngineEntityExt;

class VanillaProjectileExt
{
    // C#: extension method ShootProjectile(this Entity entity)
    // C#: extension method ShootProjectile(this Entity entity, NamespaceID? projectileID)
    // C#: extension method ShootProjectile(this Entity entity, NamespaceID? projectileID, Vector3 velocity)
    // C#: extension method ShootProjectile(this Entity entity, ShootParams parameters)
    // PORT-NOTE: Haxe 不支持重载，四个重载合并为一个方法：
    //   param1 为 null 时等价于无参重载；为 ShootParams 时等价于 ShootParams 重载；
    //   其余情况视为 NamespaceID，配合可选的 velocity 参数等价于另外两个重载。
    public static function ShootProjectile(entity:Entity, ?param1:Dynamic, ?velocity:Null<Vector3>):Null<Entity>
    {
        var shootParams:ShootParams;
        if (param1 == null)
        {
            shootParams = GetShootParams(entity);
        }
        else if (Std.isOfType(param1, ShootParams))
        {
            shootParams = cast param1;
        }
        else
        {
            shootParams = GetShootParams(entity);
            shootParams.projectileID = cast param1;
            if (velocity != null)
            {
                shootParams.velocity = velocity;
            }
        }
        return ShootProjectileWithParams(entity, shootParams);
    }
    // C#: extension method ShootProjectile(this Entity entity, ShootParams parameters)
    // PORT-NOTE: Haxe 不支持重载，重命名为 ShootProjectileWithParams。
    public static function ShootProjectileWithParams(entity:Entity, parameters:ShootParams):Null<Entity>
    {
        if (parameters.soundID != null)
            entity.PlaySound(parameters.soundID);
        var projectileID = parameters.projectileID;
        if (projectileID == null)
            return null;
        var projectileDefinition = entity.Level.Content.GetEntityDefinition(projectileID);
        if (projectileDefinition == null)
            return null;

        var velocity = VanillaEntityExt.ModifyProjectileVelocity(entity, parameters.velocity);
        var position = parameters.position;
        var projectileSize = projectileDefinition.GetSize();
        var projectileBoundsPivot = projectileDefinition.GetBoundsPivot();
        position += Vector3.Scale(projectileBoundsPivot - parameters.pivot, projectileSize);

        var param = parameters.spawnParam;
        param.SetProperty(VanillaEntityProps.DAMAGE, parameters.damage);
        param.SetProperty(EngineEntityProps.FACTION, parameters.faction);
        // C#: entity.Spawn(projectileDefinition, position, param)?.Let(e => { ... })
        var projectile = entity.Spawn(projectileDefinition, position, param);
        if (projectile != null)
        {
            projectile.Velocity = velocity;
            projectile.UpdatePointTowardsDirection();
            entity.Level.Triggers.RunCallbackFiltered(VanillaLevelCallbacks.POST_PROJECTILE_SHOT, new EntityCallbackParams(projectile), projectile.GetDefinitionID());
        }
        return projectile;
    }
    // C#: extension method GetShootParams(this Entity entity)
    public static function GetShootParams(entity:Entity):ShootParams
    {
        var velocity = entity.GetShotVelocity();
        velocity.x *= entity.GetFacingX();
        var parameters = new ShootParams();
        parameters.projectileID = entity.GetProjectileID();
        parameters.position = entity.GetShootPoint();
        parameters.pivot = entity.GetShotPivot();
        parameters.faction = entity.GetFaction();
        parameters.damage = entity.GetDamage();
        parameters.soundID = entity.GetShootSound();
        parameters.velocity = velocity;
        parameters.spawnParam = entity.GetSpawnParams();
        return parameters;
    }
    // C#: extension method ModifyShotOffset(this Entity entity, Vector3 offset)
    public static function ModifyShotOffset(entity:Entity, offset:Vector3):Vector3
    {
        offset.x *= entity.GetFacingX();
        return offset;
    }
    // C#: extension method GetShootPoint(this Entity entity)
    public static function GetShootPoint(entity:Entity):Vector3
    {
        var offset = entity.GetShotOffset();
        offset = ModifyShotOffset(entity, offset);
        return entity.Position + offset;
    }
    // C#: extension method UpdatePointTowardsDirection(this Entity entity)
    public static function UpdatePointTowardsDirection(entity:Entity):Void
    {
        if (entity.PointsTowardDirection())
        {
            var vel = new Vector2(entity.Velocity.x, entity.Velocity.y + entity.Velocity.z);
            entity.RenderRotation = Vector3.forward * Vector2.SignedAngle(Vector2.right, vel);
        }
    }
    public static function GetLobVelocity(source:Vector3, target:Vector3, maxY:Float, gravity:Float, passesMaxY:Bool = true):Vector3
    {
        //问题：已知y = a[(x - h)]^2 + k经过原点，求h。

        //其中，x为点的x值，y为点的y值，a为偏曲率，h为抛物线对称轴，k为最大高度。
        //因为抛物线经过原点，故得：
        //0 = a(-h) ^ 2 + k
        //0 = ah ^ 2 + k
        //a = -k / h ^ 2

        //将a = -k / h ^ 2 代入y = a[(x - h)]^2 + k，得：
        //y = (-k/h^2) * (x-h)^2 + k
        //y = (-k/h^2) * (x^2 - 2xh + h^2) + k
        //y = -k * (x^2 - 2xh + h^2) / h^2 + k
        //y = (-kx^2 + 2kxh - kh^2) / h^2 + k
        //y = -kx^2/h^2 + 2kx/h - k + k
        //y = -kx^2/h^2 + 2kx/h
        //y = (-kx^2 + 2kxh)/
        //yh^2 = -kx^2 + 2kxh
        //yh^2 - 2kxh + kx^2 = 0

        //通过二次函数求根公式x = (-b±√(b^2 - 4ac))/ (2a)可得：
        //h = (2kx±√(4k^2x^2 - 4kx^2y))/ 2y
        //h = (kx±√(x^2 * (k^2 - k*y)))/ y

        //当y = 0时，h = x / 2
        //其中，如果点(x, y)在靠近Y轴一侧，则
        //h = (kx+√(x^2 * (k^2 - k*y)))/ y
        //如果点在(x, y)在远离Y轴一侧，则
        //h = (kx-√(x^2 * (k^2 - k*y)))/ y

        //当k > 0时，函数向下开口，y≤k
        //当k < 0时，函数向上开口，y≥k
        //当k = 0时，h不存在
        //当x = 0时，函数在x = 0上有无数个值

        var relativePosition = target - source;
        var k = maxY - source.y;
        if (k > 0)
        {
            if (relativePosition.y > k)
                throw "If maxY is positive, it must be greater than target.y.";
            if (gravity < 0)
                throw "If maxY is positive, the gravity must be positive.";
        }
        else if (k < 0)
        {
            if (relativePosition.y > k)
                throw "If maxY is negative, it must be less than target.y.";
            if (gravity < 0)
                throw "If maxY is negative, the gravity must be negative.";
        }
        else
        {
            throw "MaxY cannot be equal to source.y.";
        }

        var horiVector = new Vector2(relativePosition.x, relativePosition.z);
        var horiDirection = horiVector.normalized;
        var length = horiVector.magnitude;
        var highestLength:Float;
        var sign = passesMaxY ? -1 : 1;
        if (Mathf.Approximately(relativePosition.y, 0))
        {
            highestLength = length * 0.5;
        }
        else
        {
            var sqrMaxY = Mathf.Pow(k, 2);
            var sqrLength = Mathf.Pow(length, 2);
            var factor = Mathf.Sqrt(sqrLength * (sqrMaxY - k * relativePosition.y));
            highestLength = (k * length + sign * factor) / relativePosition.y;
        }
        // 到达最高点t帧过后的y速度y1 = -gt
        // 到达最高点t帧过后的y位置 = k + y1 * (1 + t) / 2
        // 按照目标的最终y位置求出到达最高点后的时间。
        var a = -gravity / 2;
        var b = 0;
        var c = k - relativePosition.y;
        var fallTime = (-b + sign * Mathf.Sqrt(b * b - 4 * a * c)) / (2 * a);
        // 根据后半段时间求出总时间。
        var fallPercent = (length - highestLength) / length;
        var totalTime = fallTime / fallPercent;
        var ascendTime = totalTime - fallTime;

        // 根据总时间获取水平移速。
        var velHori = length / totalTime;

        // 到达最高点的y位置 k = y1 + g * (1 + t) / 2
        // 所以 y1 = k - g * (1 + t) / 2
        // 获取垂直移速y1。
        var velVert = gravity * ascendTime;

        var hori = horiDirection * velHori;
        return new Vector3(hori.x, velVert, hori.y);
    }
    public static function GetLobVelocityByTime(source:Vector3, target:Vector3, maxTime:Float, gravity:Float):Vector3
    {
        var x:Float;
        var y:Float;
        var z:Float;
        x = (target.x - source.x) / maxTime;
        y = (target.y - source.y) / maxTime + gravity * maxTime * 0.5;
        z = (target.z - source.z) / maxTime;
        return new Vector3(x, y, z);
    }

    // #region 出屏幕
    // C#: extension method IsProjectileOutsideView(this Entity proj)
    public static function IsProjectileOutsideView(proj:Entity):Bool
    {
        var bounds = proj.GetBounds();
        var position = proj.Position;
        return bounds.max.x < LevelPositions.PROJECTILE_LEFT_BORDER ||
            bounds.min.x > LevelPositions.PROJECTILE_RIGHT_BORDER ||
            position.z > LevelPositions.PROJECTILE_UP_BORDER ||
            position.z < LevelPositions.PROJECTILE_DOWN_BORDER ||
            position.y > LevelPositions.PROJECTILE_TOP_BORDER ||
            position.y < LevelPositions.PROJECTILE_BOTTOM_BORDER;
    }
    // #endregion
}
