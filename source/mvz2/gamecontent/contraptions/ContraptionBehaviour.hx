// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Behaviours/ContraptionBehaviour.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.contraptions.IContraptionEvokeBehaviour;
import mvz2.vanilla.contraptions.ITriggerableContraption;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicContraptionProps;

// abstract
class ContraptionBehaviour extends AIEntityBehaviour implements IContraptionEvokeBehaviour implements ITriggerableContraption
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
        OnEvoke(entity);
    }
    public function CanTrigger(entity:Entity):Bool
    {
        return entity.IsTriggerActive() && !entity.IsAIFrozen();
    }
    public function Trigger(entity:Entity):Void
    {
        OnTrigger(entity);
    }
    function OnTrigger(entity:Entity):Void
    {
    }
    function OnEvoke(entity:Entity):Void
    {
    }
}
