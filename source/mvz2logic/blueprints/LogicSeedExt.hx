// Ported from: Assets/Scripts/Logic/Blueprints/LogicSeedExt.cs
package mvz2logic.blueprints;

import mvz2logic.Global;
import mvz2logic.entities.LogicContraptionProps;
import mvz2logic.games.LogicGameExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import pvzengine.seedpacks.ClassicSeedPack;
import pvzengine.seedpacks.SeedDefinition;
import pvzengine.seedpacks.SeedPack;
import tools.Ref;

// PORT-NOTE: C# 扩展方法 (this SeedPack seed) / (this SeedDefinition definition) 改为静态方法。
class LogicSeedExt
{
	public static function CanPick(seed:SeedPack):Bool
	{
		var errorMessage:Ref<Null<String>> = Ref.to(null);
		return CanPickWithError(seed, errorMessage);
	}
	// TODO-PORT: C# 重载 CanPick(this SeedPack, out string?)，Haxe 不支持重载，重命名为 CanPickWithError
	public static function CanPickWithError(seed:SeedPack, errorMessage:Ref<Null<String>>):Bool
	{
		var id = GetPickError(seed);
		if (NamespaceID.IsValid(id))
		{
			errorMessage.value = LogicGameExt.GetBlueprintErrorMessage(Global.Game, id);
			return false;
		}
		errorMessage.value = null;
		return true;
	}
	public static function GetPickError(seed:SeedPack):Null<NamespaceID>
	{
		if (seed == null)
		{
			return LogicBlueprintErrors.invalid;
		}
		else if (Std.isOfType(seed, ClassicSeedPack))
		{
			if (!seed.IsCharged())
			{
				return LogicBlueprintErrors.recharging;
			}
			else if (seed.Level.Energy < seed.GetCost())
			{
				return LogicBlueprintErrors.notEnoughEnergy;
			}
		}
		if (seed.IsDisabled())
		{
			return seed.GetDisableID();
		}
		return null;
	}
	public static function CanInstantTrigger(seedPack:SeedPack):Bool
	{
		var blueprintDef = seedPack.Definition;
		return LogicSeedProps.IsTriggerActive(blueprintDef) && LogicSeedProps.CanInstantTrigger(blueprintDef);
	}
	public static function WillInstantEvokeOfPack(seedPack:SeedPack):Bool
	{
		var blueprintDef = seedPack.Definition;
		return WillInstantEvoke(blueprintDef, seedPack.Level);
	}
	public static function WillInstantEvoke(definition:SeedDefinition, level:LevelEngine):Bool
	{
		if (definition == null)
			return false;
		if (!LogicSeedProps.CanInstantEvoke(definition))
			return false;
		if (LogicLevelExt.IsDay(level))
		{
			var entityID = LogicSeedProps.GetSeedEntityID(definition);
			if (entityID == null)
				return false;
			var entityDef = level.Content.GetEntityDefinition(entityID);
			if (entityDef == null || LogicContraptionProps.IsNocturnalOfDefinition(entityDef))
				return false;
		}
		return true;
	}

	private function new() {}
}
