// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/SpawnConditions/DreamSilkSpawnCondition.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.contraptions.DreamSilk;
import mvz2.vanilla.grids.VanillaGridStatus;
import pvzengine.NamespaceID;
import pvzengine.entities.EntityDefinition;
import pvzengine.grids.LawnGrid;
import pvzengine.placements.PlacementDefinition;

class DreamSilkSpawnCondition extends ContraptionSpawnCondition
{
    override function GetSpawnErrorOfGrid(placement:PlacementDefinition, grid:LawnGrid, entity:EntityDefinition):Null<NamespaceID>
    {
        var entities = grid.GetEntities();
        if (entities.length <= 0 || !Lambda.exists(entities, e -> DreamSilk.CanSleep(e)))
            return VanillaGridStatus.onlyCanSleep;

        // 被占用。
        return super.GetSpawnErrorOfGrid(placement, grid, entity);
    }
}
