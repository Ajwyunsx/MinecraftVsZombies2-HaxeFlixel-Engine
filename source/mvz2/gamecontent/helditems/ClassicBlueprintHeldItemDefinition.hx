// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Definitions/Logic/ClassicBlueprintHeldItemDefinition.cs
package mvz2.gamecontent.helditems;

import mvz2logic.helditems.LogicHeldItemNames;

@:autoHeldItemDefinition(LogicHeldItemNames.blueprint)
class ClassicBlueprintHeldItemDefinition extends BlueprintHeldItemDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(VanillaHeldItemBehaviourID.classicBlueprint);
    }
}
