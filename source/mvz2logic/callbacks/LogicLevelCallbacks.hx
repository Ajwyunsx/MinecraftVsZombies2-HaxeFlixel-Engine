// Ported from: Assets/Scripts/Logic/Callbacks/LogicLevelCallbacks.cs
package mvz2logic.callbacks;

import mvz2logic.blueprints.BlueprintChooseItem;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.IHeldItemTarget;
import mvz2logic.inputs.PointerInteractionData;
import mvz2logic.level.LevelSpawnPointParams;
import pvzengine.NamespaceID;
import pvzengine.SeedDefinition;
import pvzengine.SeedPack;
import pvzengine.callbacks.CallbackType;
import pvzengine.callbacks.LevelCallbackParams;
import pvzengine.callbacks.LevelCallbacks.EntityDeathParams;
import pvzengine.entities.Entity;
import pvzengine.grids.LawnGrid;
import pvzengine.level.LevelEngine;
import pvzengine.placements.PlaceOutput;

class LogicLevelCallbacks
{
	public static var POST_LEVEL_STOP:CallbackType<LevelCallbackParams> = new CallbackType<LevelCallbackParams>();
	public static var PRE_BATTLE:CallbackType<LevelCallbackParams> = new CallbackType<LevelCallbackParams>();
	public static var GET_BLUEPRINT_NOT_RECOMMONDED:CallbackType<GetBlueprintNotRecommondedParams> = new CallbackType<GetBlueprintNotRecommondedParams>();
	public static var GET_BLUEPRINT_WARNINGS:CallbackType<GetBlueprintWarningsParams> = new CallbackType<GetBlueprintWarningsParams>();
	public static var POST_BLUEPRINT_SELECTION:CallbackType<PostBlueprintSelectionParams> = new CallbackType<PostBlueprintSelectionParams>();
	public static var POST_USE_ENTITY_BLUEPRINT:CallbackType<PostUseEntityBlueprintParams> = new CallbackType<PostUseEntityBlueprintParams>();
	public static var PRE_PLACE_ENTITY:CallbackType<PlaceEntityParams> = new CallbackType<PlaceEntityParams>();
	public static var POST_PLACE_ENTITY:CallbackType<PostPlaceEntityParams> = new CallbackType<PostPlaceEntityParams>();
	public static var PRE_WAVE_ENEMY_SPAWN:CallbackType<WaveEnemySpawnParams> = new CallbackType<WaveEnemySpawnParams>();
	public static var POST_WAVE_ENEMY_SPAWN:CallbackType<WaveEnemySpawnParams> = new CallbackType<WaveEnemySpawnParams>();
	public static var POST_HUGE_WAVE_APPROACH:CallbackType<LevelCallbackParams> = new CallbackType<LevelCallbackParams>();
	public static var POST_FINAL_WAVE:CallbackType<LevelCallbackParams> = new CallbackType<LevelCallbackParams>();
	public static var CALCULATE_SPAWN_POINTS:CallbackType<CalculateSpawnPointParams> = new CallbackType<CalculateSpawnPointParams>();
	public static var ENTITY_DEATH_EFFECTS:CallbackType<EntityDeathParams> = new CallbackType<EntityDeathParams>();
	public static var POST_HELD_ITEM_EVENT:CallbackType<PostHeldItemEventParams> = new CallbackType<PostHeldItemEventParams>();
	public static var POST_PAUSE:CallbackType<LevelCallbackParams> = new CallbackType<LevelCallbackParams>();
	public static var POST_RESUME:CallbackType<LevelCallbackParams> = new CallbackType<LevelCallbackParams>();

	private function new() {}
}

class GetBlueprintNotRecommondedParams
{
	public var level:LevelEngine;
	public var blueprintID:NamespaceID;

	public function new(level:LevelEngine, blueprintID:NamespaceID)
	{
		this.level = level;
		this.blueprintID = blueprintID;
	}
}

class GetBlueprintWarningsParams
{
	public var level:LevelEngine;
	public var blueprintsForChoose:Array<NamespaceID>;
	public var chosenBlueprints:Array<BlueprintChooseItem>;
	public var warnings:Array<String>;

	public function new(level:LevelEngine, blueprintsForChoose:Array<NamespaceID>, chosenBlueprints:Array<BlueprintChooseItem>, warnings:Array<String>)
	{
		this.level = level;
		this.blueprintsForChoose = blueprintsForChoose;
		this.chosenBlueprints = chosenBlueprints;
		this.warnings = warnings;
	}
}

class PostBlueprintSelectionParams
{
	public var level:LevelEngine;
	public var chosenBlueprints:Array<BlueprintChooseItem>;

	public function new(level:LevelEngine, chosenBlueprints:Array<BlueprintChooseItem>)
	{
		this.level = level;
		this.chosenBlueprints = chosenBlueprints;
	}
}

class PostUseEntityBlueprintParams
{
	public var placeOutput:PlaceOutput;
	public var definition:SeedDefinition;
	public var blueprint:Null<SeedPack>;
	public var heldData:IHeldItemData;

	public function new(placeOutput:PlaceOutput, definition:SeedDefinition, blueprint:Null<SeedPack>, heldData:IHeldItemData)
	{
		this.placeOutput = placeOutput;
		this.definition = definition;
		this.blueprint = blueprint;
		this.heldData = heldData;
	}
}

class PlaceEntityParams
{
	public var grid:LawnGrid;
	public var entityID:NamespaceID;

	public function new(grid:LawnGrid, entityID:NamespaceID)
	{
		this.grid = grid;
		this.entityID = entityID;
	}
}

class PostPlaceEntityParams
{
	public var grid:LawnGrid;
	public var entity:Entity;

	public function new(grid:LawnGrid, entity:Entity)
	{
		this.grid = grid;
		this.entity = entity;
	}
}

class WaveEnemySpawnParams
{
	public var level:LevelEngine;
	public var wave:Int;
	public var maxPoints:Float;

	public function new(level:LevelEngine, wave:Int, maxPoints:Float)
	{
		this.level = level;
		this.wave = wave;
		this.maxPoints = maxPoints;
	}
}

class CalculateSpawnPointParams
{
	public var level:LevelEngine;
	public var wave:Int;
	public var flags:Int;
	// PORT-NOTE: C# LevelSpawnPointParams 定义在 LogicLevelExt.cs 中（与 LogicLevelExt 同文件），Haxe 中拆为独立模块 mvz2logic.level.LevelSpawnPointParams（避免与 LogicLevelExt 循环引用子类型）。
	public var param:LevelSpawnPointParams;

	public function new(level:LevelEngine, wave:Int, flags:Int, param:LevelSpawnPointParams)
	{
		this.level = level;
		this.wave = wave;
		this.flags = flags;
		this.param = param;
	}
}

class PostHeldItemEventParams
{
	public var level:LevelEngine;
	public var target:IHeldItemTarget;
	public var data:IHeldItemData;
	public var pointerInteraction:PointerInteractionData;

	public function new(level:LevelEngine, target:IHeldItemTarget, data:IHeldItemData, pointerInteraction:PointerInteractionData)
	{
		this.level = level;
		this.target = target;
		this.data = data;
		this.pointerInteraction = pointerInteraction;
	}
}
