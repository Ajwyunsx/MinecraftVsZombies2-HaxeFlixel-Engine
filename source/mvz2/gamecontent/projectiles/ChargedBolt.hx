// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter4/ChargedBolt.cs
package mvz2.gamecontent.projectiles;

import mvz2.vanilla.audios.VanillaSoundID;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.chargedBolt)
class ChargedBolt extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Level.AddLoopSoundEntity(VanillaSoundID.chargedBolt, entity.ID);
        entity.SetAnimationFloat("Speed", entity.RNG.NextFloat() * 1.5 + 0.5);
    }
    public override function Update(projectile:Entity):Void
    {
        super.Update(projectile);
        var vel = projectile.Velocity;
        vel.z = projectile.RNG.Next(-1, 2) * 5;
        projectile.Velocity = vel;
    }
}
