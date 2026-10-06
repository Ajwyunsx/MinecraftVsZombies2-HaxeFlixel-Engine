// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter6/InstakillByWind.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.entities.IBeBlownBehaviour;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.instakillByWind)
class InstakillByWind extends EntityBehaviourDefinition implements IBeBlownBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public function BeBlown(entity:Entity, source:Entity):Void
    {
        entity.Die(new DamageEffectList([VanillaDamageEffects.INSTA_KILL]), source);
    }
}
