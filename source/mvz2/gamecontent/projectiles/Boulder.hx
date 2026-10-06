// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter3/Boulder.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.contraptions.StoneDropper;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostProjectileHitParams;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.ShootParams;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import unity.Mathf;
import unity.Quaternion;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.boulder)
class Boulder extends EntityBehaviourDefinition
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
        var other = hitResult.Other;
        if (other.Type == EntityTypes.ENEMY)
        {
            var vel = other.Velocity;
            vel.x += 5 * Mathf.Sign(projectile.Velocity.x) * other.GetWeakKnockbackMultiplier();
            other.Velocity = vel;
            projectile.PlaySound(VanillaSoundID.bash);
        }

        if (!hitResult.Pierce)
        {
            var rng = projectile.RNG;
            for (i in 0...3)
            {
                var randomRotation = new Vector3(rng.Next(360), rng.Next(360), rng.Next(360));
                var radius:Float = rng.Next(24);
                var quaternion = Quaternion.Euler(randomRotation.x, randomRotation.y, randomRotation.z);
                var pos = projectile.Position + (quaternion * Vector3.right) * radius;

                var xspeed = rng.Next(-18, 18);
                var zspeed = rng.Next(-1.5, 1.5);
                var yspeed = rng.Next(10);

                var shootParams = new ShootParams();
                shootParams.damage = projectile.GetDamage() / StoneDropper.BOULDER_DAMAGE_MULTIPLIER;
                shootParams.faction = projectile.GetFaction();
                shootParams.position = pos;
                shootParams.projectileID = VanillaProjectileID.cobble;
                shootParams.velocity = new Vector3(xspeed, yspeed, zspeed);
                shootParams.spawnParam = projectile.GetSpawnParams();
                projectile.ShootProjectile(shootParams);
            }
            projectile.PlaySound(VanillaSoundID.stone);
        }
    }
}
