// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter1/MummyGas.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.mummyGas)
class MummyGas extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskHostile |=
            EntityCollisionHelper.MASK_PLANT |
            EntityCollisionHelper.MASK_ENEMY |
            EntityCollisionHelper.MASK_BOSS |
            EntityCollisionHelper.MASK_OBSTACLE |
            EntityCollisionHelper.MASK_PROJECTILE |
            EntityCollisionHelper.MASK_EFFECT;
        entity.CollisionMaskFriendly |=
            EntityCollisionHelper.MASK_PLANT |
            EntityCollisionHelper.MASK_ENEMY |
            EntityCollisionHelper.MASK_BOSS |
            EntityCollisionHelper.MASK_OBSTACLE |
            EntityCollisionHelper.MASK_PROJECTILE |
            EntityCollisionHelper.MASK_EFFECT;
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        var entity = collision.Entity;
        var other = collision.Other;
        if (state == EntityCollisionHelper.STATE_EXIT)
            return;
        if (GasBehaviour.IsDisappearing(entity))
            return;
        if (other.IsFire())
        {
            entity.PlaySound(VanillaSoundID.fire);
            GasBehaviour.Disappear(entity);
            var burningGas = entity.Level.Spawn(VanillaEffectID.burningGas, entity.Position, entity);
            if (burningGas != null)
            {
                burningGas.SetSize(entity.GetSize());
            }

            Burn(entity);
            return;
        }
        if (!other.IsVulnerableEntity() || other.IsDead)
            return;
        if (other.IsUndead())
        {
            other.HealEffects(entity.GetDamage(), entity);
        }
        else if (entity.IsHostile(other))
        {
            var damageEffects = new DamageEffectList([VanillaDamageEffects.IGNORE_ARMOR, VanillaDamageEffects.MUTE]);
            other.TakeDamage(entity.GetDamage(), damageEffects, entity);
        }
    }
    private function Burn(gas:Entity):Void
    {
        collisionBuffer.resize(0);
        gas.GetCurrentCollisions(collisionBuffer);
        for (collision in collisionBuffer)
        {
            if (!collision.Entity.IsVulnerableEntity())
                continue;
            if (gas.IsHostile(collision.Entity))
                continue;
            var damageEffectList = new DamageEffectList([VanillaDamageEffects.FIRE]);
            var other = collision.Other;
            var otherCollider = collision.OtherCollider;
            otherCollider.TakeDamage(100, damageEffectList, gas);
        }
    }
    // #endregion

    private var collisionBuffer:Array<EntityCollision> = [];
}
