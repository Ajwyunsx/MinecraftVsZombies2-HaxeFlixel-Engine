// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/ProjectileRotatingBehaviour.cs
package mvz2.gamecontent.projectiles;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Vector3;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.projectileRotating)
class ProjectileRotatingBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(projectile:Entity):Void
    {
        super.Update(projectile);
        var angleSpeed = -projectile.Velocity.x * 2.5;
        projectile.RenderRotation += Vector3.forward * angleSpeed;
    }
}
