// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter2/LilyPadCarrier.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import pvzengine.NamespaceID;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.lilyPadCarrier)
class LilyPadCarrier extends CarrierContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function GetCarrierBuffID():NamespaceID return VanillaBuffID.Contraption.carryingOther;
    override function GetPassenagerBuffID():NamespaceID return VanillaBuffID.Contraption.carriedByLilyPad;
}
