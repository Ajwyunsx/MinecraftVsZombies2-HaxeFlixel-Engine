// Ported from: Assets/Scripts/Vanilla/GameContent/Grids/VanillaGridExt.cs
package mvz2.vanilla.grids;

import mvz2.gamecontent.grids.VanillaGridModelTypes;
import mvz2logic.grids.LogicGridProps;
import pvzengine.entities.Entity;
import pvzengine.grids.LawnGrid;
import tools.Ref;

// PORT-NOTE: C# 扩展方法 → 以 LawnGrid 为首参的静态方法（PORTING.md §扩展方法）。
class VanillaGridExt
{

    // #region 层级
    public static function GetCarrierEntity(grid:LawnGrid):Null<Entity>
    {
        return grid.GetLayerEntity(VanillaGridLayers.carrier);
    }
    public static function GetMainEntity(grid:LawnGrid):Null<Entity>
    {
        return grid.GetLayerEntity(VanillaGridLayers.main);
    }
    public static function GetToolEntity(grid:LawnGrid):Null<Entity>
    {
        return grid.GetLayerEntity(VanillaGridLayers.tool);
    }
    public static function GetProtectorEntity(grid:LawnGrid):Null<Entity>
    {
        return grid.GetLayerEntity(VanillaGridLayers.protector);
    }
    // #endregion

    // #region 导电
    public static function IsConductive(grid:LawnGrid):Bool
    {
        if (LogicGridProps.IsWater(grid))
            return true;
        if (LogicGridProps.IsWet(grid))
            return true;
        return false;
    }
    // #endregion

    // #region 获取指向实体
    // PORT-NOTE: C# `out float rangeMin, out float rangeMax` → tools.Ref<Float>。
    public static function FindPointerTargetEntity(grid:LawnGrid, pointerPosition:Float, predicate:Entity->Bool, rangeMin:Ref<Float>, rangeMax:Ref<Float>):Null<Entity>
    {
        var protector = GetProtectorEntity(grid);
        var protectedLayers = VanillaGridLayers.protectedLayers;
        var hasProtector = protector != null;

        var column = grid.Column;
        var lane = grid.Lane;
        var protectedEntities = Lambda.array(Lambda.filter(Lambda.map(protectedLayers, t -> grid.GetLayerEntity(t)), e -> e != null));
        var hasMain = protectedEntities.length > 0;
        var validMain = Lambda.find(protectedEntities, t -> t.GetColumn() == column && t.GetLane() == lane && predicate(t));

        var canUseOnProtector = protector != null && predicate(protector);
        var canUseOnMain = validMain != null;

        rangeMin.value = 0;
        rangeMax.value = 1;

        if (canUseOnProtector && canUseOnMain)
        {
            // 两者都可以使用，根据 pointerPosition 选择
            if (pointerPosition < 0.5)
            {
                // 指向下方，选择保护层
                rangeMax.value = 0.5;
                return protector;
            }
            else
            {
                // 指向上方，选择主要层
                rangeMin.value = 0.5;
                return validMain;
            }
        }

        if (canUseOnProtector)
        {
            // 只能使用保护层
            if (hasMain)
            {
                // 存在主要层但不可用
                rangeMax.value = 0.5;
            }
            return protector;
        }

        if (canUseOnMain)
        {
            // 只能使用主要层
            if (hasProtector)
            {
                // 存在保护层但不可用
                rangeMin.value = 0.5;
            }
            return validMain;
        }
        return null;
    }
    // #endregion
    public static function GetGridModelType(grid:LawnGrid):Int
    {
        if (LogicGridProps.GetSlope(grid) > 0)
        {
            return VanillaGridModelTypes.TYPE_SLOPE;
        }
        if (LogicGridProps.IsCloudOfDefinition(grid.Definition))
        {
            return VanillaGridModelTypes.TYPE_CLOUD;
        }
        if (LogicGridProps.IsWaterOfDefinition(grid.Definition))
        {
            return VanillaGridModelTypes.TYPE_WATER;
        }
        return VanillaGridModelTypes.TYPE_NORMAL;
    }
}
