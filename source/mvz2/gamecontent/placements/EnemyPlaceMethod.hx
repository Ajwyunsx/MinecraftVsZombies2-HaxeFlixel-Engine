// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/PlaceMethods/EnemyPlaceMethod.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.grids.VanillaGridStatus;
import pvzengine.NamespaceID;
import pvzengine.entities.EntityDefinition;
import pvzengine.grids.LawnGrid;
import pvzengine.placements.PlacementDefinition;

class EnemyPlaceMethod extends EntityPlaceMethod
{
    public override function GetPlaceError(placement:PlacementDefinition, grid:LawnGrid, entity:EntityDefinition):Null<NamespaceID>
    {
        var level = grid.Level;
        if (level.IsIZombie() && !VanillaEntityProps.IgnoreRedlinePlacementOfDefinition(entity))
        {
            var lane = grid.Lane;
            var line = level.FindFirstEntityWithTheLeast(e -> e.IsEntityOf(VanillaEffectID.redline) && e.GetLane() == lane, e -> e.Position.x);
            if (line != null)
            {
                var column = grid.Column;
                var gridX = level.GetEntityColumnX(column);
                if (gridX < line.Position.x)
                {
                    return VanillaGridStatus.rightOfLine;
                }
            }
        }
        return super.GetPlaceError(placement, grid, entity);
    }
}
