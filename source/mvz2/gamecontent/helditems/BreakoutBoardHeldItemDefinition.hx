// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Definitions/Entity/BreakoutBoardHeldItemDefinition.cs
package mvz2.gamecontent.helditems;

@:autoHeldItemDefinition(VanillaHeldItemNames.breakoutBoard)
class BreakoutBoardHeldItemDefinition extends EntityHeldItemDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(VanillaHeldItemBehaviourID.pickup);
        AddBehaviour(VanillaHeldItemBehaviourID.triggerCart);
        AddBehaviour(VanillaHeldItemBehaviourID.selectBlueprint);
        AddBehaviour(VanillaHeldItemBehaviourID.breakoutBoard);
        Exclusive = false;
    }
}
