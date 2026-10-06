// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter1/SoulfireBall.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostProjectileHitParams;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.soulfireBall)
class SoulfireBall extends EntityBehaviourDefinition
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

        var blast = IsBlast(projectile);
        if (blast)
        {
            projectile.PlaySound(VanillaSoundID.darkSkiesImpact);
            projectile.Level.ShakeScreen(3, 3, 3);
            projectile.Level.Spawn(VanillaEffectID.soulfireBlast, projectile.Position, projectile);
        }
        else if (!blocksFire)
        {
            projectile.Level.Spawn(VanillaEffectID.soulfire, projectile.Position, projectile);
        }

        if (!blocksFire || blast)
        {
            var damageEffects = new DamageEffectList([VanillaDamageEffects.FIRE, VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.MUTE]);
            projectile.SplashDamage(hitResult.Collider, projectile.Position, 40, projectile.GetFaction(), projectile.GetDamage() / 4, damageEffects);
        }
    }
    public static function SetBlast(entity:Entity, value:Bool):Void
    {
        entity.SetBehaviourField(PROP_BLAST, value);
    }
    public static function IsBlast(entity:Entity):Bool
    {
        return entity.GetBehaviourField(PROP_BLAST);
    }
    public static var PROP_BLAST:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("Blast");
}
