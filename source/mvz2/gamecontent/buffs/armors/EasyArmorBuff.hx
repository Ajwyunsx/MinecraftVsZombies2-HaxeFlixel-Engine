// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Armor/Difficulty/EasyArmorBuff.cs
package mvz2.gamecontent.buffs.armors;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.ArmorMaxHealthModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaBuffNames.Armor_easyArmor)
class EasyArmorBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new ArmorMaxHealthModifier(NumberOperator.Multiply, 0.5));
    }
}
