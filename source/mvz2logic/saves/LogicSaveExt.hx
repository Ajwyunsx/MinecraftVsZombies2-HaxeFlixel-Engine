// Ported from: Assets/Scripts/Logic/Saves/LogicSaveExt.cs
package mvz2logic.saves;

import mvz2logic.Global;
import mvz2logic.callbacks.LogicCallbacks;
import mvz2logic.games.IGlobalSaveData;
import mvz2logic.unlocks.LogicUnlockGroupID;
import mvz2logic.unlocks.LogicUnlockID;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EmptyCallbackParams;

class LogicSaveExt
{
	// PORT-NOTE: 全部为 C# 扩展方法，此处保留为静态方法，调用处可用 Haxe `using`。
	public static function GetLogicSaveData(save:IGlobalSaveData):Null<LogicSaveData>
	{
		// PORT-NOTE: C# `save.GetModSaveData<LogicSaveData>(...)`，Haxe 无显式类型实参，改用 GetModSaveDataOfType（返回类型推断 T）。
		return save.GetModSaveDataOfType(Global.BuiltinNamespace);
	}
	public static function GetLastMapID(save:IGlobalSaveData):Null<NamespaceID>
	{
		var saveData = GetLogicSaveData(save);
		if (saveData == null)
			return null;
		return saveData.LastMapID;
	}
	public static function SetLastMapID(save:IGlobalSaveData, value:NamespaceID):Void
	{
		var saveData = GetLogicSaveData(save);
		if (saveData == null)
			return;
		saveData.LastMapID = value;
	}
	public static function GetLastSelection(save:IGlobalSaveData):Null<BlueprintSelection>
	{
		var saveData = GetLogicSaveData(save);
		if (saveData == null)
			return null;
		return saveData.LastSelection;
	}
	public static function SetLastSelection(save:IGlobalSaveData, value:BlueprintSelection):Void
	{
		var saveData = GetLogicSaveData(save);
		if (saveData == null)
			return;
		saveData.LastSelection = value;
	}
	public static function SetMoney(save:IGlobalSaveData, money:Int):Void
	{
		var saveData = GetLogicSaveData(save);
		if (saveData == null)
			return;
		saveData.SetMoney(money);
	}
	public static function AddMoney(save:IGlobalSaveData, money:Int):Void
	{
		SetMoney(save, GetMoney(save) + money);
	}
	public static function GetMoney(save:IGlobalSaveData):Int
	{
		var saveData = GetLogicSaveData(save);
		if (saveData == null)
			return 0;
		return saveData.GetMoney();
	}
	public static function SetMapTalk(save:IGlobalSaveData, value:Null<NamespaceID>):Void
	{
		var saveData = GetLogicSaveData(save);
		if (saveData == null)
			return;
		saveData.MapTalkID = value;
	}
	public static function GetMapTalk(save:IGlobalSaveData):Null<NamespaceID>
	{
		var saveData = GetLogicSaveData(save);
		if (saveData == null)
			return null;
		return saveData.MapTalkID;
	}
	public static function GetBlueprintSlots(save:IGlobalSaveData):Int
	{
		var saveData = GetLogicSaveData(save);
		var count = 6;
		if (saveData != null)
		{
			count = saveData.GetBlueprintSlots();
		}
		var result = new CallbackResult(count);
		Global.Game.RunCallbackWithResult(LogicCallbacks.GET_BLUEPRINT_SLOT_COUNT, new EmptyCallbackParams(), result);
		// PORT-NOTE: C# 为 result.GetValue<int>()，Haxe 不支持显式类型参数调用，靠返回类型推断。
		return result.GetValue();
	}
	public static function GetArtifactSlots(save:IGlobalSaveData):Int
	{
		var saveData = GetLogicSaveData(save);
		if (saveData == null)
			return 1;
		return saveData.GetArtifactSlots();
	}
	public static function GetStarshardSlots(save:IGlobalSaveData):Int
	{
		var saveData = GetLogicSaveData(save);
		if (saveData == null)
			return 3;
		return saveData.GetStarshardSlots();
	}
	public static function IsLevelCleared(save:IGlobalSaveData, stageID:NamespaceID):Bool
	{
		return save.IsUnlocked(LogicUnlockID.GetLevelClearUnlock(stageID));
	}

