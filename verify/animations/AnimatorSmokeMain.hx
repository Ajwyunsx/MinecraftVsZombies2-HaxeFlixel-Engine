// Ported from: (新增文件) 动画状态机与动画事件的运行期自检（工作包③）
package animations;

import mvz2.animations.AnimatorAutoUpdater;
import mvz2.animations.AnimatorManifestLoader;
import mvz2.animations.AnimatorRuntime;
import mvz2.animations.AnimData;
import unity.Animator;
import unity.GameObject;
import unity.MonoBehaviour;
import unity.Vector3;

/**
 * `AnimatorManifestLoader` / `AnimatorRuntime` 的运行期自检。
 *
 * 核心断言：**`Assets/Animation/Init/Splash/splash.anim` 在 2.5 s 处的
 * `EnterTitleScreen` 事件必须被派发到同一 GameObject 上的 `SplashController`**
 * —— 这是 Splash 页推进到标题页的唯一途径，也是「黑屏卡在 Splash」的修复判据。
 *
 * 用法（在 HaxePort/ 下，先跑过 tools_build/build_anim.py）：
 *
 *   haxe -cp source -cp verify -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl \
 *     -lib hscript -lib hxjsonast -lib json2object -main animations.AnimatorSmokeMain \
 *     -cpp /tmp/anim_smoke -D lime_use_old_deltatime \
 *     --macro "flixel.system.macros.FlxDefines.run()"
 *   # 然后以 HaxePort/ 为工作目录运行产物（unity.Application.dataPath = "assets"）
 *   /tmp/anim_smoke/AnimatorSmokeMain.exe
 */
class AnimatorSmokeMain {
	static var checked:Int = 0;
	static var failures:Array<String> = [];
	static var expected:Int = 0;

	public static function main() {
		Sys.println('dataPath=' + unity.Application.dataPath);
		var manifest = AnimatorManifestLoader.GetManifest();
		if (manifest == null) {
			Sys.println("FAIL: 动画清单加载失败");
			for (warning in AnimatorManifestLoader.loadWarnings)
				Sys.println("  " + warning);
			Sys.exit(1);
		}
		Sys.println('anim manifest: version=${manifest.version} 条目=${manifest.entries.length}');

		checkClipData();
		checkControllerData();
		checkSplashEvent();
		checkCurveWrite();
		checkPageInjection();

		Sys.println('自检完成：断言 $expected 条，通过 $checked 条，失败 ${failures.length} 条');
		for (failure in failures)
			Sys.println('  FAIL ' + failure);
		for (warning in AnimatorManifestLoader.loadWarnings)
			Sys.println('告警：$warning');
		Sys.exit(failures.length == 0 ? 0 : 1);
	}

	/** splash.anim 的数据：长度 2.5、含 1 条 EnterTitleScreen 事件、1 条曲线。 */
	static function checkClipData():Void {
		Sys.println("-- splash.anim 数据 --");
		var clip = AnimatorManifestLoader.LoadClip("Animation/Init/Splash/splash.anim");
		check(clip != null, "splash.anim 能加载");
		if (clip == null)
			return;
		check(clip.length == 2.5, 'clip 长度 == 2.5（实际 ${clip.length}）');
		check(clip.events.length == 1, '事件数 == 1（实际 ${clip.events.length}）');
		if (clip.events.length > 0) {
			check(clip.events[0].functionName == "EnterTitleScreen",
				'事件函数名 == EnterTitleScreen（实际 ${clip.events[0].functionName}）');
			check(clip.events[0].time == 2.5, '事件时间 == 2.5（实际 ${clip.events[0].time}）');
		}
		check(clip.curves.length >= 1, '曲线数 >= 1（实际 ${clip.curves.length}）');
	}

