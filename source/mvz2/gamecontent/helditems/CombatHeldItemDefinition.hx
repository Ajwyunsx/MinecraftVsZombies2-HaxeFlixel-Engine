// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Definitions/CombatHeldItemDefinition.cs
package mvz2.gamecontent.helditems;

import mvz2logic.helditems.HeldItemDefinition;

@:autoHeldItemDefinition(VanillaHeldItemNames.combat)
class CombatHeldItemDefinition extends HeldItemDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(VanillaHeldItemBehaviourID.rightMouseCancel);
        AddBehaviour(VanillaHeldItemBehaviourID.pickup);
        AddBehaviour(VanillaHeldItemBehaviourID.triggerCart);
        AddBehaviour(VanillaHeldItemBehaviourID.selectBlueprint);
        AddBehaviour(VanillaHeldItemBehaviourID.combat);
    }
}
