// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter5/SkywardBeaconNightBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.fragments.VanillaFragmentID;
import mvz2.vanilla.contraptions.VanillaContraptionProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.NamespaceIDModifier;
import pvzengine.modifiers.SetOperator;

@:autoBuffDefinition(VanillaBuffNames.Contraption_skywardBeaconNight)
class SkywardBeaconNightBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new NamespaceIDModifier(VanillaContraptionProps.FRAGMENT_ID, SetOperator.SetIfNotNull, VanillaFragmentID.skywardBeaconNight));
    }
}
