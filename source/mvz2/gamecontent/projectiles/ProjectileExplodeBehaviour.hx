// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Explode/ProjectileExplodeBehaviour.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.Explosion;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaCallbackPriorities;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PreProjectileHitParams;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.entities.IDeathEffectsBehaviour;
import mvz2logic.level.LogicLevelExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.projectileExplode)
class ProjectileExplodeBehaviour extends EntityBehaviourDefinition implements IDeathEffectsBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.PRE_PROJECTILE_HIT, PreHitEntityCallback, VanillaCallbackPriorities.LATE);
    }
    private function PreHitEntityCallback(param:PreProjectileHitParams, result:CallbackResult):Void
    {
        var hit = param.hit;
        var projectile = hit.Projectile;
        if (!projectile.Definition.HasBehaviour(this))
            return;
        param.damage.SetAmount(0);
    }
    public function DeathEffects(entity:Entity, damageInfo:DeathInfo):Void
    {
        Explode(entity);
    }
    // virtual
    public function Explode(entity:Entity):Void
    {
        ExplodeDamage(entity);
        SpawnExplosionEffect(entity, entity.GetCenter());
        PlayExplosionSound(entity);
    }
    // virtual
    public function ExplodeDamage(entity:Entity):Void
    {
        var range = entity.GetRange();
        var damageEffects = new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN, VanillaDamageEffects.MUTE]);
        entity.Explode(entity.Position, range, entity.GetFaction(), entity.GetDamage(), damageEffects);
    }
    // virtual
    public function SpawnExplosionEffect(entity:Entity, position:Vector3):Void
    {
        Explosion.Spawn(entity, entity.GetCenter(), entity.GetRange());
    }
    // virtual
    public function PlayExplosionSound(entity:Entity):Void
    {
        entity.PlaySound(VanillaSoundID.explosion);
    }
}
