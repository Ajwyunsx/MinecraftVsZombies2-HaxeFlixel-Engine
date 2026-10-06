// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Difficulty/IZombieHardBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;

@:autoBuffDefinition(VanillaBuffNames.Level_iZombieHard)
class IZombieHardBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.IZ_FURNACE_REDSTONE_COUNT, IntegerOperator.Add, -1));
    }
}
