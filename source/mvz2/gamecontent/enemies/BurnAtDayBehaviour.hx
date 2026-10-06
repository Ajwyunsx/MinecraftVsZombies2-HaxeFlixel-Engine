// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Common/BurnAtDayBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.burnAtDay)
class BurnAtDayBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var interval = entity.GetProperty(PROP_BURN_INTERVAL);
        if (entity.IsTimeInterval(interval) && !entity.IsInWater() && entity.Level.IsDay() && entity.GetMainArmor() == null)
        {
            var effects = new DamageEffectList([VanillaDamageEffects.FIRE, VanillaDamageEffects.SELF_DAMAGE, VanillaDamageEffects.IGNORE_ARMOR]);
            entity.TakeDamage(entity.GetProperty(PROP_BURN_DAMAGE), effects, entity);
            entity.Spawn(VanillaEffectID.fireburn, entity.Position);
        }
    }
    public static var PROP_BURN_INTERVAL:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("burn_interval", 15);
    public static var PROP_BURN_DAMAGE:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("burn_damage", 50);
}
