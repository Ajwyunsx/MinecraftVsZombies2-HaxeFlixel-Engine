// Ported from: Assets/Scripts/Vanilla/Frameworks/Projectiles/VanillaProjectileProps.cs
package mvz2.vanilla.projectiles;

import pvzengine.NamespaceID;
import pvzengine.PropertyMeta;
import pvzengine.PropertyRegions;
import pvzengine.collisions.EntityColliderReference;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;

@:propertyRegistryRegion(PropertyRegions.entity)
class VanillaProjectileProps
{
    public static var ROLLS:PropertyMeta<Bool> = new PropertyMeta<Bool>("rolls");
    // C#: extension method Rolls(this Entity entity)
    public static function Rolls(entity:Entity):Bool
    {
        return entity.GetProperty(ROLLS);
    }
    public static var KILL_ON_GROUND:PropertyMeta<Bool> = new PropertyMeta<Bool>("killOnGround");
    // C#: extension method KillOnGround(this Entity entity)
    public static function KillOnGround(entity:Entity):Bool
    {
        return entity.GetProperty(KILL_ON_GROUND);
    }

    public static var POINT_TO_DIRECTION:PropertyMeta<Bool> = new PropertyMeta<Bool>("pointToDirection");
    // C#: extension method PointsTowardDirection(this Entity entity)
    public static function PointsTowardDirection(entity:Entity):Bool
    {
        return entity.GetProperty(POINT_TO_DIRECTION);
    }
    public static var NO_DESTROY_OUTSIDE_LAWN:PropertyMeta<Bool> = new PropertyMeta<Bool>("noDestroyOutsideLawn");
    // C#: extension method WillDestroyOutsideLawn(this Entity projectile)
    public static function WillDestroyOutsideLawn(projectile:Entity):Bool
    {
        return !projectile.GetProperty(NO_DESTROY_OUTSIDE_LAWN);
    }
    public static var PIERCING:PropertyMeta<Bool> = new PropertyMeta<Bool>("piercing");
    // C#: extension method IsPiercing(this Entity projectile)
    public static function IsPiercing(projectile:Entity):Bool
    {
        return projectile.GetProperty(PIERCING);
    }
    // C#: extension method SetPiercing(this Entity projectile, bool value)
    public static function SetPiercing(projectile:Entity, value:Bool):Void
    {
        projectile.SetProperty(PIERCING, value);
    }
    // #region 忽略护盾
    public static var IGNORE_SHIELDS:PropertyMeta<Bool> = new PropertyMeta<Bool>("ignore_shields");
    // C#: extension method IgnoreShields(this Entity projectile)
    public static function IgnoreShields(projectile:Entity):Bool
    {
        return projectile.GetProperty(IGNORE_SHIELDS);
    }
    // C#: extension method SetIgnoreShields(this Entity projectile, bool value)
    public static function SetIgnoreShields(projectile:Entity, value:Bool):Void
    {
        projectile.SetProperty(IGNORE_SHIELDS, value);
    }
    // #endregion
    public static var DAMAGE_EFFECTS:PropertyMeta<Array<NamespaceID>> = new PropertyMeta<Array<NamespaceID>>("damageEffects");
    // C#: extension method GetDamageEffects(this Entity projectile)
    public static function GetDamageEffects(projectile:Entity):Null<Array<NamespaceID>>
    {
        return projectile.GetProperty(DAMAGE_EFFECTS);
    }
    public static var NO_HIT_ENTITIES:PropertyMeta<Bool> = new PropertyMeta<Bool>("noHitEntities");
    // C#: extension method DontHitEntities(this Entity projectile)
    public static function DontHitEntities(projectile:Entity):Bool
    {
        return projectile.GetProperty(NO_HIT_ENTITIES);
    }
    public static var IGNORED_COLLIDERS:PropertyMeta<Array<EntityColliderReference>> = new PropertyMeta<Array<EntityColliderReference>>("ignoredColliders");
    // C#: extension method AddIgnoredProjectileCollider(this Entity projectile, IEntityCollider other)
    public static function AddIgnoredProjectileCollider(projectile:Entity, other:IEntityCollider):Void
    {
        var colliders = projectile.GetBehaviourField(IGNORED_COLLIDERS);
        if (colliders == null)
        {
            colliders = [];
            projectile.SetBehaviourField(IGNORED_COLLIDERS, colliders);
        }
        var reference = other.ToReference();
        if (colliders.indexOf(reference) >= 0)
            return;
        colliders.push(reference);
    }
    // C#: extension method RemoveIgnoredProjectileCollider(this Entity projectile, IEntityCollider other)
    public static function RemoveIgnoredProjectileCollider(projectile:Entity, other:IEntityCollider):Void
    {
        var colliders = projectile.GetBehaviourField(IGNORED_COLLIDERS);
        if (colliders == null)
        {
            return;
        }
        var reference = other.ToReference();
        colliders.remove(reference);
    }
    // C#: extension method IsProjectileColliderIgnored(this Entity projectile, IEntityCollider other)
    public static function IsProjectileColliderIgnored(projectile:Entity, other:IEntityCollider):Bool
    {
        var colliders = projectile.GetBehaviourField(IGNORED_COLLIDERS);
        if (colliders == null)
        {
            return false;
        }
        var reference = other.ToReference();
        return colliders.indexOf(reference) >= 0;
    }
    // C#: extension method ClearIgnoredProjectileColliders(this Entity projectile)
    public static function ClearIgnoredProjectileColliders(projectile:Entity):Void
    {
        var colliders = projectile.GetBehaviourField(IGNORED_COLLIDERS);
        if (colliders == null)
        {
            return;
        }
        colliders.resize(0);
    }
}
