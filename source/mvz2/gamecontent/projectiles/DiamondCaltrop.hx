// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter3/DiamondCaltrop.cs
package mvz2.gamecontent.projectiles;

import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Vector3;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.diamondCaltrop)
class DiamondCaltrop extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostContactGround(entity:Entity, velocity:Vector3):Void
    {
        super.PostContactGround(entity, velocity);
        var vel = entity.Velocity;
        vel.y = -velocity.y * 0.2;
        entity.Velocity = vel;
    }
}