	/** splash.controller 的数据：1 层、默认状态绑定 splash.anim。 */
	static function checkControllerData():Void {
		Sys.println("-- splash.controller 数据 --");
		var controller = AnimatorManifestLoader.LoadController("Animation/Init/Splash/splash.controller");
		check(controller != null, "splash.controller 能加载");
		if (controller == null)
			return;
		check(controller.layers.length == 1, '层数 == 1（实际 ${controller.layers.length}）');
		var layer = controller.layers[0];
		var machine:AnimStateMachine = Reflect.field(controller.machines, layer.machine);
		check(machine != null, "层指向的状态机存在");
		if (machine == null)
			return;
		check(machine.defaultState != null, "状态机有默认状态");
		var state:AnimState = Reflect.field(controller.states, machine.defaultState);
		check(state != null, "默认状态存在");
		if (state == null)
			return;
		check(state.clip == "Animation/Init/Splash/splash.anim",
			'默认状态的 clip == splash.anim（实际 ${state.clip}）');
	}

	/**
	 * **核心断言**：驱动 Animator 3 秒，`EnterTitleScreen` 必须被调用一次。
	 *
	 * 用一个最小的 `SplashProbe` 组件替代 `SplashController`（后者会访问运行期管理器），
	 * 语义等价：动画事件按 Unity 的 SendMessage 规则发给**同一 GameObject 上的组件**。
	 */
	static function checkSplashEvent():Void {
		Sys.println("-- 动画事件派发（Splash → Titlescreen 的关键路径） --");
		var root = new GameObject("Splash");
		var probe = root.AddComponent(SplashProbe);
		var animator = root.AddComponent(Animator);
		animator.runtimeAnimatorController = "Animation/Init/Splash/splash.controller";
		check(animator.HasController(), "Animator 绑定 controller 成功");
		check(animator.runtime != null, "Animator 有运行期状态机");

		var updater = new AnimatorAutoUpdater();
		updater.addTree(root);
		check(updater.count == 1, '登记了 1 个 Animator（实际 ${updater.count}）');

		// 按 60 fps 推进 3 秒（事件在 2.5 s）。`AnimatorAutoUpdater` 不维护自己的时钟，
		// 这里累计推进时长自己算（`unity.Time.time` 是墙钟，与本自检的模拟推进无关）。
		var elapsed = 0.0;
		for (_ in 0...180) {
			updater.update(1 / 60);
			elapsed += 1 / 60;
		}
		check(probe.calls == 1, 'EnterTitleScreen 被调用 1 次（实际 ${probe.calls}）');
		check(elapsed >= 2.5, '推进时长跨过 2.5s（实际 $elapsed）');

		// 再推进 3 秒不应重复触发（事件只在该帧跨越时派发）。
		for (_ in 0...180)
			updater.update(1 / 60);
		check(probe.calls == 1, '再推进 3 秒不重复触发（实际 ${probe.calls}）');

		// enabled=false 的 Animator 不应被自动推进（Unity 语义；显式 Update 仍生效）。
		animator.enabled = false;
		probe.calls = 0;
		for (_ in 0...180)
			updater.update(1 / 60);
		check(probe.calls == 0, 'enabled=false 时自动推进被跳过（实际 ${probe.calls}）');
	}

