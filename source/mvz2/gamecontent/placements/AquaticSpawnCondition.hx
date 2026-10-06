// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/SpawnConditions/AquaticSpawnCondition.cs
package mvz2.gamecontent.placements;

import mvz2.vanilla.grids.VanillaGridLayers;
import mvz2.vanilla.grids.VanillaGridStatus;
import pvzengine.NamespaceID;
import pvzengine.entities.EntityDefinition;
import pvzengine.grids.LawnGrid;
import pvzengine.placements.PlacementDefinition;

class AquaticSpawnCondition extends ContraptionSpawnCondition
{
    override function GetSpawnErrorOfGrid(placement:PlacementDefinition, grid:LawnGrid, entity:EntityDefinition):Null<NamespaceID>
    {
        if (grid.IsCloud())
            return VanillaGridStatus.notOnAir;

        if (!grid.IsWater())
            return VanillaGridStatus.notOnLand;

        var error = super.GetSpawnErrorOfGrid(placement, grid, entity);
        if (error != null)
            return error;

        var carrier = grid.GetLayerEntity(VanillaGridLayers.carrier);
        if (carrier != null)
            return VanillaGridStatus.alreadyTaken;
        return null;
    }
}
