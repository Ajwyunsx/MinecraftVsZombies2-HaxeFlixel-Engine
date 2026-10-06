// Ported from: Assets/Scripts/MVZ2/Managers/DebugManager.cs
//             合并了 DebugManager_Console.cs（partial class 合并为单文件）。
package mvz2.debugs;

import mvz2.io.FileHelper;
import mvz2.io.PathHelper;
import mvz2.debugs.MVZ2Logger;
import mvz2.managers.MainManager;
import mvz2.metas.CommandMetaParam;
import mvz2logic.Global;
import mvz2logic.ParseHelper;
import mvz2logic.ParseHelper.OutFloat;
import mvz2logic.ParseHelper.OutInt;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.commands.CommandUtility;
import mvz2logic.commands.ICommandParameterMeta;
import mvz2logic.commands.ICommandVariantMeta;
import mvz2logic.commands.LogicCommandProps;
import mvz2logic.games.IGlobalDebug;
import mvz2logic.games.LogicGameDefinitionsExt;
import mvz2logic.localization.LogicStrings;
import mvz2logic.saves.LogicSaveExt;
import pvzengine.NamespaceID;
import system.threading.tasks.Task;
import unity.*;
import unity.Debug;

// PORT-NOTE: C# 中 IsDebugUserName / GetCommandDefinition / GetAllCommandDefinitions 为
// LogicSaveExt、LogicGameDefinitionsExt 里的扩展方法，Haxe 侧用 `using` 还原为调用点方法形式。
using mvz2logic.games.LogicGameDefinitionsExt;
using mvz2logic.saves.LogicSaveExt;
using mvz2logic.commands.ICommandVariantMeta.ICommandVariantMetaHelper;

class DebugManager extends MonoBehaviour implements IGlobalDebug
{
	public function CanUseDebugFeatures():Bool
	{
		return CanUseDebugFeaturesByName(Main.SaveManager.GetCurrentUserName());
	}
	// TODO-PORT: C# 重载 CanUseDebugFeatures(string? username)。
	public function CanUseDebugFeaturesByName(username:String):Bool
	{
		if (Application.isEditor && !disableDebugFeatures)
			return true;
		if (Main.SaveManager.IsDebugUserName(username))
			return true;
		return false;
	}
	public function ExportLogFiles():Void
	{
		var success = false;
		var path = FileHelper.SaveExternalFile("log_files", ["zip"], function(dest:String):Void
		{
			if (dest == null || dest == "")
				return;
			try
			{
				success = Logger.ExportLogFilePack(dest);
			}
			catch (e:Dynamic)
			{
				success = false;
			}
		});
		var title:String;
		var desc:String;
		if (!success)
		{
			title = Main.LanguageManager._(LogicStrings.ERROR);
			desc = Main.LanguageManager._(ERROR_NOT_EXPORTED);
		}
		else
		{
			title = Main.LanguageManager._(LogicStrings.HINT);
			desc = Main.LanguageManager._(HINT_EXPORTED, [path]);
		}
		Main.Scene.ShowDialogMessageAsync(title, desc);
	}
	public var Main(get, never):MainManager;
	function get_Main():MainManager return MainManager.Instance;
	public var Logger(get, never):MVZ2Logger;
	function get_Logger():MVZ2Logger return MVZ2Logger.Instance;
	@:translateMsg("日志导出失败的警告")
	public static inline var ERROR_NOT_EXPORTED:String = "导出日志失败。";
	@:translateMsg("日志导出成功的提示，{0}为路径")
	public static inline var HINT_EXPORTED:String = "日志已导出至{0}。";

	@:serializeField
	private var disableDebugFeatures:Bool = false;

