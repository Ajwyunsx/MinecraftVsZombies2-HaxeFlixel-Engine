// Ported from: Assets/Scripts/Vanilla/Frameworks/Projectiles/ProjectileHitInput.cs
package mvz2.vanilla.projectiles;

import pvzengine.entities.Entity;

class ProjectileHitInput
{
    public function new(projectile:Entity, other:Entity, pierce:Bool = false)
    {
        Projectile = projectile;
        Other = other;
        Pierce = pierce;
    }

    public var Projectile:Entity;
    public var Other:Entity;
    public var Pierce:Bool;
}
