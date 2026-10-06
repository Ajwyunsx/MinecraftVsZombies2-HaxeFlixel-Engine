// Ported from: Assets/Scripts/Logic/Grids/LogicGridExt.cs
package mvz2logic.grids;

import Lambda;
import mvz2logic.blueprints.LogicSeedProps;
import mvz2logic.blueprints.SeedTypes;
import mvz2logic.callbacks.LogicLevelCallbacks;
import mvz2logic.callbacks.LogicLevelCallbacks.PlaceEntityParams;
import mvz2logic.callbacks.LogicLevelCallbacks.PostPlaceEntityParams;
import mvz2logic.callbacks.LogicLevelCallbacks.PostUseEntityBlueprintParams;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.helditems.HeldHighlight;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityDefinition;
import pvzengine.grids.LawnGrid;
import pvzengine.level.SpawnParams;
import pvzengine.placements.PlaceOutput;
import mvz2logic.placements.LogicPlaceProps;
import pvzengine.placements.PlaceParams;
import pvzengine.placements.PlacementDefinition;
import pvzengine.seedpacks.SeedDefinition;
import pvzengine.seedpacks.SeedPack;
import tools.Ref;
import unity.Vector3;

// PORT-NOTE: C# 扩展方法 (this LawnGrid grid) 改为静态方法，grid 作为第一个参数。
class LogicGridExt
{
	public static function GetSeedHeldHighlight(grid:LawnGrid, seedDef:Null<SeedDefinition>):HeldHighlight
	{
		if (seedDef == null)
			return HeldHighlight.None;

		if (LogicSeedProps.GetSeedType(seedDef) == SeedTypes.ENTITY)
		{
			var entityID = LogicSeedProps.GetSeedEntityID(seedDef);
			var entityDef = grid.Level.Content.GetEntityDefinition(entityID);
			if (entityDef == null)
				return HeldHighlight.None;

			var error = GetEntityPlaceStatus(grid, entityDef);
			var grids = Lambda.filter(LogicEntityProps.GetGridsToTakeOfGrid(entityDef, grid), function(g) return g != null);

			if (error == null)
			{
				return HeldHighlight.GreenMultiple(grids);
			}
			else
			{
				return HeldHighlight.RedMultiple(grids);
			}
		}
		else
		{
			var errorRef:Ref<Null<NamespaceID>> = Ref.to(null);
			if (CanPlaceBlueprint(grid, cast(seedDef, SeedDefinition), errorRef))
			{
				return HeldHighlight.Green(grid);
			}
			else
			{
				return HeldHighlight.Red(grid);
			}
		}
	}

	//region 放置音效
	public static function GetPlaceSound(grid:LawnGrid, entity:Entity):Null<NamespaceID>
	{
		return LogicEntityProps.GetPlaceSound(entity);
	}
	//endregion

	//region 放置蓝图
	public static function UseEntityBlueprint(grid:LawnGrid, seed:SeedPack, heldItemData:IHeldItemData):Void
	{
		var seedDef = seed.Definition;
		var param = new PlaceParams();
		LogicPlaceProps.SetCommandBlock(param, LogicSeedProps.IsCommandBlockOfPack(seed));
		LogicPlaceProps.SetVariant(param, LogicSeedProps.GetVariantOfPack(seed));

		var output = PlaceEntityBlueprint(grid, seedDef, param);
		if (output.IsInvalid())
			return;
		var level = grid.Level;
		level.Triggers.RunCallback(LogicLevelCallbacks.POST_USE_ENTITY_BLUEPRINT, new PostUseEntityBlueprintParams(output, seedDef, seed, heldItemData));
	}
	//endregion

