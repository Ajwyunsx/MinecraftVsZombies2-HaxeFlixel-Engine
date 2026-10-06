// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Definitions/Logic/ConveyorBlueprintHeldItemDefinition.cs
package mvz2.gamecontent.helditems;

import mvz2logic.helditems.LogicHeldItemNames;

@:autoHeldItemDefinition(LogicHeldItemNames.conveyor)
class ConveyorBlueprintHeldItemDefinition extends BlueprintHeldItemDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(VanillaHeldItemBehaviourID.conveyorBlueprint);
    }
}
