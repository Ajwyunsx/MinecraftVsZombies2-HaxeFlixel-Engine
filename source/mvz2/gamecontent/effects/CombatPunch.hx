// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/CombatPunch.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaColliderExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LevelPositions;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.EntityTypes;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.projectiles.VanillaProjectileProps;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.combatPunch)
class CombatPunch extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskHostile |= EntityCollisionHelper.MASK_VULNERABLE;
        entity.Velocity = entity.GetFacingDirection() * 60;
        // C#: entity.Spawn(...)?.Let(e => { e.SetParent(entity); })
        var trail = entity.Spawn(VanillaEffectID.combatPunchTrail, entity.Position);
        if (trail != null)
        {
            trail.SetParent(entity);
        }
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var position = entity.Position;
        position.y = entity.GetGroundY();
        entity.Position = position;
        if (entity.Position.x >= LevelPositions.LEVEL_RIGHTMOST)
        {
            entity.Remove();
        }
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        var entity = collision.Entity;
        var collider = collision.OtherCollider;
        var other = collision.Other;
        if (state != EntityCollisionHelper.STATE_EXIT)
        {
            if (entity.IsHostile(other) && other.IsVulnerableEntity())
            {
                if (!entity.IsProjectileColliderIgnored(collider))
                {
                    entity.AddIgnoredProjectileCollider(collider);

                    var faction = entity.GetFaction();
                    var damage = entity.GetDamage();
                    var damageEffects = new DamageEffectList([VanillaDamageEffects.IMPACT, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN]);
                    collider.TakeDamage(damage, damageEffects, entity);
                    Explosion.Spawn(entity, collider.GetBoundingBox().center, 20);
                    entity.PlaySound(VanillaSoundID.punch);
                    entity.PlaySound(VanillaSoundID.impact);
                    entity.Level.ShakeScreen(10, 0, 15);

                    if (collider.IsForMain() && other.Type == EntityTypes.ENEMY)
                    {
                        var knockbackMultiplier = other.GetStrongKnockbackMultiplier();
                        other.Velocity += entity.GetFacingDirection() * (40 * knockbackMultiplier) + Vector3.up * (20 * knockbackMultiplier);

                        other.ApplyStrongImpact();
                    }
                }
            }
        }
        else
        {
            entity.RemoveIgnoredProjectileCollider(collider);
        }
    }
}
