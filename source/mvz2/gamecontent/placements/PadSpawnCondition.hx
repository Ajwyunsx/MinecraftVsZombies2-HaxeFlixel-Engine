// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/SpawnConditions/PadSpawnCondition.cs
package mvz2.gamecontent.placements;

import mvz2.vanilla.grids.VanillaGridStatus;
import pvzengine.NamespaceID;
import pvzengine.entities.EntityDefinition;
import pvzengine.grids.LawnGrid;
import pvzengine.placements.PlacementDefinition;

class PadSpawnCondition extends ContraptionSpawnCondition
{
    override function GetSpawnErrorOfGrid(placement:PlacementDefinition, grid:LawnGrid, entity:EntityDefinition):Null<NamespaceID>
    {
        if (grid.IsCloud())
            return VanillaGridStatus.notOnAir;
        if (grid.IsWater())
            return VanillaGridStatus.notOnWater;
        return super.GetSpawnErrorOfGrid(placement, grid, entity);
    }
}
