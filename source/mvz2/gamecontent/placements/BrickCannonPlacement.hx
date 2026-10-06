// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/BrickCannonPlacement.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.placements.VanillaPlacementID.VanillaPlacementNames;
import pvzengine.placements.PlacementDefinition;

@:autoPlacementDefinition(VanillaPlacementNames.brickCannon)
class BrickCannonPlacement extends PlacementDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaSpawnConditions.normal);
        AddMethod(VanillaPlaceMethods.upgradeSideBySide);
    }
}
