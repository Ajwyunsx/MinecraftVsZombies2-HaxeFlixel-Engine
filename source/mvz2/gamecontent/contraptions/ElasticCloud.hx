// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter5/ElasticCloud/ElasticCloud.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.contraptions.ElasticCloudBounceCooldownBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.buffs.Buff;
import pvzengine.buffs.BuffExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DamageInput;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.EntitySourceReference;
import pvzengine.entities.EntityTypes;
import tools.Ticks;
using mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.elasticCloud)
class ElasticCloud extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskHostile |= EntityCollisionHelper.MASK_ENEMY;
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        if (!collision.OtherCollider.IsForMain())
            return;
        var cloud = collision.Entity;
        var other = collision.Other;
        if (other.Type != EntityTypes.ENEMY || !cloud.IsHostile(other))
            return;
        TryBounceEnemy(cloud, other);
    }
    public override function PreTakeDamage(input:DamageInput, result:CallbackResult):Void
    {
        super.PreTakeDamage(input, result);
        var punch = input.Effects.HasEffect(VanillaDamageEffects.IMPACT);
        if (input.Effects.HasEffect(VanillaDamageEffects.ENEMY_MELEE) || punch)
        {
            var cloud = input.Entity;
            // C#: if (input.Source is EntitySourceReference entityRef)
            if (Std.isOfType(input.Source, EntitySourceReference))
            {
                var entityRef:EntitySourceReference = cast input.Source;
                TryBounceEnemy(cloud, entityRef.GetEntity(cloud.Level), punch);
            }
            result.SetFinalValue(false);
            return;
        }
    }
    public static function TryBounceEnemy(self:Entity, enemy:Null<Entity>, ignoreCooldown:Bool = false):Bool
    {
        if (!enemy.ExistsAndAlive() || enemy.Type != EntityTypes.ENEMY)
            return false;
        if (!ignoreCooldown && HasEnemyKnockbackCooldown(self, enemy))
            return false;
        var knockbackMultiplier = enemy.GetStrongKnockbackMultiplier();
        enemy.Velocity += knockbackMultiplier * KNOCKBACK_DISTANCE * self.GetFacingDirection();

        var bounceDamage = BOUNCE_DAMAGE * self.Level.GetElasticCloudBounceDamageMultiplier();
        self.TakeDamage(bounceDamage, new DamageEffectList([]), self);
        AddEnemyKnockbackCooldown(self, enemy, Ticks.FromSeconds(KNOCKBACK_COOLDOWN_SECONDS));
        PlayBounceEffect(self);
        return true;
    }
    public static function PlayBounceEffect(entity:Entity):Void
    {
        entity.TriggerAnimation("Bounce");
        entity.PlaySound(VanillaSoundID.boing);
    }
    public static function AddEnemyKnockbackCooldown(self:Entity, enemy:Entity, cooldown:Int):Void
    {
        var targetID = enemy.ID;
        var buffID = VanillaBuffID.Contraption.elasticCloudBounceCooldown;
        var buff = GetEnemyKnockbackCooldownBuff(self, enemy);
        if (buff == null)
        {
            buff = self.AddBuff(buffID);
            ElasticCloudBounceCooldownBuff.SetTargetID(buff, targetID);
        }
        ElasticCloudBounceCooldownBuff.SetTimeout(buff, cooldown);
    }
    public static function GetEnemyKnockbackCooldownBuff(self:Entity, enemy:Entity):Buff
    {
        var targetID = enemy.ID;
        var buffID = VanillaBuffID.Contraption.elasticCloudBounceCooldown;
        var buffs = self.GetBuffs(buffID);
        return Lambda.find(buffs, b -> ElasticCloudBounceCooldownBuff.GetTargetID(b) == targetID);
    }
    public static function HasEnemyKnockbackCooldown(self:Entity, enemy:Entity):Bool
    {
        return GetEnemyKnockbackCooldownBuff(self, enemy) != null;
    }
    public static inline var KNOCKBACK_DISTANCE:Float = 20;
    public static inline var BOUNCE_DAMAGE:Float = 300;
    public static inline var KNOCKBACK_COOLDOWN_SECONDS:Float = 1;
}
