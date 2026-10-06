// Ported from: Assets/Scripts/Vanilla/Frameworks/Projectiles/ProjectileHitOutput.cs
package mvz2.vanilla.projectiles;

import pvzengine.armors.Armor;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;

class ProjectileHitOutput
{
    public function new(projectile:Entity, other:Entity, colliderOrShield:Dynamic, ?collider:IEntityCollider, pierce:Bool = false)
    {
        Projectile = projectile;
        Other = other;
        // C# 有两个重载：(Entity, Entity, IEntityCollider, bool) 与 (Entity, Entity, Armor, IEntityCollider, bool)
        if (Std.isOfType(colliderOrShield, IEntityCollider))
        {
            Collider = cast colliderOrShield;
        }
        else
        {
            Shield = cast colliderOrShield;
            Collider = collider;
        }
        Pierce = pierce;
    }

    public var Projectile:Entity;
    public var Other:Entity;
    public var Shield:Null<Armor>;
    public var Collider:IEntityCollider;
    public var Pierce:Bool;
}
