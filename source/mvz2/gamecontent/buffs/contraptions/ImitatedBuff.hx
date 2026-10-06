// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter4/ImitatedBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.modifiers.VanillaModifierPriorities;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.ColorModifier;
import unity.Color;

@:autoBuffDefinition(VanillaBuffNames.Contraption_imitated)
class ImitatedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicEntityProps.GRAYSCALE, true));
        // C#: ColorModifier.Override(LogicEntityProps.LIGHT_COLOR, Color.white, priority: VanillaModifierPriorities.FORCE)
        AddModifier(ColorModifier.Override(LogicEntityProps.LIGHT_COLOR, Color.white, VanillaModifierPriorities.FORCE));
    }
}
