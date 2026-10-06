// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter4/GreedyVacuumBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2logic.level.LogicStageProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Level_greedyVacuum)
class GreedyVacuumBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicStageProps.AUTO_COLLECT_ENERGY, true));
        AddModifier(new BooleanModifier(LogicStageProps.AUTO_COLLECT_STARSHARD, true));
    }
}
