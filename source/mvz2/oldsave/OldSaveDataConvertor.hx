// Ported from: Assets/Scripts/OldSave/OldSaveDataConvertor.cs

package mvz2.oldsave;

import mvz2.gamecontent.difficulties.VanillaDifficulties;
import mvz2.gamecontent.maps.VanillaMapID;
import mvz2.gamecontent.stages.VanillaStageID.VanillaStageNames;
import mvz2.oldsave.OldSaveDataMain.OldSaveData;
import mvz2.oldsave.OldSaveDataMain.OldSaveDataAchievements;
import mvz2.oldsave.OldSaveDataMain.OldSaveDataEndless;
import mvz2.oldsave.OldSaveDataMain;
import mvz2.vanilla.unlocks.VanillaUnlockID.VanillaUnlockNames;
import mvz2logic.Global;
import mvz2logic.saves.LogicSaveData;
import mvz2logic.stats.LogicStats;
import mvz2logic.unlocks.LogicUnlockNames;
import pvzengine.NamespaceID;

// PORT-NOTE: C# static class → Haxe 全静态成员的 class（私有构造）。
class OldSaveDataConvertor {
	private function new() {}

	public static function ImportUserDataFromOld(saveData:LogicSaveData, oldData:OldSaveData):Void {
		if (oldData == null)
			return;
		ImportMainUserDataFromOld(saveData, oldData.main);
		ImportAchievementsUserDataFromOld(saveData, oldData.achievements);
		ImportEndlessUserDataFromOld(saveData, oldData.endless);
	}

	private static function ImportMainUserDataFromOld(saveData:LogicSaveData, oldData:OldSaveDataMain):Void {
		if (oldData == null)
			return;

		// 关卡进度。
		for (i in 0...oldLevelIDList.length) {
			if (oldData.currentLevel > i) {
				var unlockName = LogicUnlockNames.GetLevelClearUnlock(oldLevelIDList[i]);
				saveData.Unlock(unlockName);
			}
		}
		if ((oldData.currentLevel == 12 && oldData.sidePlot == 1) || oldData.currentLevel > 12) {
			saveData.Unlock(VanillaUnlockNames.enteredDream);
		}
		// 关卡难度。
		// PORT-NOTE: C# byte[] 索引 arr[i] → Haxe haxe.io.Bytes.get(i)。
		for (i in 0...oldData.levelDifficulties.length) {
			var difficulty = oldData.levelDifficulties.get(i);
			var index = i + 1;
			if (index >= oldLevelIDList.length || index > oldData.currentLevel)
				continue;
			var stageID = oldLevelIDList[index];
			var diff:NamespaceID = VanillaDifficulties.hard;
			switch (difficulty) {
				case 0:
					diff = VanillaDifficulties.easy;
				case 1:
					diff = VanillaDifficulties.normal;
				case _:
			}
			saveData.AddLevelDifficultyRecord(stageID, diff);
		}
		// 上一张地图
		if (oldData.lastMap == "mvz2:dream_map") {
			saveData.LastMapID = VanillaMapID.dream;
		} else {
			saveData.LastMapID = VanillaMapID.halloween;
		}
		// 金钱
		saveData.SetMoney(oldData.money);
		// 卡槽
		if (oldData.cardSlots >= 7)
			saveData.Unlock(LogicUnlockNames.blueprintSlot1);
		if (oldData.cardSlots >= 8)
			saveData.Unlock(LogicUnlockNames.blueprintSlot2);
		if (oldData.cardSlots >= 9)
			saveData.Unlock(LogicUnlockNames.blueprintSlot3);
		if (oldData.cardSlots >= 10)
			saveData.Unlock(LogicUnlockNames.blueprintSlot4);
		// 星之碎片槽
		if (oldData.starshardSlots >= 4)
			saveData.Unlock(LogicUnlockNames.starshardSlot1);
		if (oldData.starshardSlots >= 5)
			saveData.Unlock(LogicUnlockNames.starshardSlot2);
		// 升级
		if ((oldData.upgrades & 1) != 0) {
			saveData.Unlock(VanillaUnlockNames.infectenser);
		}
		if ((oldData.upgrades & 2) != 0) {
			saveData.Unlock(VanillaUnlockNames.forcePad);
		}
		// 梦魇
		if (oldData.nightmare) {
			saveData.Unlock(VanillaUnlockNames.dreamIsNightmare);
		}
		// 教程
		if (oldData.moneyFound) {
			saveData.Unlock(VanillaUnlockNames.money);
		}
		if (oldData.starshardLearnt) {
			saveData.Unlock(VanillaUnlockNames.starshard);
		}
		if (oldData.triggerLearnt) {
			saveData.Unlock(VanillaUnlockNames.trigger);
		}
	}

	private static function ImportAchievementsUserDataFromOld(saveData:LogicSaveData, oldData:OldSaveDataAchievements):Void {
		if (oldData == null)
			return;
		if (oldData.earned == null || oldData.earned.length < 1)
			return;
		var earned = oldData.earned.get(0);
		for (i in 0...oldAchievementIDList.length) {
			if ((earned & (1 << i)) != 0) {
				saveData.Unlock(oldAchievementIDList[i]);
			}
		}
	}

	private static function ImportEndlessUserDataFromOld(saveData:LogicSaveData, oldData:OldSaveDataEndless):Void {
		if (oldData == null || oldData.flags == null)
			return;
		// PORT-NOTE: C# foreach (var pair in Dictionary<string, Record>) → Haxe Map.keyValueIterator()。
		for (pair in oldData.flags.keyValueIterator()) {
			if (pair.value == null)
				continue;
			var stageID = VanillaStageNames.halloweenEndless;
			switch (pair.key) {
				case "dream":
					stageID = VanillaStageNames.dreamEndless;
				case _:
			}
			saveData.SetCurrentEndlessFlag(stageID, pair.value.current);
			saveData.SetStat(LogicStats.CATEGORY_MAX_ENDLESS_FLAGS.Path, new NamespaceID(Global.BuiltinNamespace, stageID), pair.value.max);
		}
	}

	private static var oldLevelIDList:Array<String> = [
		VanillaStageNames.prologue, // 0
		VanillaStageNames.halloween1,
		VanillaStageNames.halloween2,
		VanillaStageNames.halloween3,
		VanillaStageNames.halloween4,
		VanillaStageNames.halloween5,
		VanillaStageNames.halloween6,
		VanillaStageNames.halloween7,
		VanillaStageNames.halloween8,
		VanillaStageNames.halloween9,
		VanillaStageNames.halloween10,
		VanillaStageNames.halloween11, // 11
		VanillaStageNames.dream1,
		VanillaStageNames.dream2,
		VanillaStageNames.dream3,
		VanillaStageNames.dream4,
		VanillaStageNames.dream5,
		VanillaStageNames.dream6,
		VanillaStageNames.dream7,
		VanillaStageNames.dream8,
		VanillaStageNames.dream9,
		VanillaStageNames.dream10,
		VanillaStageNames.dream11, // 22
	];

	private static var oldAchievementIDList:Array<String> = [
		VanillaUnlockNames.doubleTrouble,
		VanillaUnlockNames.ghostBuster,
		VanillaUnlockNames.rickrollDrown,
		VanillaUnlockNames.returnToSender,
	];
}