	/** 曲线求值：m_IsActive / Transform 位置按线性插值写回目标。 */
	static function checkCurveWrite():Void {
		Sys.println("-- 曲线求值（Mainmenu 的相机位移动画） --");
		// mainmenu_start.anim 有 Cameras/Camera 的 m_LocalPosition.{x,y,z} 曲线。
		var clip = AnimatorManifestLoader.LoadClip("Animation/Mainmenu/mainmenu_start.anim");
		check(clip != null, "mainmenu_start.anim 能加载");
		if (clip == null)
			return;
		var posCurves = [for (c in clip.curves) if (c.attribute == "m_LocalPosition.y") c];
		check(posCurves.length == 1, '有 1 条 m_LocalPosition.y 曲线（实际 ${posCurves.length}）');
		if (posCurves.length == 0)
			return;

		var root = new GameObject("Mainmenu");
		var cameras = new GameObject("Cameras");
		cameras.transform.SetParent(root.transform, false);
		var camera = new GameObject("Camera");
		camera.transform.SetParent(cameras.transform, false);
		check(camera.transform.localPosition.y == 0, "曲线写入前相机 y == 0");
		var animator = root.AddComponent(Animator);
		animator.runtimeAnimatorController = "Animation/Mainmenu/mainmenu.controller";

		// 直接驱动：默认状态是 Start（mainmenu_start.anim，0 → 0.5s 相机 y 从 12 到 0）。
		// PORT-NOTE: Start 状态带一条 `hasExitTime` 转移（exitTime=0.5，dst=Blend Tree），
		// 所以推进到 normalized >= 0.5 时状态会切换、时间重置（Unity 的同一语义）。
		// 这里分两次推进各 0.2s（normalized 0.4 < 0.5），验证线性插值确实在写字段。
		animator.Update(0.2);
		var after1 = camera.transform.localPosition.y;
		check(after1 > 0 && after1 < 12, '0.2s 处 y 在 (0,12) 之间（实际 $after1）');
		animator.Update(0.2);
		var after2 = camera.transform.localPosition.y;
		check(after2 < after1, '0.4s 处 y 继续下降（0.2s=$after1 -> 0.4s=$after2）');
		// 再推进 0.2s（normalized 0.6 >= exitTime 0.5）应触发转移到 Blend Tree 状态。
		animator.Update(0.2);
		check(animator.runtime.GetCurrentAnimatorStateInfo(0).shortNameHash == Animator.StringToHash("Blend Tree"),
			'exitTime 到点后转移到 Blend Tree 状态（实际 ${animator.GetCurrentAnimationName()}）');
	}

	/**
	 * 页面 prefab 注入的 Animator 是否真的建出来（对应游戏里 `MainGameScene.InjectPagePrefab`）。
	 *
	 * PORT-NOTE: 这是「Splash 页能否推进」的前置条件 —— 注入失败的页面连 Animator 都没有，
	 * 动画事件自然不会被触发。游戏侧 boot-trace 里 `Animator 已登记：N 个` 就是这个统计。
	 */
	static function checkPageInjection():Void {
		Sys.println("-- 页面 prefab 注入的 Animator 统计 --");
		var pages = [
			"Map" => "Prefabs/Map/Map",
			"Titlescreen" => "Prefabs/Init/Titlescreen",
			"Mainmenu" => "Prefabs/Mainmenu/Mainmenu",
			"Splash" => "Prefabs/Init/Splash",
		];
		for (name in pages.keys()) {
			var key = pages.get(name);
			var root = new GameObject(name);
			var written = mvz2.scenes.ScenePrefabLoader.InstantiateInto(key, root, null, false);
			check(written > 0, '$name 注入写入字段 > 0（实际 $written）');
			var animators = root.GetComponentsInChildren(Animator, true);
			check(animators.length > 0, '$name 注入后子树里有 Animator（实际 ${animators.length}）');
			// 页面根上的控制器组件引用的 Animator 应能绑定 controller 数据。
			var bound = 0;
			for (a in animators)
				if (a.HasController())
					bound++;
			check(bound > 0, '$name 注入后至少 1 个 Animator 绑定了 controller（实际 $bound/${animators.length}）');
		}
	}

	// #region 辅助
	static function check(condition:Bool, message:String):Void {
		expected++;
		if (condition) {
			checked++;
		} else {
			failures.push(message);
		}
	}
	// #endregion
}

/** 替身：记录 `EnterTitleScreen` 被调用的次数与时刻（避免依赖运行期管理器）。 */
class SplashProbe extends MonoBehaviour {
	public var calls:Int = 0;
	public var lastTime:Float = 0;

	public function EnterTitleScreen():Void {
		calls++;
		lastTime = unity.Time.time;
	}
}
