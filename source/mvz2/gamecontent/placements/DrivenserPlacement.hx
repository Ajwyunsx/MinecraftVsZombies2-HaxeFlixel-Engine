// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/DrivenserPlacement.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.placements.VanillaPlacementID.VanillaPlacementNames;
import pvzengine.placements.PlacementDefinition;

@:autoPlacementDefinition(VanillaPlacementNames.drivenser)
class DrivenserPlacement extends PlacementDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaSpawnConditions.normal);
        AddMethod(VanillaPlaceMethods.entity);
        AddMethod(VanillaPlaceMethods.drivenser);
    }
}
