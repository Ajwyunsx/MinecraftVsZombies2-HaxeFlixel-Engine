// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter5/ElasticCloudEvocationBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.effects.Explosion;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.buffs.Buff;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.collisions.level.OverlapParams;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.EntityTypes;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2logic.entities.LogicEntityExt;

@:autoBuffDefinition(VanillaBuffNames.Contraption_elasticCloudEvocation)
class ElasticCloudEvocationBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
        AddModifier(new FloatModifier(EngineEntityProps.GRAVITY, NumberOperator.Multiply, 3));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        if (entity.IsOnGround)
        {
            var center = entity.Position;
            var faction = entity.GetFaction();
            var radius:Float = 200;
            var level = entity.Level;
            var overlapParam = OverlapParams.Hostile(faction, EntityCollisionHelper.MASK_VULNERABLE | EntityCollisionHelper.MASK_PROJECTILE);
            for (entityCollider in level.OverlapSphere(center, radius, overlapParam))
            {
                if (!entityCollider.IsMainCollider())
                    continue;
                var target = entityCollider.Entity;
                if (target.Type == EntityTypes.ENEMY)
                {
                    var knockbackMultiplier = VanillaEntityProps.GetStrongKnockbackMultiplier(target);
                    target.Velocity = target.Velocity + VanillaEntityExt.GetFacingDirection(entity) * (10 * knockbackMultiplier) + Vector3.up * (20 * knockbackMultiplier);

                    VanillaEntityExt.ApplyStrongImpact(target);
                }
                else if (target.Type == EntityTypes.PROJECTILE)
                {
                    // 击退射弹，并将其阵营变为被引爆的实体的阵营
                    var velocity = VanillaEntityExt.GetFacingDirection(target) * target.Velocity.magnitude;
                    target.Velocity = velocity;
                    target.SetFaction(entity.GetFaction());
                }
            }
            Explosion.Spawn(entity, center, radius);
            entity.PlaySound(VanillaSoundID.explosion);
            VanillaEntityExt.DestroyConflictGridEntities(entity);
            buff.Remove();
        }
    }
}
