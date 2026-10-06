// Ported from: Assets/Scripts/OldSave/OldSaveDataMain.cs

package mvz2.oldsave;

import nbtutility.NBTData;

// PORT-NOTE: C# byte[] → haxe.io.Bytes；C# byte/short → Haxe Int（Haxe 无这些整数宽度）。
// PORT-NOTE: C# 对象初始化器 `new X() { f = v }` → Haxe 逐字段赋值。

class OldSaveData {
	public var main:OldSaveDataMain;
	public var achievements:OldSaveDataAchievements;
	public var endless:OldSaveDataEndless;

	public function new() {}
}

class OldSaveDataMain {
	public var version:Int = 0;
	public var currentLevel:Int = 0;
	public var levelDifficulties:haxe.io.Bytes;
	public var lastMap:String;
	public var sidePlot:Int = 0;
	public var moneyFound:Bool = false;
	public var money:Int = 0;
	public var starshardLearnt:Bool = false;
	public var triggerLearnt:Bool = false;
	public var cardSlots:Int = 0;
	public var starshardSlots:Int = 0;
	public var obsidianFirstAid:Bool = false;
	public var upgrades:Int = 0;
	public var nightmare:Bool = false;

	public function new() {}

	public static function FromNBT(nbt:NBTData):OldSaveDataMain {
		var version = NBTHelper.LoadByte(nbt, "version", 0);
		if (version == 0) {
			return LoadVersion0(nbt);
		}
		return LoadVersion1(nbt);
	}

	private static function LoadVersion0(nbt:NBTData):OldSaveDataMain {
		var currentLevel = NBTHelper.LoadByte(nbt, "mvz2:current_level", 0);
		var levelDifficulties = NBTHelper.LoadByteArray(nbt, "mvz2:level_difficulties", haxe.io.Bytes.alloc(132));
		var lastMap = NBTHelper.LoadString(nbt, "mvz2:last_map", "mvz2:halloween_map");
		var sidePlot = NBTHelper.LoadByte(nbt, "mvz2:side_plot", 0);
		var moneyFound = NBTHelper.LoadBool(nbt, "mvz2:money_found", false);
		var money = NBTHelper.LoadInt(nbt, "mvz2:money", 0);
		var starshardLearnt = NBTHelper.LoadBool(nbt, "mvz2:starshard_learnt", false);
		var triggerLearnt = NBTHelper.LoadBool(nbt, "mvz2:trigger_learnt", false);
		var cardSlots = NBTHelper.LoadByte(nbt, "mvz2:card_slots", 0);
		var starshardSlots = NBTHelper.LoadByte(nbt, "mvz2:starshard_slots", 0);
		var obsidianFirstAid = NBTHelper.LoadBool(nbt, "mvz2:obsidian_first_aid", false);
		var upgrades = NBTHelper.LoadShort(nbt, "mvz2:taboos", 0);
		var result = new OldSaveDataMain();
		result.version = 0;
		result.currentLevel = currentLevel;
		result.levelDifficulties = levelDifficulties;
		result.lastMap = lastMap;
		result.sidePlot = sidePlot;
		result.moneyFound = moneyFound;
		result.money = money;
		result.starshardLearnt = starshardLearnt;
		result.triggerLearnt = triggerLearnt;
		result.cardSlots = cardSlots;
		result.starshardSlots = starshardSlots;
		result.obsidianFirstAid = obsidianFirstAid;
		result.upgrades = upgrades;
		result.nightmare = false;
		return result;
	}

	private static function LoadVersion1(nbt:NBTData):OldSaveDataMain {
		var currentLevel = NBTHelper.LoadByte(nbt, "current_level", 0);
		var levelDifficulties = NBTHelper.LoadByteArray(nbt, "level_difficulties", haxe.io.Bytes.alloc(132));
		var lastMap = NBTHelper.LoadString(nbt, "last_map", "mvz2:halloween_map");
		var sidePlot = NBTHelper.LoadByte(nbt, "side_plot", 0);
		var moneyFound = NBTHelper.LoadBool(nbt, "money_found", false);
		var money = NBTHelper.LoadInt(nbt, "money", 0);
		var starshardLearnt = NBTHelper.LoadBool(nbt, "starshard_learnt", false);
		var triggerLearnt = NBTHelper.LoadBool(nbt, "trigger_learnt", false);
		var cardSlots = NBTHelper.LoadByte(nbt, "card_slots", 0);
		var starshardSlots = NBTHelper.LoadByte(nbt, "starshard_slots", 0);
		var obsidianFirstAid = NBTHelper.LoadBool(nbt, "obsidian_first_aid", false);
		var upgrades = NBTHelper.LoadShort(nbt, "upgrades", 0);
		var nightmare = NBTHelper.LoadBool(nbt, "nightmare", false);
		var result = new OldSaveDataMain();
		result.version = 1;
		result.currentLevel = currentLevel;
		result.levelDifficulties = levelDifficulties;
		result.lastMap = lastMap;
		result.sidePlot = sidePlot;
		result.moneyFound = moneyFound;
		result.money = money;
		result.starshardLearnt = starshardLearnt;
		result.triggerLearnt = triggerLearnt;
		result.cardSlots = cardSlots;
		result.starshardSlots = starshardSlots;
		result.obsidianFirstAid = obsidianFirstAid;
		result.upgrades = upgrades;
		result.nightmare = nightmare;
		return result;
	}
}

class OldSaveDataAchievements {
	public var version:Int = 0;
	public var earned:haxe.io.Bytes;

	public function new() {}

	public static function FromNBT(nbt:NBTData):OldSaveDataAchievements {
		var version = NBTHelper.LoadByte(nbt, "version", 0);
		var earned = NBTHelper.LoadByteArray(nbt, "earned", haxe.io.Bytes.alloc(0));
		var result = new OldSaveDataAchievements();
		result.version = 0;
		result.earned = earned;
		return result;
	}
}

class OldSaveDataEndless {
	public var version:Int = 0;
	public var flags:Map<String, Record>;

	public function new() {}

	public static function FromNBT(nbt:NBTData):OldSaveDataEndless {
		var version = NBTHelper.LoadByte(nbt, "version", 0);
		var flags = new Map<String, Record>();
		// PORT-NOTE: C# TryGetValue(key, out var flagsData) → 返回值 + 显式类型转换（Haxe 无 out 参数）。
		var flagsData:NBTData = cast nbt.TryGetValue("flags");
		if (flagsData != null) {
			for (key in flagsData.Keys) {
				var endlessData:NBTData = cast flagsData.TryGetValue(key);
				if (endlessData != null) {
					var current = NBTHelper.LoadInt(endlessData, "current", 0);
					var max = NBTHelper.LoadInt(endlessData, "max", 0);
					var record = new Record();
					record.current = current;
					record.max = max;
					flags.set(key, record);
				} else {
					flags.set(key, new Record());
				}
			}
		}
		var result = new OldSaveDataEndless();
		result.version = 0;
		result.flags = flags;
		return result;
	}
}

// PORT-NOTE: C# 嵌套类 OldSaveDataEndless.Record → Haxe 模块级类型
// （Haxe 不支持嵌套类，访问路径为 mvz2.oldsave.OldSaveDataEndless.Record）。
class Record {
	public var current:Int = 0;
	public var max:Int = 0;

	public function new() {}
}
