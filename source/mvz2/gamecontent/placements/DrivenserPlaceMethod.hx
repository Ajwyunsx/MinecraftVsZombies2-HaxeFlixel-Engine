// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/PlaceMethods/DrivenserPlaceMethod.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.contraptions.Drivenser;
import mvz2.vanilla.grids.VanillaGridStatus;
import pvzengine.NamespaceID;
import pvzengine.entities.EntityDefinition;
import pvzengine.grids.LawnGrid;
import pvzengine.placements.PlaceMethod;
import pvzengine.placements.PlaceOutput;
import pvzengine.placements.PlaceParams;
import pvzengine.placements.PlacementDefinition;

class DrivenserPlaceMethod extends PlaceMethod
{
    public function new() {}
    public override function GetPlaceError(placement:PlacementDefinition, grid:LawnGrid, entity:EntityDefinition):Null<NamespaceID>
    {
        var entities = grid.GetEntities();
        if (entities.length <= 0 || !Lambda.exists(entities, e -> Drivenser.CanUpgrade(e)))
        {
            return VanillaGridStatus.onlyUpgrade;
        }
        return null;
    }

    public override function PlaceEntity(placement:PlacementDefinition, grid:LawnGrid, entity:EntityDefinition, param:PlaceParams):PlaceOutput
    {
        var entities = grid.GetEntities();
        var drivenser = Lambda.find(entities, e -> Drivenser.CanUpgrade(e));
        if (drivenser == null)
            return PlaceOutput.InvalidOutput;
        Drivenser.Upgrade(drivenser);
        // PORT-NOTE: C# 对象初始化器 new PlaceOutput(e, d) { f = v } → 逐字段赋值。
        var output = new PlaceOutput(drivenser, entity);
        output.increaseTakenConveyorSeed = true;
        return output;
    }
}
