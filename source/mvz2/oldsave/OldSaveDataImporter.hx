// Ported from: Assets/Scripts/OldSave/OldSaveDataImporter.cs

package mvz2.oldsave;

import mvz2.oldsave.OldSaveDataMain.OldSaveData;
import system.io.Directory;
import system.io.File;
import system.io.Path;
import unity.Application;
import unity.Application.RuntimePlatform;
import unity.Debug;

// PORT-NOTE: C# static class → Haxe 全静态成员的 class（私有构造）。
class OldSaveDataImporter {
	private function new() {}

	public static function Import():OldGlobalSave {
		var platform = Application.platform;
		var thisDirectory = Application.persistentDataPath;
		var oldDirectory:String;
		if (platform == RuntimePlatform.WindowsEditor || platform == RuntimePlatform.WindowsPlayer) {
			var cuerzorDirectory = Path.GetDirectoryName(thisDirectory);
			var localLowDirectory = Path.GetDirectoryName(cuerzorDirectory);
			// PORT-NOTE: C# Path.Combine(a, b, c) → 嵌套 Combine（IO shim 的 Combine 只接受两个参数）。
			oldDirectory = Path.Combine(Path.Combine(localLowDirectory, "Tocmic Studio"), "MinecraftVSZombies2");
		} else {
			return null;
		}
		var oldSaveDirectory = Path.Combine(oldDirectory, "saves");
		if (!Directory.Exists(oldSaveDirectory))
			return null;
		var usersPath = Path.Combine(oldSaveDirectory, "users.dat");
		var userList = ImportOldUserList(usersPath);
		if (userList == null)
			return null;

		// PORT-NOTE: C# new OldSaveData[N] → 固定长度（元素为 null）的 Array<OldSaveData>。
		var saveDatas = new Array<OldSaveData>();
		for (i in 0...userList.usernames.length)
			saveDatas.push(null);
		for (i in 0...userList.usernames.length) {
			var userName = userList.usernames[i];
			if (userName == null || userName.length == 0)
				continue;
			var userDirectory = Path.Combine(oldSaveDirectory, 'user${i}');
			var loader = new OldSaveDataLoader(userDirectory);
			var saveData = loader.Load();
			saveDatas[i] = saveData;
		}
		var result = new OldGlobalSave();
		result.userList = userList;
		result.saveDatas = saveDatas;
		return result;
	}

	public static function ImportOldUserList(path:String):OldUserList {
		if (!File.Exists(path))
			return null;
		// PORT-NOTE: C# `using var stream = ...` → 显式 Dispose（Haxe 无 using/finally）。
		// PORT-NOTE: system.io.File shim 的 Open 使用 sys 风格模式字符串，"r" 等价于 C# FileMode.Open。
		var stream = File.Open(path, "r");
		var result:OldUserList = null;
		try {
			result = OldUserList.ReadStream(stream);
		} catch (e:Dynamic) {
			Debug.LogError('An error occured while importing users.dat from the old version: ${e}');
			result = null;
		}
		stream.Dispose();
		return result;
	}
}