	// ===== DebugManager_Console.cs =====
	public function LoadCommandParameterSuggestions():Void
	{
		commandIDSet.clear();
		for (def in Main.Game.GetAllCommandDefinitions())
		{
			commandIDSet.set(def.GetID(), true);
		}

		for (set in idSetDictionary)
		{
			set.clear();
		}
		RegisterIDSets();

		for (unlock in Main.ResourceManager.GetAllUnlockConditions())
		{
			var defType = CommandMetaParam.ID_TYPE_UNLOCK;
			if (!idSetDictionary.exists(defType))
			{
				idSetDictionary.set(defType, new Map());
			}
			idSetDictionary.get(defType).set(unlock.toString(), true);
		}
	}
	private function RegisterIDSets():Void
	{
		// PORT-NOTE: C# 的无参 Main.Game.GetDefinitions()（取全部定义）在 Haxe 侧为 GetDefinitionsAll()，
		// 带参重载 GetDefinitions<T>(type) 与它同名但需要类型，按工程约定改名区分。
		for (def in Main.Game.GetDefinitionsAll())
		{
			var defType = def.GetDefinitionType();
			if (!idSetDictionary.exists(defType))
			{
				idSetDictionary.set(defType, new Map());
			}
			idSetDictionary.get(defType).set(def.GetID().toString(), true);
		}
		var chapterTransitionType = CommandMetaParam.ID_TYPE_CHAPTER_TRANSITION;
		for (id in Main.ResourceManager.GetAllChapterTransitions())
		{
			if (!idSetDictionary.exists(chapterTransitionType))
			{
				idSetDictionary.set(chapterTransitionType, new Map());
			}
			idSetDictionary.get(chapterTransitionType).set(id.toString(), true);
		}
	}
	public function IsConsoleActive():Bool
	{
		return Main.Scene.IsConsoleActive();
	}
	public function GetCommandHistory():Array<String>
	{
		return Main.Scene.GetCommandHistory();
	}
	public function ExecuteCommand(input:String, count:Int):Void
	{
		// TODO-PORT: C# 的 out 参数改为使用 DebugManager 实例字段保存结果。
		if (!PreExecuteCommand(input))
		{
			Print('> $input\n');
			PrintLine(preExecuteErrorMsg);
			return;
		}
		for (i in 0...count)
		{
			Print('> $input\n');
			try
			{
				preExecuteDefinition.Invoke(preExecuteArgs);
			}
			catch (ex:Dynamic)
			{
				var msg = Main.LanguageManager._p(LogicStrings.CONTEXT_COMMAND_OUTPUT, COMMAND_ERROR, [Std.string(ex)]);
				PrintLine(msg);
			}
		}
	}
	// TODO-PORT: C# 签名为 `PreExecuteCommand(string, out string, out CommandDefinition?, out string[]?)`，
	// Haxe 无 out 参数，结果通过字段 preExecuteErrorMsg / preExecuteDefinition / preExecuteArgs 传递。
	private var preExecuteErrorMsg:String;
	private var preExecuteDefinition:CommandDefinition;
	private var preExecuteArgs:Array<String>;
	private function PreExecuteCommand(input:String):Bool
	{
		preExecuteErrorMsg = "";
		preExecuteArgs = null;
		preExecuteDefinition = null;
		var parts = SplitCommand(input);
		if (parts.length < 1)
			return false;
		var command = parts[0];
		preExecuteArgs = parts.slice(1);

		var commandID = NamespaceID.TryParse(command, Main.BuiltinNamespace);
		if (commandID != null)
		{
			preExecuteDefinition = Global.Game.GetCommandDefinition(commandID);
		}
		if (preExecuteDefinition == null)
		{
			preExecuteErrorMsg = Main.LanguageManager._p(LogicStrings.CONTEXT_COMMAND_OUTPUT, COMMAND_NOT_FOUND, [command]);
			return false;
		}
		try
		{
			ValidateCommand(parts);
		}
		catch (ex:Dynamic)
		{
			preExecuteErrorMsg = Main.LanguageManager._p(LogicStrings.CONTEXT_COMMAND_OUTPUT, COMMAND_ERROR, [Std.string(ex)]);
			return false;
		}
		return true;
	}
	public function SplitCommand(input:String):Array<String> return CommandUtility.SplitCommand(input);
	public function ClearConsole():Void
	{
		Main.Scene.ClearConsole();
	}
	public function GetCommandIDByName(text:String):NamespaceID
	{
		var id = NamespaceID.TryParse(text, Main.BuiltinNamespace);
		if (id != null)
		{
			return id;
		}
		return null;
	}
	public function GetCommandNameByID(id:NamespaceID):String
	{
		if (id.SpaceName == Main.BuiltinNamespace)
		{
			return id.Path;
		}
		return id.toString();
	}
	public function GetAllCommandsID():Array<NamespaceID>
	{
		return [for (k in commandIDSet.keys()) k];
	}

	// #region 历史
	public function SaveCommandHistory(history:Array<String>):Void
	{
		var path = GetCommandHistoryPath();
		FileHelper.ValidateDirectory(path);
		// PORT-NOTE: C# 的 `using var stream = File.Open(...)` 在 Haxe 中改为 try/catch + 显式 close。
		var output = sys.io.File.write(path, false);
		try
		{
			output.writeString(history.join("\n"));
		}
		catch (e:Dynamic)
		{
			output.close();
			throw e;
		}
		output.close();
	}
	public function LoadCommandHistory(history:Array<String>):Void
	{
		var path = GetCommandHistoryPath();
		if (!sys.FileSystem.exists(path))
		{
			return;
		}
		var input = sys.io.File.read(path, false);
		try
		{
			while (!input.eof())
			{
				history.push(input.readLine());
			}
		}
		catch (e:Dynamic)
		{
			input.close();
			throw e;
		}
		input.close();
	}
	private function GetCommandHistoryPath():String
	{
		return PathHelper.combine(Application.persistentDataPath, commandHistoryFileName);
	}
	// #endregion

