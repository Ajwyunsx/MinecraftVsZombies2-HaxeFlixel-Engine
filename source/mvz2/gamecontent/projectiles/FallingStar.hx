// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter5/FallingStar.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.effects.VanillaEffectID;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Vector3;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.fallingStar)
class FallingStar extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostContactGround(entity:Entity, velocity:Vector3):Void
    {
        super.PostContactGround(entity, velocity);
        entity.Spawn(VanillaEffectID.starParticles, entity.Position);
    }
}
