// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Armor/Chapter3/LittleZombieArmorBuff.cs
package mvz2.gamecontent.buffs.armors;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.ArmorMaxHealthModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaBuffNames.Armor_littleZombieArmor)
class LittleZombieArmorBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new ArmorMaxHealthModifier(NumberOperator.Multiply, 0.25));
    }
}
