// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Boss/Chapter4/TheGiantPhase3Buff.cs
package mvz2.gamecontent.buffs.bosses;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.MaxHealthModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaBuffNames.Boss_theGiantPhase3)
class TheGiantPhase3Buff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new MaxHealthModifier(NumberOperator.Multiply, 0.4));
    }
}
