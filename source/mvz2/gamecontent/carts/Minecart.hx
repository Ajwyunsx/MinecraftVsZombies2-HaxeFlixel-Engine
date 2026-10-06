// Ported from: Assets/Scripts/Vanilla/GameContent/Carts/Minecart.cs
package mvz2.gamecontent.carts;

import mvz2.gamecontent.carts.VanillaCartID.VanillaCartNames;

@:autoEntityBehaviourDefinition(VanillaCartNames.minecart)
class Minecart extends CartBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
}
