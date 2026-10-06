// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/SpawnConditions/AnySpawnCondition.cs
package mvz2.gamecontent.placements;

import pvzengine.NamespaceID;
import pvzengine.entities.EntityDefinition;
import pvzengine.grids.LawnGrid;
import pvzengine.placements.PlacementDefinition;
import pvzengine.placements.SpawnCondition;

class AnySpawnCondition extends SpawnCondition
{
    public function new() {}
    public override function GetSpawnError(placement:PlacementDefinition, grid:LawnGrid, entity:EntityDefinition):Null<NamespaceID>
    {
        return null;
    }
}
