// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/SpawnConditions/ContraptionSpawnCondition.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.obstacles.VanillaObstacleID;
import mvz2.vanilla.grids.VanillaGridStatus;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityDefinition;
import pvzengine.grids.LawnGrid;
import pvzengine.placements.PlacementDefinition;
import pvzengine.placements.SpawnCondition;

// abstract
class ContraptionSpawnCondition extends SpawnCondition
{
    public function new() {}
    // C#: public sealed override NamespaceID? GetSpawnError(PlacementDefinition placement, LawnGrid grid, EntityDefinition entity)
    public override function GetSpawnError(placement:PlacementDefinition, grid:LawnGrid, entity:EntityDefinition):Null<NamespaceID>
    {
        var extraGrids = LogicEntityProps.GetGridsToTakeOfGrid(entity, grid);
        var thisGridError = GetSpawnErrorOfGrid(placement, grid, entity);
        if (thisGridError != null)
            return thisGridError;

        for (extraGrid in extraGrids)
        {
            if (extraGrid == null)
                return VanillaGridStatus.outOfBounds;
            var error = GetSpawnErrorOfGrid(placement, extraGrid, entity);
            if (error != null)
                return error;
        }
        return null;
    }
    // C#: protected virtual NamespaceID? GetSpawnErrorOfGrid(PlacementDefinition placement, LawnGrid grid, EntityDefinition entity)
    function GetSpawnErrorOfGrid(placement:PlacementDefinition, grid:LawnGrid, entity:EntityDefinition):Null<NamespaceID>
    {
        if (grid.IsDisabled())
            return VanillaGridStatus.gridDisabled;
        var layersToTake = LogicEntityProps.GetGridLayersToTakeOfDefinition(entity);
        // PORT-NOTE: C# LINQ `.Select(l => grid.GetLayerEntity(l)).OfType<Entity>()` → 显式循环并过滤 null。
        var conflictEntities:Array<Entity> = [];
        for (layer in layersToTake)
        {
            var ent = grid.GetLayerEntity(layer);
            if (ent != null)
                conflictEntities.push(ent);
        }
        if (conflictEntities.length > 0)
        {
            for (ent in conflictEntities)
            {
                if (ent.IsEntityOf(VanillaObstacleID.gargoyleStatue))
                {
                    return VanillaGridStatus.notOnStatues;
                }
                if (ent.IsEntityOf(VanillaObstacleID.monsterSpawner))
                {
                    return VanillaGridStatus.notOnSpawners;
                }
            }
            return VanillaGridStatus.alreadyTaken;
        }
        return null;
    }
}
