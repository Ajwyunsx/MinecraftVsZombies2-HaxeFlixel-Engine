// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Definitions/Entity/BrickCannonHeldItemDefinition.cs
package mvz2.gamecontent.helditems;

@:autoHeldItemDefinition(VanillaHeldItemNames.brickCannon)
class BrickCannonHeldItemDefinition extends EntityHeldItemDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(VanillaHeldItemBehaviourID.brickCannon);
        AddBehaviour(VanillaHeldItemBehaviourID.rightMouseCancel);
    }
}