	// #region 自动补全
	private function GetBestFitCommandVariant(variants:Array<ICommandVariantMeta>, parts:Array<String>, uncompleted:Bool = false):ICommandVariantMeta
	{
		var maxFits = 0;
		var bestVariant:ICommandVariantMeta = null;
		var targetCount = parts.length;
		for (variant in variants)
		{
			var fitCount = GetCommandVariantFitPartCount(variant, parts, uncompleted);

			if (fitCount == targetCount)
				return variant;
			if (fitCount > maxFits)
			{
				maxFits = fitCount;
				bestVariant = variant;
			}
		}
		return bestVariant;
	}
	private function GetCommandVariantFitPartCount(variant:ICommandVariantMeta, parts:Array<String>, uncompleted:Bool = false):Int
	{
		var hasSubname = !(variant.Subname == null || variant.Subname == "");
		// 实参数量大于形参，直接不通过
		if (parts.length > variant.GetMaxCommandPartCount())
		{
			return 0;
		}

		// 子命令不一致，不通过
		if (hasSubname && (parts.length < 2 || variant.Subname.toLowerCase() != parts[1].toLowerCase()))
		{
			return 1;
		}

		// 检查参数
		for (i in 0...variant.Parameters.length)
		{
			var partIndex = variant.GetCommandPartIndexOfParameter(i);

			if (partIndex < 0 || partIndex >= parts.length)
				continue;
			var parameter = variant.Parameters[i];
			if (parameter == null)
				continue;

			// 未完成的指令，如果目前的参数是最后一个参数（也就是未完成），则所有参数都符合。
			if (uncompleted && partIndex == parts.length - 1)
				return parts.length;

			// 参数不一致。
			if (!FitsCommandParameter(parameter, parts[partIndex]))
				return partIndex;
		}
		return parts.length;
	}
	private function FitsCommandParameter(param:ICommandParameterMeta, paramText:String):Bool
	{
		if (paramText == DEFAULT_VALUE_PARAMETER && param.Optional)
		{
			return true;
		}
		switch (param.Type)
		{
			case CommandMetaParam.TYPE_COMMAND:
				{
					var id = GetCommandIDByName(paramText);
					return NamespaceID.IsValid(id) && commandIDSet.exists(id);
				}
			case CommandMetaParam.TYPE_INT:
				{
					// PORT-NOTE: C# 为 `int.TryParse(paramText, out _)`；`Std.parseInt` 会接受
					// "0x10"（→16）与 "12abc"（→12），与 C# 的严格语义不一致，改用 ParseHelper。
					var outValue:OutInt = {value: 0};
					return ParseHelper.TryParseInt(paramText, outValue);
				}
			case CommandMetaParam.TYPE_FLOAT:
				{
					// PORT-NOTE: C# 为 `float.TryParse(paramText, out _)`；cpp 目标上 `Std.parseFloat`
					// 返回非空 Float，不能与 null 比较，改用与 C# TryParse 语义一致的 ParseHelper。
					var outValue:OutFloat = {value: 0};
					return ParseHelper.TryParseFloat(paramText, outValue);
				}
			case CommandMetaParam.TYPE_ID:
				{
					var id = NamespaceID.TryParse(paramText, Main.BuiltinNamespace);
					if (id == null)
					{
						return false;
					}
					return FitsCommandParameterID(param, id);
				}
			default:
		}
		return false;
	}
	private function FitsCommandParameterID(param:ICommandParameterMeta, id:NamespaceID):Bool
	{
		switch (param.IDType)
		{
			case CommandMetaParam.ID_TYPE_ENTITY:
				{
					return Main.Game.GetEntityDefinition(id) != null;
				}
			case CommandMetaParam.ID_TYPE_SEED:
				{
					return Main.Game.GetSeedDefinition(id) != null;
				}
			case CommandMetaParam.ID_TYPE_ARTIFACT:
				{
					return Main.Game.GetArtifactDefinition(id) != null;
				}
			case CommandMetaParam.ID_TYPE_ARMOR:
				{
					return Main.Game.GetArmorDefinition(id) != null;
				}
			case CommandMetaParam.ID_TYPE_ARMOR_SLOT:
				{
					return Main.Game.GetArmorSlotDefinition(id) != null;
				}
			default:
		}
		return true;
	}
	public function FillSuggestions(parts:Array<String>, currentSuggestions:Array<String>):Void
	{
		var currentCommand = parts[0].toLowerCase();
		var commandID = NamespaceID.TryParse(currentCommand, Main.BuiltinNamespace);
		if (commandID == null)
			return;

		// 命令建议
		if (parts.length == 1)
		{
			var currentCommandName = GetCommandNameByID(commandID);
			FillNameSuggestions(currentCommandName, currentSuggestions);
		}
		// 参数建议
		else
		{
			var def = Main.Game.GetCommandDefinition(commandID);
			if (def != null)
				FillParameterSuggestions(def, parts, currentSuggestions);
		}
	}
	private function FillNameSuggestions(currentCommandName:String, currentSuggestions:Array<String>):Void
	{
		for (cmd in GetAllCommandsID())
		{
			var cmdName = GetCommandNameByID(cmd);
			if (cmdName.toLowerCase().indexOf(currentCommandName.toLowerCase()) == 0)
			{
				var meta = Main.Game.GetCommandDefinition(cmd);
				if (meta == null)
					continue;
				if (!Main.LevelManager.IsInLevel() && LogicCommandProps.MustInLevel(meta))
					continue;
				currentSuggestions.push(cmdName);
			}
		}
	}
	private function FillParameterSuggestions(def:CommandDefinition, parts:Array<String>, currentSuggestions:Array<String>):Void
	{
		if (def == null)
			return;

		var variants = LogicCommandProps.GetVariants(def);
		if (variants == null)
			return;

		// 变体子名称
		if (parts.length == 2)
		{
			var subnameVariants = variants.filter(v -> !(v.Subname == null || v.Subname == ""));
			for (v in subnameVariants)
			{
				if (v.Subname.indexOf(parts[1]) == 0)
				{
					currentSuggestions.push(v.Subname);
				}
			}
		}
		// 查找目前最符合的命令变体。
		var variant = GetBestFitCommandVariant(variants, parts, true);

		if (variant == null)
			return;
		FillSuggestionsOfCommandVariant(variant, parts, currentSuggestions);
	}
	private function FillSuggestionsOfCommandVariant(variant:ICommandVariantMeta, parts:Array<String>, currentSuggestions:Array<String>):Void
	{
		if (variant == null)
			return;
		var parameterIndex = variant.GetParameterIndexOfCommandPart(parts.length - 1);
		if (parameterIndex < 0 || parameterIndex >= variant.Parameters.length)
			return;
		var parameter = variant.Parameters[parameterIndex];
		FillSuggestionsOfCommandParameter(parameter, parts, currentSuggestions);
	}
	private function FillSuggestionsOfCommandParameter(param:ICommandParameterMeta, parts:Array<String>, currentSuggestions:Array<String>):Void
	{
		if (param == null)
			return;
		var last = parts[parts.length - 1];
		var suggestions = GetSuggestionsOfParameter(param);
		for (suggestion in suggestions)
		{
			if (last == null || last == "" || suggestion.indexOf(last) == 0)
			{
				currentSuggestions.push(suggestion);
			}
			else
			{
				var parsed = NamespaceID.TryParseStrict(suggestion);
				if (parsed != null && parsed.Path.indexOf(last) == 0)
				{
					currentSuggestions.push(suggestion);
				}
			}
		}
	}
	private function GetSuggestionsOfParameter(param:ICommandParameterMeta):Array<String>
	{
		var result:Array<String> = [];
		switch (param.Type)
		{
			case CommandMetaParam.TYPE_COMMAND:
				{
					var ids = GetAllCommandsID();
					for (id in ids)
					{
						var name = GetCommandNameByID(id);
						result.push(name);
					}
				}
			case CommandMetaParam.TYPE_ID:
				{
					if (idSetDictionary.exists(param.IDType))
					{
						for (sug in idSetDictionary.get(param.IDType).keys())
						{
							result.push(sug);
						}
					}
				}
			default:
		}
		return result;
	}
	// #endregion

