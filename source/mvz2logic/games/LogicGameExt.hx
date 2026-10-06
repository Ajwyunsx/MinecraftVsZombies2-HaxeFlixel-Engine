// Ported from: Assets/Scripts/Logic/Game/LogicGameExt.cs
package mvz2logic.games;

import mvz2logic.Global;
import mvz2logic.artifacts.LogicArtifactProps;
import mvz2logic.blueprints.EntitySeedDefinition;
import mvz2logic.blueprints.LogicSeedOptionProps;
import mvz2logic.blueprints.LogicSeedProps;
import mvz2logic.blueprints.SeedTypes;
import mvz2logic.callbacks.LogicCallbacks;
import mvz2logic.callbacks.LogicCallbacks.GetInnateArtifactsParams;
import mvz2logic.callbacks.LogicCallbacks.GetInnateBlueprintsParams;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.localization.LogicStrings;
import mvz2logic.difficulties.LogicDifficultyProps;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.StringCallbackParams;

// PORT-NOTE: C# 扩展方法 (this IGlobalGame game) 改为静态方法，game 作为第一个参数。
class LogicGameExt
{
	public static function IsSpecialUserName(game:IGlobalGame, name:String):Bool
	{
		var result = new CallbackResult(false);
		game.RunCallbackWithResult(LogicCallbacks.IS_SPECIAL_USER_NAME, new StringCallbackParams(name), result);
		// TODO-PORT: C# 为 result.GetValue<bool>()，Haxe 无法在无参情况下推断泛型参数，按非泛型形式调用。
		return result.GetValue();
	}
	public static function GetInnateBlueprints(game:IGlobalGame):Array<NamespaceID>
	{
		var list:Array<NamespaceID> = [];
		var param = new GetInnateBlueprintsParams();
		param.list = list;
		game.RunCallback(LogicCallbacks.GET_INNATE_BLUEPRINTS, param);
		return list;
	}
	public static function GetInnateArtifacts(game:IGlobalGame):Array<NamespaceID>
	{
		var list:Array<NamespaceID> = [];
		var param = new GetInnateArtifactsParams();
		param.list = list;
		game.RunCallback(LogicCallbacks.GET_INNATE_ARTIFACTS, param);
		return list;
	}

	public static function GetEntityName(game:IGlobalGame, entityID:Null<NamespaceID>):String
	{
		if (entityID == null)
			return "null";
		var def = game.GetEntityDefinition(entityID);
		if (def == null)
			return entityID.toString();
		var name = LogicEntityProps.GetEntityName(def);
		if (name == null)
			name = LogicStrings.UNKNOWN_ENTITY_NAME;
		return Global.Localization.GetTextParticular(name, LogicStrings.CONTEXT_ENTITY_NAME);
	}
	public static function GetEntityTooltip(game:IGlobalGame, entityID:Null<NamespaceID>):String
	{
		if (entityID == null)
			return "null";
		var def = game.GetEntityDefinition(entityID);
		if (def == null)
			return entityID.toString();
		var tooltip = LogicEntityProps.GetEntityTooltip(def);
		if (tooltip == null)
			tooltip = LogicStrings.UNKNOWN_ENTITY_TOOLTIP;
		return Global.Localization.GetTextParticular(tooltip, LogicStrings.CONTEXT_ENTITY_TOOLTIP);
	}

	public static function GetEntityDeathMessage(game:IGlobalGame, entityID:Null<NamespaceID>):String
	{
		var key = LogicStrings.DEATH_MESSAGE_UNKNOWN;
		if (entityID != null)
		{
			var def = game.GetEntityDefinition(entityID);
			var deathMessage = def != null ? LogicEntityProps.GetDeathMessage(def) : null;
			if (deathMessage != null)
			{
				key = deathMessage;
			}
		}
		return Global.Localization.GetTextParticular(key, LogicStrings.CONTEXT_DEATH_MESSAGE);
	}

	//region 制品
	public static function GetArtifactName(game:IGlobalGame, artifactID:Null<NamespaceID>):String
	{
		if (artifactID == null)
			return "null";
		var def = LogicGameDefinitionsExt.GetArtifactDefinition(game, artifactID);
		if (def == null)
			return artifactID.toString();
		var name = LogicArtifactProps.GetArtifactName(def);
		if (name == null)
			name = LogicStrings.UNKNOWN_ARTIFACT_NAME;
		return Global.Localization.GetTextParticular(name, LogicStrings.CONTEXT_ARTIFACT_NAME);
	}
	public static function GetArtifactTooltip(game:IGlobalGame, artifactID:Null<NamespaceID>):String
	{
		if (artifactID == null)
			return "null";
		var def = LogicGameDefinitionsExt.GetArtifactDefinition(game, artifactID);
		if (def == null)
			return artifactID.toString();
		var tooltip = LogicArtifactProps.GetArtifactTooltip(def);
		if (tooltip == null)
			tooltip = LogicStrings.UNKNOWN_ARTIFACT_TOOLTIP;
		return Global.Localization.GetTextParticular(tooltip, LogicStrings.CONTEXT_ARTIFACT_TOOLTIP);
	}
	//endregion

