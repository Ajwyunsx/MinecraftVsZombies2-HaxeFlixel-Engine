// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/CombatUppercut.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaColliderExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.collisions.IEntityCollider;
import pvzengine.collisions.level.OverlapParams;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.EntityTypes;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.combatUppercut)
class CombatUppercut extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Velocity = Vector3.up * 30;
        // C#: entity.Spawn(...)?.Let(e => { e.SetParent(entity); })
        var trail = entity.Spawn(VanillaEffectID.combatUppercutTrail, entity.Position);
        if (trail != null)
        {
            trail.SetParent(entity);
        }

        var faction = entity.GetFaction();
        var radius = entity.GetRange();
        var damage = entity.GetDamage();
        var direction = entity.GetFacingDirection();
        var bounds = entity.GetBounds();
        var position = entity.GetBounds().center;
        position.y = bounds.max.y;
        var damageEffects = new DamageEffectList([VanillaDamageEffects.IMPACT, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN]);
        var level = entity.Level;
        var overlapParam = OverlapParams.Hostile(faction, EntityCollisionHelper.MASK_VULNERABLE);
        for (entityCollider in level.OverlapSphere(position, radius, overlapParam))
        {
            entityCollider.TakeDamage(damage, damageEffects, entity);
            var target = entityCollider.Entity;
            target.PlaySound(VanillaSoundID.punch);
            target.PlaySound(VanillaSoundID.impact);
            entity.Level.ShakeScreen(10, 0, 15);
            if (entityCollider.IsForMain() && target.Type == EntityTypes.ENEMY)
            {
                var knockbackMultiplier = target.GetStrongKnockbackMultiplier();
                target.Velocity += direction * (10 * knockbackMultiplier) + Vector3.up * (20 * knockbackMultiplier);

                target.ApplyStrongImpact();
            }
        }
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.Velocity = entity.Velocity * 0.8;
    }
}
