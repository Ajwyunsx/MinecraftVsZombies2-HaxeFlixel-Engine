// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Armor/Chapter2/DarkMatterArmorInvisibleBuff.cs
package mvz2.gamecontent.buffs.armors;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import pvzengine.armors.EngineArmorProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.ColorModifier;
import unity.Color;

@:autoBuffDefinition(VanillaBuffNames.Armor_darkMatterArmorInvisible)
class DarkMatterArmorInvisibleBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Multiply(EngineArmorProps.TINT, new Color(1, 1, 1, 0)));
    }
}