	// #region 命令校验
	private function ValidateCommand(parts:Array<String>):Void
	{
		if (parts.length == 0)
			return;
		var commandName = parts[0];
		var commandID = Main.DebugManager.GetCommandIDByName(commandName);
		if (!NamespaceID.IsValid(commandID))
			return;
		var def = Main.Game.GetCommandDefinition(commandID);
		if (def == null)
			return;
		// 在关卡外执行关卡命令
		if (LogicCommandProps.MustInLevel(def) && !Global.Level.IsInLevel())
			throw Main.LanguageManager._p(LogicStrings.CONTEXT_COMMAND_OUTPUT, LogicStrings.COMMAND_MUST_IN_LEVEL);

		// PORT-NOTE: C# 的 def.GetVariants() 是 LogicCommandProps 中的扩展方法，Haxe 侧为静态方法。
		var variants = LogicCommandProps.GetVariants(def);
		if (variants == null)
			throw Main.LanguageManager._p(LogicStrings.CONTEXT_COMMAND_OUTPUT, LogicStrings.COMMAND_INCORRECT_FORMAT);
		var variant = GetBestFitCommandVariant(variants, parts);
		// 命令变体不存在。
		if (variant == null)
			throw Main.LanguageManager._p(LogicStrings.CONTEXT_COMMAND_OUTPUT, LogicStrings.COMMAND_INCORRECT_FORMAT);

		// 检测命令变体的子名称是否正确。
		var hasSubname = !(variant.Subname == null || variant.Subname == "");
		if (hasSubname)
		{
			// 没有子名称
			if (parts.length < 2)
			{
				var possibleSubnames = GetCommandPossibleSubnameTexts(variants);
				var subnameStr = possibleSubnames.join(",");
				throw Main.LanguageManager._p(LogicStrings.CONTEXT_COMMAND_OUTPUT, LogicStrings.COMMAND_MISSING_SUBNAME, [subnameStr]);
			}
			// 子名称不正确
			if (variant.Subname.toLowerCase() != parts[1].toLowerCase())
			{
				var possibleSubnames = GetCommandPossibleSubnameTexts(variants);
				var subnameStr = possibleSubnames.join(",");
				throw Main.LanguageManager._p(LogicStrings.CONTEXT_COMMAND_OUTPUT, LogicStrings.COMMAND_INCORRECT_SUBNAME, [subnameStr]);
			}
		}
		// 检测命令变体的参数是否正确。
		for (i in 0...variant.Parameters.length)
		{
			var partIndex = variant.GetCommandPartIndexOfParameter(i);
			var parameter = variant.Parameters[i];
			if (partIndex >= parts.length)
			{
				if (parameter.Optional)
					continue;

				throw Main.LanguageManager._p(LogicStrings.CONTEXT_COMMAND_OUTPUT, LogicStrings.COMMAND_MISSING_PARAMETER, [parameter.Name]);
			}
			var part = parts[partIndex];

			if (!FitsCommandParameter(parameter, part))
			{
				throw Main.LanguageManager._p(LogicStrings.CONTEXT_COMMAND_OUTPUT, LogicStrings.COMMAND_INCORRECT_PARAMETER, [parameter.Name]);
			}
		}
		var actualParamLength = variant.GetParameterIndexOfCommandPart(parts.length);
		var minParameterCount = 0;
		for (p in variant.Parameters)
		{
			if (!p.Optional)
				minParameterCount++;
		}
		var maxParameterCount = variant.Parameters.length;
		if (actualParamLength < minParameterCount || actualParamLength > maxParameterCount)
		{
			throw Main.LanguageManager._p(LogicStrings.CONTEXT_COMMAND_OUTPUT, LogicStrings.COMMAND_INCORRECT_PARAMETER_COUNT);
		}
	}
	// #endregion

