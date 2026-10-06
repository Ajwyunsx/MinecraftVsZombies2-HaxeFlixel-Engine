// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/NormalPlacement.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.placements.VanillaPlacementID.VanillaPlacementNames;
import pvzengine.placements.PlacementDefinition;

@:autoPlacementDefinition(VanillaPlacementNames.normal)
class NormalPlacement extends PlacementDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaSpawnConditions.normal);
        AddMethod(VanillaPlaceMethods.entity);
        AddMethod(VanillaPlaceMethods.firstAid);
    }
}
