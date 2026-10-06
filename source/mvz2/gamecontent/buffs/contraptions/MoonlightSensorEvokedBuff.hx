// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter1/MoonlightSensorEvoked.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Contraption_moonlightSensorEvoked)
class MoonlightSensorEvokedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEntityProps.PRODUCE_SPEED, NumberOperator.Multiply, PRODUCE_SPEED_MULTIPLIER));
        AddModifier(new BooleanModifier(LogicEntityProps.IS_LIGHT_SOURCE, true));
        AddModifier(new Vector3Modifier(LogicEntityProps.LIGHT_RANGE, NumberOperator.Add, LIGHT_RANGE_ADDITION));
    }
    public static inline var PRODUCE_SPEED_MULTIPLIER:Float = 2;
    public static var LIGHT_RANGE_ADDITION:Vector3 = new Vector3(240, 240, 240);
}
