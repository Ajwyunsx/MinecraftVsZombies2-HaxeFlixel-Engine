// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Grids/Chapter5/WaterStainWetBuff.cs
package mvz2.gamecontent.buffs.grids;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2logic.grids.LogicGridProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Grid_waterStainWet)
class WaterStainWetBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicGridProps.IS_WET, true));
    }
}
