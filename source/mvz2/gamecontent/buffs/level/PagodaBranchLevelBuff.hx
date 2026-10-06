// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter2/PagodaBranchLevelBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2logic.level.LogicLevelProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaBuffNames.Level_pagodaBranchLevel)
class PagodaBranchLevelBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(LogicLevelProps.SPAWN_POINTS_MUTLIPLIER, NumberOperator.AddMultiple, 2));
    }
}
