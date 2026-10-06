// Ported from: Assets/Scripts/Logic/Saves/LogicSaveData.cs
package mvz2logic.saves;

import mvz2logic.saves.ModSaveData.SerializableModSaveData;
import mvz2logic.unlocks.LogicUnlockNames;
import pvzengine.NamespaceID;
import pvzengine.base.MissingSerializeDataException;
import unity.Mathf;

class LogicSaveData extends ModSaveData
{
	public function new(spaceName:String)
	{
		super(spaceName);
	}
	public override function CreateSerializable():SerializableModSaveData
	{
		var seri = new SerializableLogicSaveData();
		seri.version = 0;
		seri.lastMapID = LastMapID;
		seri.mapTalkID = MapTalkID;
		seri.money = money;
		seri.lastSelection = LastSelection;
		return seri;
	}
	public static function DeserializeFrom(seri:SerializableLogicSaveData):LogicSaveData
	{
		if (seri.spaceName == null || seri.spaceName.length == 0)
		{
			throw MissingSerializeDataException.Property("spaceName");
		}
		var saveData = new LogicSaveData(seri.spaceName);
		saveData.LoadFromSerializable(seri);
		saveData.LastMapID = seri.lastMapID;
		saveData.MapTalkID = seri.mapTalkID;
		saveData.money = seri.money;
		saveData.LastSelection = seri.lastSelection;
		return saveData;
	}
	public function GetMoney():Int
	{
		return money;
	}
	public function SetMoney(value:Int):Void
	{
		money = Mathf.ClampInt(value, 0, 999990);
	}
	public function GetBlueprintSlots():Int
	{
		return MIN_BLUEPRINT_SLOTS + countUnlocked(blueprintSlotUnlocks);
	}
	public function GetArtifactSlots():Int
	{
		return MIN_ARTIFACT_SLOTS + countUnlocked(artifactSlotUnlocks);
	}
	public function GetStarshardSlots():Int
	{
		return MIN_STARSHARD_SLOTS + countUnlocked(starshardSlotUnlocks);
	}
	// PORT-NOTE: C# LINQ Count(u => IsUnlocked(u)) -> 显式循环。
	private function countUnlocked(slotUnlocks:Array<String>):Int
	{
		var count = 0;
		for (u in slotUnlocks)
		{
			if (IsUnlocked(u))
				count++;
		}
		return count;
	}
	public static inline var MIN_BLUEPRINT_SLOTS:Int = 6;
	public static inline var MIN_ARTIFACT_SLOTS:Int = 1;
	public static inline var MIN_STARSHARD_SLOTS:Int = 3;
	public var LastMapID:Null<NamespaceID>;
	public var MapTalkID:Null<NamespaceID>;
	public var LastSelection:Null<BlueprintSelection>;
	private static var blueprintSlotUnlocks:Array<String> = [
		LogicUnlockNames.blueprintSlot1,
		LogicUnlockNames.blueprintSlot2,
		LogicUnlockNames.blueprintSlot3,
		LogicUnlockNames.blueprintSlot4,
	];
	private static var artifactSlotUnlocks:Array<String> = [
		LogicUnlockNames.artifactSlot1,
		LogicUnlockNames.artifactSlot2,
	];
	private static var starshardSlotUnlocks:Array<String> = [
		LogicUnlockNames.starshardSlot1,
		LogicUnlockNames.starshardSlot2,
	];
	private var money:Int;
}
