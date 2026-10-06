// Ported from: Assets/Scripts/Logic/HeldItems/LogicHeldItemExt.cs
package mvz2logic.helditems;

import mvz2logic.games.LogicGameDefinitionsExt;
import mvz2logic.level.LogicHeldItemProps;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import pvzengine.seedpacks.ClassicSeedPack;
import pvzengine.seedpacks.ConveyorSeedPack;
import pvzengine.seedpacks.SeedPack;

// PORT-NOTE: C# 扩展方法 (this IHeldItemData data) / (this HeldItemDefinition) 改为静态方法。
class LogicHeldItemExt
{
	public static function GetDefinition(data:IHeldItemData, level:LevelEngine):Null<HeldItemDefinition>
	{
		return LogicGameDefinitionsExt.GetHeldItemDefinition(level.Content, data.Type);
	}
	public static function GetHoldingEntity(data:IHeldItemData, level:LevelEngine):Null<Entity>
	{
		var entityID = LogicHeldItemProps.GetEntityID(data);
		return level.FindEntityByID(entityID);
	}
	public static function IsHoldingBlueprint(data:IHeldItemData, level:LevelEngine, seedPack:SeedPack):Bool
	{
		if (Std.isOfType(seedPack, ClassicSeedPack))
		{
			var classic = cast(seedPack, ClassicSeedPack);
			var classicIndex = level.GetSeedPackIndex(classic);
			if (classicIndex >= 0)
			{
				return IsHoldingClassicBlueprint(data, classicIndex);
			}
		}
		if (Std.isOfType(seedPack, ConveyorSeedPack))
		{
			var conveyor = cast(seedPack, ConveyorSeedPack);
			var conveyorIndex = level.GetConveyorSeedPackIndex(conveyor);
			if (conveyorIndex >= 0)
			{
				return IsHoldingConveyorBlueprint(data, conveyorIndex);
			}
		}
		return false;
	}
	public static function IsHoldingClassicBlueprint(heldItemData:IHeldItemData, i:Int):Bool
	{
		return heldItemData != null && heldItemData.Type == LogicHeldTypes.blueprint && LogicHeldItemProps.GetSeedPackIndex(heldItemData) == i;
	}
	public static function IsHoldingConveyorBlueprint(heldItemData:IHeldItemData, i:Int):Bool
	{
		return heldItemData != null && heldItemData.Type == LogicHeldTypes.conveyor && LogicHeldItemProps.GetSeedPackIndex(heldItemData) == i;
	}
	public static function GetSeedPack(heldItemDef:HeldItemDefinition, level:LevelEngine, data:Null<IHeldItemData>):Null<SeedPack>
	{
		if (data == null)
			return null;
		var behaviours = heldItemDef.GetBehaviours();
		for (behaviour in behaviours)
		{
			if (!Std.isOfType(behaviour, IBlueprintHeldItemBehaviour))
				continue;
			return (cast behaviour:IBlueprintHeldItemBehaviour).GetSeedPack(level, data);
		}
		return null;
	}

	private function new() {}
}
