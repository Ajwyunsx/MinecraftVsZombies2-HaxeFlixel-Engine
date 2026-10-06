// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/PlaceMethods/FirstAidPlaceMethod.cs
package mvz2.gamecontent.placements;

import mvz2.vanilla.contraptions.VanillaContraptionExt;
import mvz2.vanilla.contraptions.VanillaContraptionProps;
import mvz2.vanilla.grids.VanillaGridStatus;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.Global;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityDefinition;
import pvzengine.grids.LawnGrid;
import pvzengine.placements.PlaceMethod;
import pvzengine.placements.PlaceOutput;
import pvzengine.placements.PlaceParams;
import pvzengine.placements.PlacementDefinition;
using mvz2logic.entities.LogicEntityExt;

class FirstAidPlaceMethod extends PlaceMethod
{
    public function new() {}
    public override function GetPlaceError(placement:PlacementDefinition, grid:LawnGrid, entity:EntityDefinition):Null<NamespaceID>
    {
        if (!Global.Saves.IsUnlocked(VanillaUnlockID.obsidianFirstAid))
            return VanillaGridStatus.notUnlocked;
        if (!VanillaContraptionProps.IsDefensiveOfDefinition(entity))
            return VanillaGridStatus.firstAid;
        var entities = grid.GetEntities();
        if (entities.length <= 0 || !Lambda.exists(entities, e -> CanFirstAid(entity, e)))
        {
            return VanillaGridStatus.firstAid;
        }
        return null;
    }
    public override function PlaceEntity(placement:PlacementDefinition, grid:LawnGrid, entityDef:EntityDefinition, param:PlaceParams):PlaceOutput
    {
        if (VanillaContraptionProps.IsDefensiveOfDefinition(entityDef))
        {
            var entities = grid.GetEntities();
            var entity = Lambda.find(entities, e -> CanFirstAid(entityDef, e));
            // PORT-NOTE: C# 扩展方法 ExistsAndAlive(this Entity) 对 null 返回 false；Haxe 需先显式判空。
            if (entity != null && entity.ExistsAndAlive())
            {
                VanillaContraptionExt.FirstAid(entity);
                // PORT-NOTE: C# 对象初始化器 new PlaceOutput(e, d) { f = v } → 逐字段赋值。
                var output = new PlaceOutput(entity, entityDef);
                output.increaseTakenConveyorSeed = false;
                return output;
            }
        }
        return PlaceOutput.InvalidOutput;
    }
    function CanFirstAid(entityDef:EntityDefinition, entity:Entity):Bool
    {
        if (entity.Definition != entityDef)
            return false;
        if (entity.Health >= entity.GetMaxHealth())
            return false;
        if (!entity.IsFriendlyEntity())
            return false;
        return true;
    }
}
