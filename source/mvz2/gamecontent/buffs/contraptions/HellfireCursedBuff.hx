// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter4/HellfireCursedBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.fragments.VanillaFragmentID;
import mvz2.vanilla.contraptions.VanillaContraptionProps;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.ColorModifier;
import pvzengine.modifiers.NamespaceIDModifier;
import pvzengine.modifiers.SetOperator;
import unity.Color;

@:autoBuffDefinition(VanillaBuffNames.Contraption_hellfireCursed)
class HellfireCursedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new NamespaceIDModifier(VanillaContraptionProps.FRAGMENT_ID, SetOperator.Set, VanillaFragmentID.hellfireCursed));
        AddModifier(ColorModifier.Override(LogicEntityProps.LIGHT_COLOR, new Color(0, 1, 0)));
    }
}
