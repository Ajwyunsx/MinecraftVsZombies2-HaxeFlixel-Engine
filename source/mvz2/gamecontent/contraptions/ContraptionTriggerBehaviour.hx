// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Behaviours/ContraptionTriggerBehaviour.cs
package mvz2.gamecontent.contraptions;

import mvz2.vanilla.contraptions.ITriggerableContraption;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicContraptionProps;

// abstract
class ContraptionTriggerBehaviour extends EntityBehaviourDefinition implements ITriggerableContraption
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public function CanTrigger(entity:Entity):Bool
    {
        return entity.IsTriggerActive() && !entity.IsAIFrozen();
    }
    public function Trigger(entity:Entity):Void
    {
    }
}
