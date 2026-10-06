// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/SpawnConditions/NormalSpawnCondition.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.contraptions.ICarrierBehaviour;
import mvz2.vanilla.grids.VanillaGridLayers;
import mvz2.vanilla.grids.VanillaGridStatus;
import pvzengine.NamespaceID;
import pvzengine.entities.EntityDefinition;
import pvzengine.grids.LawnGrid;
import pvzengine.placements.PlacementDefinition;

class NormalSpawnCondition extends ContraptionSpawnCondition
{
    override function GetSpawnErrorOfGrid(placement:PlacementDefinition, grid:LawnGrid, entity:EntityDefinition):Null<NamespaceID>
    {
        if (grid.IsWater())
        {
            var carrier = grid.GetLayerEntity(VanillaGridLayers.carrier);
            if (carrier == null || !carrier.Definition.HasBehaviour(ICarrierBehaviour))
            {
                return VanillaGridStatus.needLilypad;
            }
        }
        else if (grid.IsCloud())
        {
            return VanillaGridStatus.notOnAir;
        }
        return super.GetSpawnErrorOfGrid(placement, grid, entity);
    }
}
