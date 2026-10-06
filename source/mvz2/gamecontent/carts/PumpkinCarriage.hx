// Ported from: Assets/Scripts/Vanilla/GameContent/Carts/PumpkinCarriage.cs
package mvz2.gamecontent.carts;

import mvz2.gamecontent.carts.VanillaCartID.VanillaCartNames;

@:autoEntityBehaviourDefinition(VanillaCartNames.pumpkinCarriage)
class PumpkinCarriage extends CartBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
}
