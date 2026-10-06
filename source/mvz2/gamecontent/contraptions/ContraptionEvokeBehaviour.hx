// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Behaviours/ContraptionEvokeBehaviour.cs
package mvz2.gamecontent.contraptions;

import mvz2.vanilla.contraptions.IContraptionEvokeBehaviour;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicContraptionProps;

// abstract
class ContraptionEvokeBehaviour extends EntityBehaviourDefinition implements IContraptionEvokeBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public function CanEvoke(entity:Entity):Bool
    {
        return !entity.IsEvoked() && !entity.IsAIFrozen() && !entity.NoEvoke();
    }
    public function Evoke(entity:Entity):Void
    {
    }
}
