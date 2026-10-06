// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/AnyPlacement.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.placements.VanillaPlacementID.VanillaPlacementNames;
import pvzengine.placements.PlacementDefinition;

@:autoPlacementDefinition(VanillaPlacementNames.any)
class AnyPlacement extends PlacementDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaSpawnConditions.any);
        AddMethod(VanillaPlaceMethods.entity);
    }
}
