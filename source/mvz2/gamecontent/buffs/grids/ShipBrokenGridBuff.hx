// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Grids/Chapter5/ShipBrokenGridBuff.cs
package mvz2.gamecontent.buffs.grids;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2logic.grids.LogicGridProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Grid_shipBrokenGrid)
class ShipBrokenGridBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicGridProps.IS_AIR, true));
    }
}
