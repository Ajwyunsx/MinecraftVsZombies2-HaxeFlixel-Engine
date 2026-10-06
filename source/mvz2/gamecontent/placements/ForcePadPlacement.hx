// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/ForcePadPlacement.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.placements.VanillaPlacementID.VanillaPlacementNames;
import pvzengine.placements.PlacementDefinition;

@:autoPlacementDefinition(VanillaPlacementNames.forcePad)
class ForcePadPlacement extends PlacementDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, VanillaSpawnConditions.pad);
        AddMethod(VanillaPlaceMethods.upgrade);
    }
}
