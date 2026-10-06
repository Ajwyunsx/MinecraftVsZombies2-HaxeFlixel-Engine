// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/BuriedPlacement.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.placements.VanillaPlacementID.VanillaPlacementNames;
import mvz2.vanilla.almanac.VanillaAlmanacTagID;
import pvzengine.placements.PlacementDefinition;

@:autoPlacementDefinition(VanillaPlacementNames.buried)
class BuriedPlacement extends PlacementDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaSpawnConditions.buried);
        AddMethod(VanillaPlaceMethods.entity);
        AddMethod(VanillaPlaceMethods.firstAid);
        VanillaPlacementProps.SetAlmanacTag(this, VanillaAlmanacTagID.placementBuried);
    }
}