	//region 放置蓝图定义
	/// <summary>
	/// 在一个网格的位置上放置一个蓝图。
	/// 如果是实体蓝图，则会调用 PlaceEntityBlueprint，放置一个实体，或在已有实体上堆叠。
	/// </summary>
	public static function UseEntityBlueprintDefinition(grid:LawnGrid, seedDef:SeedDefinition, heldItemData:IHeldItemData, isCommandBlock:Bool = false, variant:Int = 0):Void
	{
		if (seedDef == null)
			return;
		var param = new PlaceParams();
		LogicPlaceProps.SetCommandBlock(param, isCommandBlock);
		LogicPlaceProps.SetVariant(param, LogicSeedProps.GetVariant(seedDef));
		var output = PlaceEntityBlueprint(grid, seedDef, param);
		if (output.IsInvalid())
			return;
		var level = grid.Level;
		level.Triggers.RunCallback(LogicLevelCallbacks.POST_USE_ENTITY_BLUEPRINT, new PostUseEntityBlueprintParams(output, seedDef, null, heldItemData));
	}
	//endregion

	//region 生成实体
	public static function CanSpawnEntity(grid:LawnGrid, entityID:NamespaceID):Bool
	{
		return GetEntitySpawnStatusByID(grid, entityID) == null;
	}
	// TODO-PORT: C# 重载 GetEntitySpawnStatus(this LawnGrid, NamespaceID)，Haxe 不支持重载，重命名为 GetEntitySpawnStatusByID
	public static function GetEntitySpawnStatusByID(grid:LawnGrid, entityID:NamespaceID):Null<NamespaceID>
	{
		var level = grid.Level;
		var entityDef = level.Content.GetEntityDefinition(entityID);
		if (entityDef == null)
			return null;
		return GetEntitySpawnStatus(grid, entityDef);
	}
	public static function GetEntitySpawnStatus(grid:LawnGrid, entityDef:EntityDefinition):Null<NamespaceID>
	{
		var level = grid.Level;
		// 可放置。
		var placementID = entityDef.GetPlacementID();
		if (placementID == null)
			return null;
		var placementDef = level.Content.GetPlacementDefinition(placementID);
		if (placementDef == null)
			return null;
		return placementDef.GetSpawnError(grid, entityDef);
	}
	//endregion

