// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Explode/ProjectileExplodeBehaviour_Meteor.cs
package mvz2.gamecontent.projectiles;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.projectileExplodeMeteor)
class ProjectileExplodeBehaviour_Meteor extends ProjectileExplodeBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Explode(entity:Entity):Void
    {
        super.Explode(entity);
        entity.Level.ShakeScreen(10, 0, 15);
    }
    public override function PlayExplosionSound(entity:Entity):Void
    {
        entity.PlaySound(VanillaSoundID.meteorLand);
    }
}
