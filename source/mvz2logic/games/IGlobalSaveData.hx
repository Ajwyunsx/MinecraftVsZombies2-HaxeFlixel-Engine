// Ported from: Assets/Scripts/Logic/Game/IGlobalSaveData.cs
package mvz2logic.games;

import haxe.Int64;
import mvz2logic.saves.ModSaveData;
import pvzengine.NamespaceID;

interface IGlobalSaveData
{
	function IsUnlocked(unlockID:NamespaceID):Bool;
	function IsGroupUnlocked(unlockID:NamespaceID):Bool;
	function Unlock(unlockID:NamespaceID):Void;
	function Relock(unlockID:NamespaceID):Void;
	function IsContraptionUnlocked(contraptionID:NamespaceID):Bool;
	function IsEnemyUnlocked(contraptionID:NamespaceID):Bool;
	function IsArtifactUnlocked(id:NamespaceID):Bool;
	function GetUnlockedContraptions():Array<NamespaceID>;
	function GetUnlockedEnemies():Array<NamespaceID>;
	function GetUnlockedArtifacts():Array<NamespaceID>;
	function GetAllUnlocks():Array<NamespaceID>;

	function GetModSaveData(spaceName:String):ModSaveData;
	// TODO-PORT: C# 重载 GetModSaveData<T>(string spaceName)（泛型），Haxe 不支持重载，重命名为 GetModSaveDataOfType
	function GetModSaveDataOfType<T>(spaceName:String):Null<T>;

	function GetCurrentUserName():Null<String>;

	function SaveToFile():Void;

	function GetStat(category:NamespaceID, entry:NamespaceID):Int64;
	function SetStat(category:NamespaceID, entry:NamespaceID, value:Int64):Void;
	// TODO-PORT: C# 的 AddStat(category, entry, value) 在接口中有默认实现，Haxe 接口不支持默认方法，此处改为需要实现的抽象方法。
	function AddStat(category:NamespaceID, entry:NamespaceID, value:Int64):Void;
}