	public static function GetGridErrorMessage(game:IGlobalGame, id:Null<NamespaceID>):Null<String>
	{
		var def = LogicGameDefinitionsExt.GetGridErrorDefinition(game, id);
		if (def == null)
			return null;
		return def.Message;
	}
	public static function GetBlueprintErrorMessage(game:IGlobalGame, id:Null<NamespaceID>):Null<String>
	{
		var def = LogicGameDefinitionsExt.GetSeedErrorDefinition(game, id);
		if (def == null)
			return null;
		return def.Message;
	}
	public static function GetEntityCounterName(game:IGlobalGame, counterID:Null<NamespaceID>):String
	{
		if (counterID == null)
			return "null";
		var def = LogicGameDefinitionsExt.GetEntityCounterDefinition(game, counterID);
		if (def == null)
			return counterID.toString();
		var name = def.CounterName;
		if (name == null)
			name = LogicStrings.UNKNOWN_ENTITY_COUNTER_NAME;
		return Global.Localization.GetTextParticular(name, LogicStrings.CONTEXT_ENTITY_COUNTER_NAME);
	}
	public static function GetDifficultyName(game:IGlobalGame, difficulty:NamespaceID):String
	{
		if (difficulty == null)
			return "null";
		var def = game.GetDifficultyDefinition(difficulty);
		if (def == null)
			return difficulty.toString();
		var name = LogicDifficultyProps.GetName(def);
		if (name == null)
			name = LogicStrings.DIFFICULTY_UNKNOWN;
		return Global.Localization.GetTextParticular(name, LogicStrings.CONTEXT_DIFFICULTY);
	}
	public static function GetSeedOptionName(game:IGlobalGame, id:NamespaceID):String
	{
		if (id == null)
			return "null";
		var def = LogicGameDefinitionsExt.GetSeedOptionDefinition(game, id);
		if (def == null)
			return id.toString();
		var name = LogicSeedOptionProps.GetOptionName(def);
		if (name == null)
			name = LogicStrings.UNKNOWN_OPTION_NAME;
		return Global.Localization.GetTextParticular(name, LogicStrings.CONTEXT_BLUEPRINT_OPTION_NAME);
	}
	public static function GetSeedOptionTooltip(game:IGlobalGame, id:NamespaceID):String
	{
		if (id == null)
			return "null";
		var def = LogicGameDefinitionsExt.GetSeedOptionDefinition(game, id);
		if (def == null)
			return id.toString();
		var name = LogicSeedOptionProps.GetOptionTooltip(def);
		if (name == null)
			name = "";
		return Global.Localization.GetTextParticular(name, LogicStrings.CONTEXT_BLUEPRINT_OPTION_TOOLTIP);
	}
	public static function GetBlueprintName(game:IGlobalGame, blueprintID:NamespaceID):String
	{
		var name = "";
		var definition = game.GetSeedDefinition(blueprintID);
		if (definition == null)
			return name;
		var seedType = LogicSeedProps.GetSeedType(definition);
		if (seedType == SeedTypes.ENTITY)
		{
			var customEntityDef = LogicGameDefinitionsExt.GetEntitySeedDefinition(game, blueprintID);
			var customName = customEntityDef != null ? customEntityDef.BlueprintName : null;
			if (customName != null && customName.length > 0)
			{
				name = Global.Localization.GetTextParticular(customName, LogicStrings.CONTEXT_ENTITY_NAME);
			}
			else
			{
				var entityID = LogicSeedProps.GetSeedEntityID(definition);
				name = entityID != null ? GetEntityName(game, entityID) : name;
			}
		}
		else if (seedType == SeedTypes.OPTION)
		{
			var optionID = LogicSeedProps.GetSeedOptionID(definition);
			name = optionID != null ? GetSeedOptionName(game, optionID) : name;
		}
		return name;
	}
	public static function GetBlueprintTooltip(game:IGlobalGame, blueprintID:NamespaceID):String
	{
		var definition = game.GetSeedDefinition(blueprintID);
		if (definition == null)
			return "";
		var seedType = LogicSeedProps.GetSeedType(definition);
		if (seedType == SeedTypes.ENTITY)
		{
			var customEntityDef = LogicGameDefinitionsExt.GetEntitySeedDefinition(game, blueprintID);
			var customTooltip = customEntityDef != null ? customEntityDef.BlueprintTooltip : null;
			if (customTooltip != null && customTooltip.length > 0)
			{
				return Global.Localization.GetTextParticular(customTooltip, LogicStrings.CONTEXT_ENTITY_TOOLTIP);
			}
			else
			{
				var entityID = LogicSeedProps.GetSeedEntityID(definition);
				return entityID != null ? GetEntityTooltip(game, entityID) : "";
			}
		}
		else if (seedType == SeedTypes.OPTION)
		{
			var optionID = LogicSeedProps.GetSeedOptionID(definition);
			return optionID != null ? GetSeedOptionTooltip(game, optionID) : "";
		}
		return "";
	}

	private function new() {}
}
