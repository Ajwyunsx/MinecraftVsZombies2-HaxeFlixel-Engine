// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/AquaticPlacement.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.placements.VanillaPlacementID.VanillaPlacementNames;
import mvz2.vanilla.almanac.VanillaAlmanacTagID;
import pvzengine.placements.PlacementDefinition;

@:autoPlacementDefinition(VanillaPlacementNames.aquatic)
class AquaticPlacement extends PlacementDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaSpawnConditions.aquatic);
        AddMethod(VanillaPlaceMethods.entity);
        AddMethod(VanillaPlaceMethods.firstAid);
        VanillaPlacementProps.SetAlmanacTag(this, VanillaAlmanacTagID.placementAquatic);
    }
}
