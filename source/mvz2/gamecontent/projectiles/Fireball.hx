// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter4/Fireball.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostProjectileHitParams;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.EntityBehaviourDefinition;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.fireball)
class Fireball extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_PROJECTILE_HIT, PostHitEntityCallback);
    }
    function PostHitEntityCallback(param:PostProjectileHitParams, result:CallbackResult):Void
    {
        var hitResult = param.hit;
        var projectile = hitResult.Projectile;
        if (!projectile.Definition.HasBehaviour(this))
            return;
        var damageOutput = param.damage;
        if (damageOutput == null)
            return;
        var other = hitResult.Other;

        var blocksFire = damageOutput.WillDamageBlockFire();

        if (!blocksFire)
        {
            var damageEffects = new DamageEffectList([VanillaDamageEffects.FIRE, VanillaDamageEffects.MUTE]);
            projectile.SplashDamage(hitResult.Collider, projectile.Position, 40, projectile.GetFaction(), projectile.GetDamage() / 4, damageEffects);
            projectile.Spawn(VanillaEffectID.fireburn, projectile.Position);
        }
    }
}
