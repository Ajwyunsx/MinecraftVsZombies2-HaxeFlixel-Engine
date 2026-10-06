// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter3/SeijaMagicBomb.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.EngineEntityProps;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.seijaMagicBomb)
class SeijaMagicBomb extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskHostile = 0;
        entity.CollisionMaskFriendly = 0;
    }
    public override function PostContactGround(entity:Entity, velocity:Vector3):Void
    {
        super.PostContactGround(entity, velocity);
        var range = entity.GetRange();
        var damage = entity.GetDamage();

        var damageEffects = new DamageEffectList([VanillaDamageEffects.MUTE, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN, VanillaDamageEffects.EXPLOSION]);
        var damageOutputs = entity.Explode(entity.Position, range, entity.GetFaction(), entity.GetDamage(), damageEffects);
        for (output in damageOutputs)
        {
            var result = output.BodyResult;
            if (result != null && result.Fatal)
            {
                var target = output.Entity;
                var distance = (target.Position - entity.Position).magnitude;
                var speed = 25 * Mathf.Lerp(1, 0.5, distance / range);
                target.Velocity = target.Velocity + Vector3.up * speed;
            }
        }
        var param = entity.GetSpawnParams();
        param.SetProperty(EngineEntityProps.DISPLAY_SCALE, Vector3.one * (range * 2 / 100));
        var explosion = entity.Spawn(VanillaEffectID.magicBombExplosion, entity.GetCenter(), param);
        entity.PlaySound(VanillaSoundID.evocation);
    }
}
