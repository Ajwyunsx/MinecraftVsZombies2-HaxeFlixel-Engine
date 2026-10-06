// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Definitions/Logic/NoneHeldItemDefinition.cs
package mvz2.gamecontent.helditems;

import mvz2logic.helditems.HeldItemDefinition;
import mvz2logic.helditems.LogicHeldItemNames;

@:autoHeldItemDefinition(LogicHeldItemNames.none)
class NoneHeldItemDefinition extends HeldItemDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(VanillaHeldItemBehaviourID.emptyHandEntity);
        AddBehaviour(VanillaHeldItemBehaviourID.putOutFire);
        AddBehaviour(VanillaHeldItemBehaviourID.pickup);
        AddBehaviour(VanillaHeldItemBehaviourID.triggerCart);
        AddBehaviour(VanillaHeldItemBehaviourID.selectBlueprint);
    }
}
