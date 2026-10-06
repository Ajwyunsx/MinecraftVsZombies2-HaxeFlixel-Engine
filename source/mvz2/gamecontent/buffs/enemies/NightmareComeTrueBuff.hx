// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter2/NightmareComeTrueBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaBuffNames.Enemy_nightmareComeTrue)
class NightmareComeTrueBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEntityProps.ATTACK_SPEED, NumberOperator.Multiply, 2));
        AddModifier(new FloatModifier(VanillaEntityProps.DAMAGE, NumberOperator.Multiply, 2));
    }
}
