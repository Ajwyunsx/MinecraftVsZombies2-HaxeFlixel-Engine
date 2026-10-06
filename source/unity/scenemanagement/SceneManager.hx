package unity.scenemanagement;

import flixel.FlxG;
import flixel.FlxState;

// Minimal UnityEngine.SceneManagement.SceneManager shim.
// PORT-NOTE: Unity 的 Scene 概念在移植层映射为 FlxState（PORTING.md §SceneManager）。
class SceneManager {
	private function new() {}

	// 场景名 -> FlxState 类，由启动引导代码（Main/InitState）注册。
	public static var scenes:Map<String, Class<FlxState>> = new Map();

	public static function LoadSceneAsync(sceneName:String, ?mode:LoadSceneMode = LoadSceneMode.Single):Void {
		var stateClass = scenes.get(sceneName);
		if (stateClass == null) {
			// TODO-PORT: Unity 端由 Addressables 场景目录解析场景；移植层需先注册场景状态。
			unity.Debug.LogWarning('Scene is not registered: ${sceneName}');
			return;
		}
		FlxG.switchState(Type.createInstance(stateClass, []));
	}

	public static function LoadScene(sceneName:String, ?mode:LoadSceneMode = LoadSceneMode.Single):Void {
		LoadSceneAsync(sceneName, mode);
	}

	public static function GetActiveScene():Dynamic {
		// TODO-PORT: FlxG 无活动场景元数据。
		return null;
	}
}
