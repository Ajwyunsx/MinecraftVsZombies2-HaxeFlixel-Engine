// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter2/SpiderClimbBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaBuffNames.Enemy_spiderClimb)
class SpiderClimbBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(EngineEntityProps.GRAVITY, NumberOperator.Set, 0));
        AddModifier(new BooleanModifier(VanillaEntityProps.KEEP_GROUND_FRICTION, true));
    }
}
