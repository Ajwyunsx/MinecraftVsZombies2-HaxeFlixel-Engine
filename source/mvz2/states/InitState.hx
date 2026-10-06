// Ported from: Assets/Scenes/Landing.unity
//              Assets/Scripts/Loader/LandingSceneController.cs
// PORT-NOTE: 原工程构建场景列表里 Landing 是启动场景（只含 LandingSceneController、BackCamera、
// MVZ2Logger 三个对象）；LandingSceneController.Start 注册 Vanilla MOD，并通过
// Addressables.LoadSceneAsync("Main", LoadSceneMode.Single) 进入 Main 场景。
// 移植层没有 Addressables 场景目录，改用 unity.scenemanagement.SceneManager 的场景名→FlxState 表
// （PORTING.md §SceneManager），本状态就是 Landing 场景的宿主。
package mvz2.states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import mvz2.LandingSceneController;
import mvz2.debugs.MVZ2Logger;
import unity.Camera;
import unity.Component;
import unity.GameObject;
import unity.MonoBehaviour;
import unity.scenemanagement.SceneManager;

class InitState extends FlxState {
	private var root:GameObject;
	private var landingController:LandingSceneController;
	private var logger:MVZ2Logger;
	private var behaviours(default, null):Array<MonoBehaviour> = [];

	public function new() {
		super();
	}

	override public function create():Void {
		super.create();

		BootTrace.start();
		BootTrace.step("InitState.create 进入（Landing 场景）");

		bgColor = FlxColor.BLACK;
		StartupError.install();
		registerScenes();
		BootTrace.step("场景已注册：Landing / Main");

		try {
			buildLandingScene();
			BootTrace.step("Landing 场景对象已创建");
			// PORT-NOTE: 对应 Unity 加载 Landing 场景时对组件调用 Awake（引擎反射），这里是显式调用。
			// Logger 最先调用（它负责把后续日志写入文件，便于排查启动问题）。
			@:privateAccess logger.Awake();
			BootTrace.step("MVZ2Logger.Awake 完成");
			// PORT-NOTE: 对应 Unity 在 Awake 之后调用 Start。LandingSceneController.Start 会注册
			// Vanilla MOD，并切换到 "Main" 场景（通过 SceneManager.scenes 里登记的状态）。
			@:privateAccess landingController.Start();
			BootTrace.step("LandingSceneController.Start 完成（已请求切换到 Main 场景）");
		} catch (e:Dynamic) {
			BootTrace.error('InitState.create 抛出：${Std.string(e)}');
			StartupError.record(e);
			FlxG.switchState(new ErrorState());
		}
	}

	/**
	 * PORT-NOTE: 对应 Unity 的 Build Settings 场景列表 / Addressables 场景目录。
	 * 启动场景（Landing）自身也登记进去，保证 SceneManager.LoadSceneAsync("Landing") 与 Unity 一致。
	 */
	private function registerScenes():Void {
		SceneManager.scenes.set("Landing", InitState);
		SceneManager.scenes.set("Main", MainSceneState);
		// TODO-PORT: "Level" 场景（Assets/GameContent/Scenes/Level.unity）尚未接线，
		// 需要 LevelController 的场景图（含大量 prefab 引用）转换完成后再登记。
	}

	/** 对应 Assets/Scenes/Landing.unity 的对象层级：Landing / BackCamera / Logger。 */
	private function buildLandingScene():Void {
		root = new GameObject("Landing");

		var cameraObject = child(root, "BackCamera");
		attach(cameraObject, new Camera());
		cameraObject.tag = "MainCamera";

		logger = attach(child(root, "Logger"), new MVZ2Logger());
		landingController = attach(child(root, "Landing"), new LandingSceneController());
	}

	private function child(parent:GameObject, name:String):GameObject {
		var go = new GameObject(name);
		go.transform.SetParent(parent.transform, false);
		return go;
	}

	// PORT-NOTE: 与 MainGameScene 同理，用显式 new + 手工登记替代
	// unity.GameObject.AddComponent 的运行期反射构造。
	private function attach<T:Component>(parent:GameObject, component:T):T {
		@:privateAccess {
			component.gameObject = parent;
			component.transform = parent.transform;
			parent.components.push(component);
		}
		if (Std.isOfType(component, MonoBehaviour))
			behaviours.push(cast component);
		// PORT-NOTE: 与 MainGameScene.attach 同理 —— 手工登记路径也要把 SpriteRenderer
		// 交给渲染桥，否则 visible/scale/angle 不同步。
		if (Std.isOfType(component, unity.SpriteRenderer))
			unity.RenderBridge.registerRenderer(cast component);
		return component;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// PORT-NOTE: Landing 场景只在第一帧存活（Start 里就切场景了），这里仍按 Unity 行为
		// 驱动协程运行器，保证 LoadSceneAsync 前后的协程能推进。
		for (behaviour in behaviours) {
			if (behaviour.gameObject == null || !behaviour.gameObject.activeInHierarchy)
				continue;
			behaviour.coroutineRunner.update(elapsed);
		}
	}
}
