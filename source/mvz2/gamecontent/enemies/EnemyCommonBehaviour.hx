// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/EnemyCommonBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.RandomEnemySpeedBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.armors.LogicArmorSlots;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.buffs.BuffExt;
import pvzengine.damages.DamageOutput;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollisionHelper;
import unity.Mathf;
using mvz2.vanilla.enemies.VanillaEnemyExt;
using mvz2.vanilla.enemies.VanillaEnemyProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.enemyCommon)
class EnemyCommonBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);

        var buff = entity.NewBuff(RandomEnemySpeedBuff);
        RandomEnemySpeedBuff.SetSpeed(buff, entity.RNG.Next(1, 1.5));
        entity.AddBuff(buff);

        entity.CollisionMaskHostile = EntityCollisionHelper.MASK_PLANT
            | EntityCollisionHelper.MASK_ENEMY
            | EntityCollisionHelper.MASK_OBSTACLE
            | EntityCollisionHelper.MASK_BOSS;

        var startingArmor = entity.GetStartingArmor();
        var startingShield = entity.GetStartingShield();
        if (NamespaceID.IsValid(startingArmor))
        {
            entity.EquipMainArmor(startingArmor);
        }
        if (NamespaceID.IsValid(startingShield))
        {
            entity.EquipArmorTo(LogicArmorSlots.shield, startingShield);
        }
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var remove = false;
        if (!entity.IsFacingLeft() && entity.IsEnemyOutsideRight())
        {
            remove = true;
        }
        else if ((entity.Level.IsIZombie() || entity.Level.IsCleared || entity.Level.IsGodMode()) && entity.IsEnemyOutsideLeft())
        {
            remove = true;
        }
        if (remove)
        {
            entity.DropRewards();
            entity.Remove();
            return;
        }

        if (entity.IsFacingLeft())
        {
            if (entity.IsEnemyOutsideRight())
            {
                entity.LimitEnemyFromRight();

                var vel = entity.Velocity;
                vel.x = Mathf.Min(vel.x, 0);
                entity.Velocity = vel;
            }
        }

        if (entity.IsOnGround && !entity.NoAlignToLane())
        {
            entity.CheckAlignToLane();
        }

        var scale = entity.GetFinalDisplayScale();
        var scaleX = Mathf.Abs(scale.x);
        var attackSpeed = entity.GetAttackSpeed() / entity.GetAttackSpeed(true) / scaleX;
        var speed = entity.GetSpeed() / entity.GetSpeed(true) / scaleX;
        if (entity.IsAIFrozen())
        {
            attackSpeed = 0;
            speed = 0;
        }
        entity.SetAnimationFloat("AttackSpeed", attackSpeed);
        entity.SetAnimationFloat("MoveSpeed", speed);
    }
    public override function PostTakeDamage(result:DamageOutput):Void
    {
        super.PostTakeDamage(result);
        var bodyResult = result.BodyResult;
        if (bodyResult != null && bodyResult.Amount > 0 && !bodyResult.HasEffect(VanillaDamageEffects.NO_DAMAGE_BLINK))
        {
            var entity = bodyResult.Entity;
            entity.DamageBlink();
        }
    }
    public override function PostDeath(entity:Entity, damageInfo:DeathInfo):Void
    {
        super.PostDeath(entity, damageInfo);
        if (entity.WillRemoveOnDeath(damageInfo))
        {
            entity.Remove();
            return;
        }
        entity.DamageBlink();
        entity.PlayDeathSound();
    }
}
