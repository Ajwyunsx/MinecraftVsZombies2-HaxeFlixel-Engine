// Ported from: Assets/Scripts/OldSave/OldSaveDataLoader.cs

package mvz2.oldsave;

import mvz2.oldsave.OldSaveDataMain.OldSaveData;
import mvz2.oldsave.OldSaveDataMain.OldSaveDataAchievements;
import mvz2.oldsave.OldSaveDataMain.OldSaveDataEndless;
import mvz2.oldsave.OldSaveDataMain;
import nbtutility.NBTData;
import nbtutility.NBTMapper;
import nbtutility.NBTReader;
import system.io.File;
import system.io.Path;
import system.text.Encoding;
import unity.Debug;

class OldSaveDataLoader {
	public function new(directory:String) {
		this.directory = directory;
	}

	public function Load():OldSaveData {
		var main = LoadMain();
		var achievements = LoadAchievements();
		var endless = LoadEndless();
		var result = new OldSaveData();
		result.main = main;
		result.achievements = achievements;
		result.endless = endless;
		return result;
	}

	private function LoadMain():OldSaveDataMain {
		var dir = GetGlobalSaveDataDirectory();
		var path = Path.Combine(dir, "main.dat");
		if (!File.Exists(path))
			return null;

		// PORT-NOTE: C# `using var stream = ...` → 显式 Dispose（Haxe 无 using/finally）。
		// PORT-NOTE: system.io.File shim 的 Open 使用 sys 风格模式字符串，"r" 等价于 C# FileMode.Open。
		var stream = File.Open(path, "r");
		var result:OldSaveDataMain = null;
		try {
			var reader = new NBTReader(stream, Encoding.UTF8);
			var nbt = NBTMapper.ToObject(reader);
			result = OldSaveDataMain.FromNBT(nbt);
		} catch (ex:Dynamic) {
			Debug.LogError('An error occured while importing main.dat from the old version: ${ex}');
			result = null;
		}
		stream.Dispose();
		return result;
	}

	private function LoadAchievements():OldSaveDataAchievements {
		var dir = GetGlobalSaveDataDirectory();
		var path = Path.Combine(dir, "achievements.dat");
		if (!File.Exists(path))
			return null;

		// PORT-NOTE: C# `using var stream = ...` → 显式 Dispose（Haxe 无 using/finally）。
		var stream = File.Open(path, "r");
		var result:OldSaveDataAchievements = null;
		try {
			var reader = new NBTReader(stream, Encoding.UTF8);
			var nbt = NBTMapper.ToObject(reader);
			result = OldSaveDataAchievements.FromNBT(nbt);
		} catch (ex:Dynamic) {
			Debug.LogError('An error occured while importing achievements.dat from the old version: ${ex}');
			result = null;
		}
		stream.Dispose();
		return result;
	}

	private function LoadEndless():OldSaveDataEndless {
		var dir = GetGlobalSaveDataDirectory();
		var path = Path.Combine(dir, "endless.dat");
		if (!File.Exists(path))
			return null;

		// PORT-NOTE: C# `using var stream = ...` → 显式 Dispose（Haxe 无 using/finally）。
		var stream = File.Open(path, "r");
		var result:OldSaveDataEndless = null;
		try {
			var reader = new NBTReader(stream, Encoding.UTF8);
			var nbt = NBTMapper.ToObject(reader);
			result = OldSaveDataEndless.FromNBT(nbt);
		} catch (ex:Dynamic) {
			Debug.LogError('An error occured while importing endless.dat from the old version: ${ex}');
			result = null;
		}
		stream.Dispose();
		return result;
	}

	private function GetGlobalSaveDataDirectory():String {
		// PORT-NOTE: C# Path.Combine(a, b, c) → 嵌套 Combine（IO shim 的 Combine 只接受两个参数）。
		return Path.Combine(Path.Combine(directory, "global"), "mvz2");
	}

	private var directory:String;
}
