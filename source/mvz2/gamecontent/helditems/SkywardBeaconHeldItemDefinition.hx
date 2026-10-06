// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Definitions/Entity/SkywardBeaconHeldItemDefinition.cs
package mvz2.gamecontent.helditems;

@:autoHeldItemDefinition(VanillaHeldItemNames.skywardBeacon)
class SkywardBeaconHeldItemDefinition extends EntityHeldItemDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(VanillaHeldItemBehaviourID.skywardBeacon);
        AddBehaviour(VanillaHeldItemBehaviourID.rightMouseCancel);
    }
}
