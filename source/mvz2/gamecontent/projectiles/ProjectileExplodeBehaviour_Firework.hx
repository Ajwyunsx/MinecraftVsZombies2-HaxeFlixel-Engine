// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Explode/ProjectileExplodeBehaviour_Firework.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.FireworkBlast;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.NamespaceID;
import pvzengine.collisions.IEntityCollider;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.projectileExplodeFirework)
class ProjectileExplodeBehaviour_Firework extends ProjectileExplodeBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function ExplodeDamage(entity:Entity):Void
    {
        var range = entity.GetRange();
        var damageEffects = new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.MUTE]);
        entity.Explode(entity.Position, range, entity.GetFaction(), entity.GetDamage(), damageEffects, CanHitCollider);
    }
    public override function SpawnExplosionEffect(entity:Entity, position:Vector3):Void
    {
        FireworkBlast.SpawnFireworkBlast(entity, entity.GetCenter(), entity.GetRange(), entity.RNG);
    }
    public override function PlayExplosionSound(entity:Entity):Void
    {
        entity.PlaySoundIfNotNull(entity.GetProperty(PROP_BLAST_SOUND));
        entity.PlaySound(VanillaSoundID.fireworkTwinkle);
    }
    public static function CanHitCollider(collider:IEntityCollider):Bool
    {
        return collider.Entity.GetRelativeY() >= MIN_HIT_RELATIVE_Y;
    }
    public static var PROP_BLAST_SOUND:VanillaEntityPropertyMeta<NamespaceID> = new VanillaEntityPropertyMeta<NamespaceID>("blast_sound", VanillaSoundID.fireworkBlast);
    public static inline var MIN_HIT_RELATIVE_Y:Float = 40;
}
