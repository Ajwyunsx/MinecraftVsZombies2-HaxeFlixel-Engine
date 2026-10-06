// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter1/FlyingTNT.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.contraptions.TNT;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.flyingTNT)
class FlyingTNT extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskHostile = 0;
        entity.CollisionMaskFriendly = 0;
    }
    public override function Update(projectile:Entity):Void
    {
        super.Update(projectile);
        if (projectile.GetRelativeY() <= 0)
        {
            var range = projectile.GetRange();
            var damage = projectile.GetDamage();
            TNT.ExplodeStatic(projectile, range, damage);
            projectile.Remove();
        }
    }
}
