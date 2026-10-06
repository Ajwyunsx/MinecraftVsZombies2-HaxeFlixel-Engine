// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Definitions/Logic/SwordHeldItemDefinition.cs
package mvz2.gamecontent.helditems;

import mvz2logic.helditems.HeldItemDefinition;
import mvz2logic.helditems.LogicHeldItemNames;

@:autoHeldItemDefinition(LogicHeldItemNames.sword)
class SwordHeldItemDefinition extends HeldItemDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(VanillaHeldItemBehaviourID.emptyHandEntity);
        AddBehaviour(VanillaHeldItemBehaviourID.putOutFire);
        AddBehaviour(VanillaHeldItemBehaviourID.pickup);
        AddBehaviour(VanillaHeldItemBehaviourID.triggerCart);
        AddBehaviour(VanillaHeldItemBehaviourID.selectBlueprint);
        AddBehaviour(VanillaHeldItemBehaviourID.sword);
        Exclusive = false;
    }
}
