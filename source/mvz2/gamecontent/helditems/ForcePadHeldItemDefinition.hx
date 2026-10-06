// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Definitions/Entity/ForcePadHeldItemDefinition.cs
package mvz2.gamecontent.helditems;

@:autoHeldItemDefinition(VanillaHeldItemNames.forcePad)
class ForcePadHeldItemDefinition extends EntityHeldItemDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(VanillaHeldItemBehaviourID.forcePad);
    }
}
