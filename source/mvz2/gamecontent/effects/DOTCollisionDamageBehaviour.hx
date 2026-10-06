// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/DOTCollisionDamageBehaviour.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileProps;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.EngineEntityExt;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.dotCollisionDamage)
class DOTCollisionDamageBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskHostile |= EntityCollisionHelper.MASK_VULNERABLE;
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        var other = collision.Other;
        var self = collision.Entity;
        if (!other.IsVulnerableEntity())
            return;
        if (!self.IsHostile(other))
            return;
        if (state == EntityCollisionHelper.STATE_EXIT)
            return;

        var damage = self.GetDamage();
        var damageEffects = self.GetDamageEffects();
        var effects:DamageEffectList;
        if (damageEffects != null)
        {
            effects = new DamageEffectList(damageEffects);
        }
        else
        {
            effects = new DamageEffectList();
        }
        collision.OtherCollider.TakeDamage(damage, effects, self);
    }
}