	public function Print(text:String):Void
	{
		Main.Scene.Print(text);
	}
	private function PrintLine(text:String):Void
	{
		Print(text + "\n");
	}
	private function GetCommandPossibleSubnameTexts(variants:Array<ICommandVariantMeta>):Array<String>
	{
		return [for (v in variants) if (!(v.Subname == null || v.Subname == "")) v.Subname];
	}

	@:serializeField
	private var commandHistoryFileName:String = "commands.txt";
	private var idSetDictionary:Map<String, Map<String, Bool>> = new Map();
	private var commandIDSet:Map<NamespaceID, Bool> = new Map();

	public static inline var COMMAND_CHARACTER:String = CommandUtility.COMMAND_CHARACTER;
	public static inline var DEFAULT_VALUE_PARAMETER:String = CommandUtility.DEFAULT_VALUE_PARAMETER;
	@:translateMsg("命令输出，{0}为命令名", LogicStrings.CONTEXT_COMMAND_OUTPUT)
	public static inline var COMMAND_NOT_FOUND:String = "<color=red>命令不存在：{0}</color>";
	@:translateMsg("命令输出，{0}为错误", LogicStrings.CONTEXT_COMMAND_OUTPUT)
	public static inline var COMMAND_ERROR:String = "<color=red>错误：{0}</color>";
}
