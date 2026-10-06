// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Explode/ProjectileExplodeBehaviour_CannonMissile.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import tools.VectorExt;
import unity.Color;
import unity.Vector2;
import unity.Vector3;
using mvz2.vanilla.level.VanillaLevelExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.entities.LogicEntityProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.projectileExplodeCannonMissile)
class ProjectileExplodeBehaviour_CannonMissile extends ProjectileExplodeBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Explode(entity:Entity):Void
    {
        super.Explode(entity);
        if (entity.GetVariant() == CannonMissile.VARIANT_DANGER)
        {
            for (i in 0...36)
            {
                var angle = i * 10;
                var vector2 = tools.VectorExt.RotateClockwise(Vector2.right, angle);
                var param = entity.GetShootParams();
                param.damage = entity.GetDamage() * 0.075;
                param.position = entity.GetCenter();
                param.velocity = new Vector3(vector2.x, 0, vector2.y) * 10;
                param.projectileID = VanillaProjectileID.fireCharge;
                entity.ShootProjectile(param);
            }
        }
    }
    public override function ExplodeDamage(entity:Entity):Void
    {
        var range = entity.GetRange();
        var damageEffects = new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN, VanillaDamageEffects.MUTE, VanillaDamageEffects.NO_DEATH_EFFECTS, VanillaDamageEffects.REMOVE_ON_DEATH]);
        var damageOutputs = entity.Explode(entity.GetCenter(), range, entity.GetFaction(), entity.GetDamage(), damageEffects);
        damageOutputs.ClearExplosionCorpses();
    }
    public override function SpawnExplosionEffect(entity:Entity, position:Vector3):Void
    {
        super.SpawnExplosionEffect(entity, position);
        var smokeSpawnParam = entity.GetSpawnParams();
        smokeSpawnParam.SetProperty(EngineEntityProps.TINT, new Color(0.5, 0.5, 0.5, 1));
        smokeSpawnParam.SetProperty(EngineEntityProps.DISPLAY_SCALE, Vector3.one * 0.5);
        entity.Spawn(VanillaEffectID.nukeSmoke, entity.Position, smokeSpawnParam);
        entity.Level.ShakeScreen(10, 0, 5);
    }
    public override function PlayExplosionSound(entity:Entity):Void
    {
        entity.PlaySound(VanillaSoundID.doom);
    }
}
