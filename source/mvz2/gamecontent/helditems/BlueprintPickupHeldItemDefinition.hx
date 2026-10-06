// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Definitions/Entity/BlueprintPickupHeldItemDefinition.cs
package mvz2.gamecontent.helditems;

@:autoHeldItemDefinition(VanillaHeldItemNames.blueprintPickup)
class BlueprintPickupHeldItemDefinition extends EntityHeldItemDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(VanillaHeldItemBehaviourID.rightMouseCancel);
        AddBehaviour(VanillaHeldItemBehaviourID.pickup);
        AddBehaviour(VanillaHeldItemBehaviourID.triggerCart);
        AddBehaviour(VanillaHeldItemBehaviourID.blueprintPickup);
    }
}