	public static function IsEnemyEncountered(save:IGlobalSaveData, enemyID:NamespaceID):Bool
	{
		return Global.VanillaInterface.IsEnemyEncountered(save, enemyID);
	}

	// #region 解锁
	public static function IsAlmanacUnlocked(save:IGlobalSaveData):Bool
	{
		return save.IsGroupUnlocked(LogicUnlockGroupID.almanac);
	}
	public static function IsStoreUnlocked(save:IGlobalSaveData):Bool
	{
		return save.IsGroupUnlocked(LogicUnlockGroupID.store);
	}
	public static function IsMusicRoomUnlocked(save:IGlobalSaveData):Bool
	{
		return save.IsGroupUnlocked(LogicUnlockGroupID.musicRoom);
	}
	public static function IsArcadeUnlocked(save:IGlobalSaveData):Bool
	{
		return save.IsGroupUnlocked(LogicUnlockGroupID.arcade);
	}
	public static function IsGensokyoUnlocked(save:IGlobalSaveData):Bool
	{
		return save.IsGroupUnlocked(LogicUnlockGroupID.gensokyo);
	}
	public static function IsTriggerUnlocked(save:IGlobalSaveData):Bool
	{
		return save.IsGroupUnlocked(LogicUnlockGroupID.trigger);
	}
	public static function IsStarshardUnlocked(save:IGlobalSaveData):Bool
	{
		return save.IsGroupUnlocked(LogicUnlockGroupID.starshard);
	}
	public static function IsCommandBlockUnlocked(save:IGlobalSaveData):Bool
	{
		return save.IsGroupUnlocked(LogicUnlockGroupID.commandBlock);
	}
	public static function IsHPBarUnlocked(save:IGlobalSaveData):Bool
	{
		return save.IsGroupUnlocked(LogicUnlockGroupID.hpBar);
	}
	// 梦境世界是否是梦魇状态。玩家设置。
	public static function DreamIsNightmare(save:IGlobalSaveData):Bool
	{
		return Global.VanillaInterface.DreamIsNightmare(save);
	}
	public static function SetDreamIsNightmare(save:IGlobalSaveData, value:Bool):Void
	{
		Global.VanillaInterface.SetDreamIsNightmare(save, value);
	}
	// #endregion

	// #region 解锁判断
	public static function IsValidAndLocked(save:IGlobalSaveData, unlockId:Null<NamespaceID>):Bool
	{
		return NamespaceID.IsValid(unlockId) && !save.IsUnlocked(unlockId);
	}
	public static function IsInvalidOrUnlocked(save:IGlobalSaveData, unlockId:Null<NamespaceID>):Bool
	{
		return !IsValidAndLocked(save, unlockId);
	}
	public static function IsValidAndUnlocked(save:IGlobalSaveData, unlockId:Null<NamespaceID>):Bool
	{
		return NamespaceID.IsValid(unlockId) && save.IsUnlocked(unlockId);
	}
	public static function IsAllInvalidOrUnlocked(save:IGlobalSaveData, unlocks:Null<Array<NamespaceID>>):Bool
	{
		if (unlocks == null || unlocks.length <= 0)
			return true;
		for (u in unlocks)
		{
			if (!IsInvalidOrUnlocked(save, u))
				return false;
		}
		return true;
	}
	// #endregion

	// #region 调试用户
	public static function IsDebugUser(saves:IGlobalSaveData):Bool
	{
		var userName = saves.GetCurrentUserName();
		return IsDebugUserName(saves, userName);
	}
	public static function IsDebugUserName(saves:IGlobalSaveData, name:Null<String>):Bool
	{
		if (name == null || name.length == 0)
			return false;
		// PORT-NOTE: C# string.Equals(name, StringComparison.OrdinalIgnoreCase) -> Haxe 小写比较。
		for (n in debugUserNames)
		{
			if (n.toLowerCase() == name.toLowerCase())
				return true;
		}
		return false;
	}
	public static var debugUserNames:Array<String> = [
		"debug",
	];
	// #endregion
}
