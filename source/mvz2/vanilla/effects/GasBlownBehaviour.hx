// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/GasBlownBehaviour.cs
package mvz2.vanilla.effects;

import mvz2.gamecontent.effects.GasBehaviour;
import mvz2.vanilla.entities.IBeBlownBehaviour;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.gasBlown)
class GasBlownBehaviour extends EntityBehaviourDefinition implements IBeBlownBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public function BeBlown(entity:Entity, source:Entity):Void
    {
        GasBehaviour.Disappear(entity);
    }
}
