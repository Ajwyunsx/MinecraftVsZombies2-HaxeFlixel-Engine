// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter6/ExplosiveSoul.cs
package mvz2.gamecontent.projectiles;

import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.explosiveSoul)
class ExplosiveSoul extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.Velocity += entity.GetFacingDirection();
    }
}
