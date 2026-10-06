// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/CoolingCellPlacement.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.placements.VanillaPlacementID.VanillaPlacementNames;
import pvzengine.placements.PlacementDefinition;

@:autoPlacementDefinition(VanillaPlacementNames.coolingCell)
class CoolingCellPlacement extends PlacementDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaSpawnConditions.coolingCell);
        AddMethod(VanillaPlaceMethods.entity);
        AddMethod(VanillaPlaceMethods.firstAid);
    }
}
