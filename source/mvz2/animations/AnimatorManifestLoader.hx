// Ported from: (新增文件) AnimatorController / AnimationClip 数据的运行期加载
package mvz2.animations;

import haxe.Json;
import mvz2.animations.AnimData.AnimControllerFile;
import mvz2.animations.AnimData.AnimClipFile;
import mvz2.animations.AnimData.AnimManifest;
import mvz2.animations.AnimData.AnimManifestEntry;
import sys.io.File;
import unity.Application;
import unity.Debug;

// PORT-NOTE: 本文件是移植层新增的「动画资产加载器」，没有 C# 对应源码。
//
// C# 侧 `Animator.runtimeAnimatorController` 由 Unity 资产系统直接给出实例；移植层没有这套系统，
// 改由 `tools_build/build_anim.py` 把 `Assets/Animation/**` 的 .controller/.anim 导出成 JSON，
// 这里按 key（相对 assets 的路径，含扩展名）加载并缓存。
//
// key 的写法与场景数据里 `runtimeAnimatorController.asset.path` 完全一致
// （例如 "Animation/Init/Splash/splash.controller"），因此 `ScenePrefabFieldApplier` 写字段时
// 解析出的资产引用可以直接拿来当 key。
class AnimatorManifestLoader {
	/** 清单路径（由 unity.Application.dataPath 给出 assets 根）。 */
	public static function GetManifestPath():String {
		return unity.Application.dataPath + "/anim_manifest.json";
	}

	public static function GetManifest(?reload:Bool = false):Null<AnimManifest> {
		if (manifest == null || reload) {
			manifest = loadManifest();
			index = null;
			if (manifest != null && manifest.entries != null) {
				index = new Map();
				for (entry in manifest.entries) {
					if (entry != null && entry.key != null)
						index.set(entry.key, entry);
				}
			}
		}
		return manifest;
	}

	public static function GetEntry(key:String):Null<AnimManifestEntry> {
		GetManifest();
		if (index == null || key == null)
			return null;
		return index.exists(key) ? index.get(key) : null;
	}

	private static function loadManifest():Null<AnimManifest> {
		var path = GetManifestPath();
		if (!sys.FileSystem.exists(path)) {
			loadWarnings.push('动画清单不存在：$path（需先运行 tools_build/build_anim.py）');
			return null;
		}
		try {
			return cast Json.parse(File.getContent(path));
		} catch (e:Dynamic) {
			loadWarnings.push('动画清单解析失败：$path：$e');
			return null;
		}
	}

	/** 按 key 读取 controller 数据（不存在返回 null）。 */
	public static function LoadController(key:String):Null<AnimControllerFile> {
		var data = loadData(key);
		if (data == null)
			return null;
		if (data.kind != "controller") {
			loadWarnings.push('$key 不是 controller（kind=${data.kind}）');
			return null;
		}
		return cast data;
	}

	/** 按 key 读取 clip 数据（不存在返回 null）。 */
	public static function LoadClip(key:String):Null<AnimClipFile> {
		var data = loadData(key);
		if (data == null)
			return null;
		if (data.kind != "clip") {
			loadWarnings.push('$key 不是 clip（kind=${data.kind}）');
			return null;
		}
		return cast data;
	}

	private static function loadData(key:String):Null<Dynamic> {
		if (key == null)
			return null;
		if (cache.exists(key))
			return cache.get(key);
		var result:Null<Dynamic> = null;
		var entry = GetEntry(key);
		if (entry != null && entry.data != null) {
			var path = unity.Application.dataPath + "/" + entry.data;
			if (sys.FileSystem.exists(path)) {
				try {
					result = Json.parse(File.getContent(path));
				} catch (e:Dynamic) {
					loadWarnings.push('动画数据解析失败：$path：$e');
				}
			} else {
				loadWarnings.push('动画数据文件不存在：$path');
			}
		}
		cache.set(key, result);
		return result;
	}

	// #region 诊断
	public static var loadWarnings:Array<String> = [];
	private static var manifest:Null<AnimManifest> = null;
	private static var index:Map<String, AnimManifestEntry> = null;
	private static var cache:Map<String, Null<Dynamic>> = new Map();
	public static function ResetStats():Void {
		loadWarnings = [];
		cache.clear();
		manifest = null;
		index = null;
	}
	// #endregion
}
