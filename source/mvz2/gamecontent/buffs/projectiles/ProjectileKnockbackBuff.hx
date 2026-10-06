// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Projectiles/Chapter2/ProjectileKnockbackBuff.cs
package mvz2.gamecontent.buffs.projectiles;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2logic.models.LogicModelHelper;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EntityTypes;
import unity.Mathf;
import unity.Vector3;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostProjectileHitParams;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoBuffDefinition(VanillaBuffNames.Projectile_projectileKnockback)
class ProjectileKnockbackBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, VanillaModelKeys.knockbackWave, VanillaModelID.knockbackWave);
        AddTrigger(VanillaLevelCallbacks.POST_PROJECTILE_HIT, PostProjectileHitCallback);
    }
    private function PostProjectileHitCallback(param:PostProjectileHitParams, result:CallbackResult):Void
    {
        var hit = param.hit;
        var projectile = hit.Projectile;
        if (!projectile.HasBuff(ProjectileKnockbackBuff))
            return;
        var damage = param.damage;
        if (!projectile.HasBuff(ProjectileKnockbackBuff))
            return;
        var other = hit.Other;
        if (other.Type == EntityTypes.ENEMY)
        {
            var sign = Mathf.Sign(projectile.Velocity.x);
            var knockbackMulti = other.GetWeakKnockbackMultiplier();
            other.Velocity += new Vector3(1 * sign, 1) * knockbackMulti;
        }
    }
}
