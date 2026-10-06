// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Prologue/ObsidianArmorBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.fragments.VanillaFragmentID;
import mvz2.vanilla.contraptions.VanillaContraptionProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.MaxHealthModifier;
import pvzengine.modifiers.NamespaceIDModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.SetOperator;

@:autoBuffDefinition(VanillaBuffNames.Contraption_obsidianArmor)
class ObsidianArmorBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new MaxHealthModifier(NumberOperator.Multiply, HEALTH_MULTIPLIER));
        AddModifier(new NamespaceIDModifier(VanillaContraptionProps.FRAGMENT_ID, SetOperator.Set, VanillaFragmentID.obsidianArmor));
    }
    public static inline var HEALTH_MULTIPLIER:Float = 2.5;
}
