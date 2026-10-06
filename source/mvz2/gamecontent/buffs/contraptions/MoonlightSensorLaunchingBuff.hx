// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter1/MoonlightSensorLaunching.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaBuffNames.Contraption_moonlightSensorLaunching)
class MoonlightSensorLaunchingBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEntityProps.PRODUCE_SPEED, NumberOperator.Multiply, PRODUCE_SPEED_MULTIPLIER));
    }
    public static inline var PRODUCE_SPEED_MULTIPLIER:Float = 0.625;
}
