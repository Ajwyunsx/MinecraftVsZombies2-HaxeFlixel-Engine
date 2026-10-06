// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter2/CarriedByLilyPadBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.entities.WaterInteraction;
import mvz2.vanilla.modifiers.VanillaModifierPriorities;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;

@:autoBuffDefinition(VanillaBuffNames.Contraption_carriedByLilyPad)
class CarriedByLilyPadBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new IntModifier(VanillaEntityProps.WATER_INTERACTION, IntegerOperator.Set, WaterInteraction.NONE, VanillaModifierPriorities.FORCE));
    }
}
