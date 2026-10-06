// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter4/CursedMeteor.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.contraptions.Hellfire;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.cursedMeteor)
class CursedMeteor extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function PostContactGround(entity:Entity, velocity:Vector3):Void
    {
        super.PostContactGround(entity, velocity);
        var parent = entity.Parent;
        if (parent != null && parent.ExistsAndAlive() && parent.IsEntityOf(VanillaContraptionID.hellfire))
        {
            Hellfire.Curse(parent);
            Hellfire.SetExtinguished(parent, false);
        }
        var range = entity.GetRange();
        var effects = new DamageEffectList([VanillaDamageEffects.MUTE, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN, VanillaDamageEffects.EXPLOSION]);
        entity.Explode(entity.GetCenter(), range, entity.GetFaction(), entity.GetDamage(), effects);

        Explosion.Spawn(entity, entity.GetCenter(), range);

        entity.Spawn(VanillaEffectID.cursedFireParticles, entity.GetCenter());

        entity.PlaySound(VanillaSoundID.meteorLand);
        entity.Level.ShakeScreen(10, 0, 15);
        entity.Remove();
    }
}
