// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/SuspensionPlacement.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.placements.VanillaPlacementID.VanillaPlacementNames;
import mvz2.vanilla.almanac.VanillaAlmanacTagID;
import pvzengine.placements.PlacementDefinition;

@:autoPlacementDefinition(VanillaPlacementNames.suspension)
class SuspensionPlacement extends PlacementDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaSpawnConditions.suspension);
        AddMethod(VanillaPlaceMethods.entity);
        AddMethod(VanillaPlaceMethods.firstAid);
        VanillaPlacementProps.SetAlmanacTag(this, VanillaAlmanacTagID.placementSuspension);
    }
}
