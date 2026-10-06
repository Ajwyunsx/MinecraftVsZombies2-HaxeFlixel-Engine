// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/UpgradeNormalPlacement.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.placements.VanillaPlacementID.VanillaPlacementNames;
import pvzengine.placements.PlacementDefinition;

@:autoPlacementDefinition(VanillaPlacementNames.upgrade)
class UpgradeNormalPlacement extends PlacementDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaSpawnConditions.normal);
        AddMethod(VanillaPlaceMethods.upgrade);
    }
}
