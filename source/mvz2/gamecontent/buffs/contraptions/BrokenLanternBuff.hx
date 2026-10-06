// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter3/BrokenLanternBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Contraption_brokenLantern)
class BrokenLanternBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(LogicEntityProps.LIGHT_RANGE, NumberOperator.Multiply, Vector3.one * 0.5));
        AddModifier(new FloatModifier(VanillaEntityProps.PRODUCE_SPEED, NumberOperator.AddMultiple, 0.25));
        AddModifier(new FloatModifier(VanillaEntityProps.ATTACK_SPEED, NumberOperator.AddMultiple, 0.25));
    }
}