	//region 放置实体
	// TODO-PORT: C# 重载 CanPlaceBlueprint(this LawnGrid, NamespaceID, out NamespaceID?)，Haxe 不支持重载，重命名为 CanPlaceBlueprintByID
	public static function CanPlaceBlueprintByID(grid:LawnGrid, seedID:NamespaceID, error:Ref<Null<NamespaceID>>):Bool
	{
		error.value = null;
		if (!NamespaceID.IsValid(seedID))
			return false;
		var level = grid.Level;
		var seedDef = level.Content.GetSeedDefinition(seedID);
		if (seedDef == null)
			return false;
		return CanPlaceBlueprint(grid, seedDef, error);
	}
	public static function CanPlaceBlueprint(grid:LawnGrid, seedDef:SeedDefinition, error:Ref<Null<NamespaceID>>):Bool
	{
		error.value = null;
		var level = grid.Level;
		if (LogicSeedProps.GetSeedType(seedDef) == SeedTypes.ENTITY)
		{
			var entityID = LogicSeedProps.GetSeedEntityID(seedDef);
			if (entityID == null)
				return false;
			error.value = GetEntityPlaceStatusByID(grid, entityID);
			return error.value == null;
		}
		return false;
	}
	public static function CanPlaceEntity(grid:LawnGrid, entityID:NamespaceID):Bool
	{
		return GetEntityPlaceStatusByID(grid, entityID) == null;
	}
	// TODO-PORT: C# 重载 GetEntityPlaceStatus(this LawnGrid, NamespaceID)，Haxe 不支持重载，重命名为 GetEntityPlaceStatusByID
	public static function GetEntityPlaceStatusByID(grid:LawnGrid, entityID:NamespaceID):Null<NamespaceID>
	{
		var level = grid.Level;
		var entityDef = level.Content.GetEntityDefinition(entityID);
		if (entityDef == null)
			return null;
		return GetEntityPlaceStatus(grid, entityDef);
	}
	public static function GetEntityPlaceStatus(grid:LawnGrid, entityDef:EntityDefinition):Null<NamespaceID>
	{
		var level = grid.Level;
		// 可放置。
		var placementID = entityDef.GetPlacementID();
		if (placementID == null)
			return null;
		var placementDef = level.Content.GetPlacementDefinition(placementID);
		if (placementDef == null)
			return null;
		return placementDef.GetPlaceError(grid, entityDef);
	}
	public static function PlaceEntityBlueprint(grid:LawnGrid, seedDef:SeedDefinition, param:PlaceParams):PlaceOutput
	{
		var id = LogicSeedProps.GetSeedEntityID(seedDef);
		if (id != null)
			return PlaceEntityByID(grid, id, param);
		return PlaceOutput.InvalidOutput;
	}
	// TODO-PORT: C# 重载 PlaceEntity(this LawnGrid, NamespaceID, PlaceParams)，Haxe 不支持重载，重命名为 PlaceEntityByID
	public static function PlaceEntityByID(grid:LawnGrid, entityID:NamespaceID, param:PlaceParams):PlaceOutput
	{
		var level = grid.Level;
		var entityDef = level.Content.GetEntityDefinition(entityID);
		if (entityDef != null)
			return PlaceEntity(grid, entityDef, param);
		return PlaceOutput.InvalidOutput;
	}
	public static function PlaceEntity(grid:LawnGrid, entityDef:EntityDefinition, param:PlaceParams):PlaceOutput
	{
		var level = grid.Level;
		var placementID = entityDef.GetPlacementID();
		if (placementID != null)
		{
			var placement = level.Content.GetPlacementDefinition(placementID);
			if (placement != null)
			{
				return PlaceEntityWithPlacement(grid, entityDef, placement, param);
			}
		}
		return PlaceOutput.InvalidOutput;
	}
	// TODO-PORT: C# 重载 PlaceEntity(this LawnGrid, EntityDefinition, PlacementDefinition, PlaceParams)，Haxe 不支持重载，重命名为 PlaceEntityWithPlacement
	public static function PlaceEntityWithPlacement(grid:LawnGrid, entityDef:EntityDefinition, placement:PlacementDefinition, param:PlaceParams):PlaceOutput
	{
		return placement.PlaceEntity(grid, entityDef, param);
	}
	public static function SpawnPlacedEntity(grid:LawnGrid, entityID:NamespaceID, ?param:SpawnParams):Null<Entity>
	{
		if (!PrePlaceEntity(grid, entityID))
			return null;

		var level = grid.Level;
		var entityDef = level.Content.GetEntityDefinition(entityID);
		if (entityDef == null)
			return null;

		var offset = LogicEntityProps.GetStartingPositionOffset(entityDef) - entityDef.GetGridPivotOffset();
		var x = level.GetEntityColumnX(grid.Column) + offset.x;
		var z = level.GetEntityLaneZ(grid.Lane) + offset.z;
		var y = level.GetGroundY(x, z) + offset.y;

		var position = new Vector3(x, y, z);
		var entity = level.Spawn(entityID, position, null, param);
		if (entity != null)
		{
			var e = entity;
			LogicEntityExt.PlaySoundIfNotNull(e, GetPlaceSound(grid, e));
			PostPlaceEntity(grid, e);
		}
		return entity;
	}
	static function PrePlaceEntity(grid:LawnGrid, entityID:NamespaceID):Bool
	{
		var level = grid.Level;
		var result = new CallbackResult(true);
		level.Triggers.RunCallbackWithResultFiltered(LogicLevelCallbacks.PRE_PLACE_ENTITY, new PlaceEntityParams(grid, entityID), result, entityID);
		// TODO-PORT: C# 为 result.GetValue<bool>()，Haxe 无法在无参情况下推断泛型参数，按非泛型形式调用。
		return result.GetValue();
	}
	static function PostPlaceEntity(grid:LawnGrid, entity:Entity):Void
	{
		var level = grid.Level;
		level.Triggers.RunCallbackFiltered(LogicLevelCallbacks.POST_PLACE_ENTITY, new PostPlaceEntityParams(grid, entity), entity.GetDefinitionID());
	}
	//endregion

	private function new() {}
}
