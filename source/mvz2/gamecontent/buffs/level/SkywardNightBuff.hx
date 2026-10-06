// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter5/SkywardNightBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2logic.level.LogicDayNightCycles;
import mvz2logic.level.LogicLevelProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;

@:autoBuffDefinition(VanillaBuffNames.Level_skywardNight)
class SkywardNightBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new IntModifier(LogicLevelProps.DAY_NIGHT_CYCLE_OVERRIDE, IntegerOperator.Set, LogicDayNightCycles.NIGHT));
    }
}
