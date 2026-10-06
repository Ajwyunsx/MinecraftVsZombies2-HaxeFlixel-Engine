// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/EntityGlobalCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.armors.VanillaArmorProps;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.shells.VanillaShellProps;
import mvz2logic.callbacks.LogicLevelCallbacks;
import mvz2logic.entities.IDeathEffectsBehaviour;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.modding.Mod;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.EntityTypes;
import pvzengine.level.ILevelSourceReference;
import unity.Mathf;
using mvz2.vanilla.enemies.VanillaEnemyExt;
import mvz2.vanilla.effects.FragmentExt;
import mvz2.vanilla.entities.VanillaEntityProps;

@:modGlobalCallbacks
class EntityGlobalCallbacks extends VanillaGlobalCallbacks
{
    public override function Apply(mod:Mod):Void
    {
        mod.AddTrigger(LevelCallbacks.POST_ENTITY_CONTACT_GROUND, PostContactGroundCallback);
        mod.AddTrigger(VanillaLevelCallbacks.POST_ENTITY_TAKE_DAMAGE, PostDamageCallback);
        mod.AddTrigger(VanillaLevelCallbacks.APPLY_DAMAGE_SPECIAL_EFFECTS, ApplyDamageEffectsCallback);
        mod.AddTrigger(LevelCallbacks.POST_ENTITY_UPDATE, HealParticlesUpdateCallback);
        mod.AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostEntityDeathCallback);
        mod.AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostEnemyDeathCallback, 0, EntityTypes.ENEMY);
        mod.AddTrigger(LevelCallbacks.POST_DESTROY_ARMOR, PostArmorDestroyCallback);
    }
    function PostContactGroundCallback(param:PostEntityContactGroundParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var velocity = param.velocity;
        if (!LogicEntityExt.IsVulnerableEntity(entity))
            return;
        if (!VanillaEntityExt.IsAboveLand(entity))
            return;
        if (velocity.y >= 0)
            return;

        // C#: entity.GetFallResistance()（MVZ2.Vanilla.Entities.VanillaEntityProps 的扩展方法，
        // 移植后位于 mvz2.vanilla.entities.VanillaEntityProps，不是 VanillaEnemyProps）。
        var damageThresold = -VanillaEntityProps.GetFallResistance(entity);
        if (velocity.y > damageThresold)
            return;
        var fallDamage = 2.5 * Mathf.Pow(velocity.y - damageThresold, 2);
        if (fallDamage > 0)
        {
            var effects = new DamageEffectList(VanillaDamageEffects.IGNORE_ARMOR, VanillaDamageEffects.FALL_DAMAGE);
            VanillaEntityExt.TakeDamage(entity, fallDamage, effects, entity);
        }
    }
    function ApplyDamageEffectsCallback(param:PostTakeDamageParams, callbackResult:CallbackResult):Void
    {
        var output = param.output;
        var entity = output.Entity;
        if (entity.Type != EntityTypes.ENEMY)
            return;
        var bodyResult = output.BodyResult;
        var armorResult = output.ArmorResult;
        var slowSource:Null<ILevelSourceReference> = null;
        var unfreezeSource:Null<ILevelSourceReference> = null;
        var slow = false;
        var unfreeze = false;
        if (bodyResult != null)
        {
            if (bodyResult.HasEffect(VanillaDamageEffects.SLOW))
            {
                slow = true;
                slowSource = bodyResult.Source;
            }
            if (bodyResult.HasEffect(VanillaDamageEffects.FIRE))
            {
                unfreeze = true;
                unfreezeSource = bodyResult.Source;
            }
        }
        if (armorResult != null)
        {
            if (armorResult.HasEffect(VanillaDamageEffects.SLOW))
            {
                slow = true;
                slowSource = armorResult.Source;
            }
            if (armorResult.HasEffect(VanillaDamageEffects.FIRE))
            {
                unfreeze = true;
                unfreezeSource = armorResult.Source;
            }
        }
        if (unfreeze)
        {
            VanillaEntityExt.Unfreeze(entity, unfreezeSource);
        }
        else if (slow)
        {
            VanillaEntityExt.InflictSlow(entity, 300, slowSource);
        }
    }
    function PostDamageCallback(param:PostTakeDamageParams, callbackResult:CallbackResult):Void
    {
        var output = param.output;
        var entity = output.Entity;
        var bodyResult = output.BodyResult;
        if (bodyResult != null)
        {
            var shellDefinition = bodyResult.ShellDefinition;
            if (bodyResult.Effects.HasEffect(VanillaDamageEffects.SLICE) && shellDefinition != null && VanillaShellProps.IsSliceCritical(shellDefinition))
            {
                VanillaEntityExt.EmitBlood(entity);
            }
        }
        VanillaEntityExt.PlayHitSound(output);
    }
    function PostEntityDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var info = param.deathInfo;
        if (VanillaEntityExt.ShouldTriggerDeathEffects(entity, info))
        {
            for (behaviour in entity.Definition.GetBehaviours())
            {
                if (!Std.isOfType(behaviour, IDeathEffectsBehaviour))
                    continue;
                var deathBehaviour:IDeathEffectsBehaviour = cast behaviour;
                deathBehaviour.DeathEffects(entity, info);
            }
            entity.Level.Triggers.RunCallbackFiltered(LogicLevelCallbacks.ENTITY_DEATH_EFFECTS, param, entity.Type);
        }
    }
    function PostEnemyDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var info = param.deathInfo;
        if (info.HasEffect(VanillaDamageEffects.NO_NEUTRALIZE) || LogicEntityProps.NoNeutralizedOnDeath(entity))
            return;
        entity.Neutralize();
    }
    function HealParticlesUpdateCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        FragmentExt.UpdateHealParticles(entity);
    }
    function PostArmorDestroyCallback(param:PostArmorDestroyParams, result:CallbackResult):Void
    {
        var armor = param.armor;
        var entity = param.entity;
        var deathSound = VanillaArmorProps.GetDeathSound(armor);
        if (!NamespaceID.IsValid(deathSound))
            return;
        LogicEntityExt.PlaySound(entity, deathSound);
    }
}
