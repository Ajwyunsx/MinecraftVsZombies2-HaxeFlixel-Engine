// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Definitions/Logic/TriggerHeldItemDefinition.cs
package mvz2.gamecontent.helditems;

import mvz2logic.helditems.HeldItemDefinition;
import mvz2logic.helditems.LogicHeldItemNames;

@:autoHeldItemDefinition(LogicHeldItemNames.trigger)
class TriggerHeldItemDefinition extends HeldItemDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(VanillaHeldItemBehaviourID.rightMouseCancel);
        AddBehaviour(VanillaHeldItemBehaviourID.pickup);
        AddBehaviour(VanillaHeldItemBehaviourID.triggerCart);
        AddBehaviour(VanillaHeldItemBehaviourID.selectBlueprint);
        AddBehaviour(VanillaHeldItemBehaviourID.trigger);
    }
}
