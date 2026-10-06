// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter6/LevelEnemiesClearedBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.level.LogicStageProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Level_levelEnemiesCleared)
class LevelEnemiesClearedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicStageProps.NO_ENERGY, true));
        AddModifier(new BooleanModifier(LogicLevelProps.ALL_ENEMIES_CLEARED, true));
    }
}
