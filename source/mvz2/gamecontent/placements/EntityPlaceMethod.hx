// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/PlaceMethods/EntityPlaceMethod.cs
package mvz2.gamecontent.placements;

import mvz2.gamecontent.contraptions.CommandBlock;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.placements.LogicPlaceProps;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityDefinition;
import pvzengine.grids.LawnGrid;
import pvzengine.level.SpawnParams;
import pvzengine.placements.PlaceMethod;
import pvzengine.placements.PlaceOutput;
import pvzengine.placements.PlaceParams;
import pvzengine.placements.PlacementDefinition;

class EntityPlaceMethod extends PlaceMethod
{
    public function new() {}
    public override function GetPlaceError(placement:PlacementDefinition, grid:LawnGrid, entity:EntityDefinition):Null<NamespaceID>
    {
        return placement.GetSpawnError(grid, entity);
    }
    public override function PlaceEntity(placement:PlacementDefinition, grid:LawnGrid, entity:EntityDefinition, param:PlaceParams):PlaceOutput
    {
        var commandBlock = LogicPlaceProps.IsCommandBlock(param);
        var ent:Null<Entity> = null;
        if (commandBlock)
        {
            var spawnParam = CommandBlock.GetImitateSpawnParams(entity.GetID());
            spawnParam.SetProperty(LogicEntityProps.VARIANT, LogicPlaceProps.GetVariant(param));
            ent = grid.SpawnPlacedEntity(VanillaContraptionID.commandBlock, spawnParam);
        }
        else
        {
            var spawnParam = new SpawnParams();
            spawnParam.SetProperty(LogicEntityProps.VARIANT, LogicPlaceProps.GetVariant(param));
            ent = grid.SpawnPlacedEntity(entity.GetID(), spawnParam);
        }
        // PORT-NOTE: C# 对象初始化器 new PlaceOutput(e, d) { f = v } → 逐字段赋值。
        var output = new PlaceOutput(ent, entity);
        output.isCommandBlock = commandBlock;
        output.increaseTakenConveyorSeed = true;
        return output;
    }
}
