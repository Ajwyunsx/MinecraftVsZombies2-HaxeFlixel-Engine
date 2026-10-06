// Ported from: Assets/GameContent/Scenes/Main.unity（+ Assets/Prefabs/MainGame.prefab）
// PORT-NOTE: 原工程 "Main" 场景由 Addressables.LoadSceneAsync("Main", Single) 加载
// （见 LandingSceneController.Start）。移植层把 Unity 场景映射为 FlxState
// （PORTING.md §SceneManager），本状态就是 "Main" 场景的宿主：它创建场景对象图、
// 分发 Awake，然后由 GameEntrance.Start 驱动后续的初始化与资源加载。
package mvz2.states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import mvz2.ui.UiRenderer;
import unity.Debug;

class MainSceneState extends FlxState {
	public var scene(default, null):MainGameScene;
	/** uGUI → Flixel 显示列表的渲染桥（见 mvz2/ui/UiRenderer.hx）。 */
	public var uiRenderer(default, null):UiRenderer;

	public function new() {
		super();
	}

	override public function create():Void {
		super.create();

		BootTrace.step("MainSceneState.create 进入（Main 场景）");

		bgColor = FlxColor.BLACK;
		// PORT-NOTE: 必须先安装错误记录器，才能捕获 GameEntrance 内部被 ShowErrorDialog
		// 吞掉、以及被本方法 catch 到的异常（对应 GameEntrance.ShowErrorDialog 的 Debug.LogException）。
		StartupError.install();

		try {
			scene = new MainGameScene();
			BootTrace.step('MainGameScene 对象图已构建（${scene.behaviours.length} 个组件）');
			// PORT-NOTE: 建立 uGUI → Flixel 的渲染桥。Unity 由引擎的 Canvas/Graphic 系统绘制 UI，
			// 移植层的 `unity.ui.*` 只是逻辑 shim（`Graphic.Rebuild()` 空实现、整包不加任何显示对象），
			// 因此必须在场景树建好后安装本桥，否则画面永远是纯黑（见 tools_build/ui_render_findings.md）。
			// 挂在 FlxState 的成员表上（不是 FlxG.plugins）：UI 必须永远盖在游戏画面上，
			// 而 plugins 的绘制顺序是全局的 drawOnTop 开关，会影响其它插件。
			uiRenderer = UiRenderer.install(scene.root);
			BootTrace.step('UI 渲染桥已安装（uGUI 根：${scene.root.name}）');
			// PORT-NOTE: 对应 Unity 加载场景时对组件调用 Awake（内部逐个 try/catch，缺 prefab 引用
			// 的 UI 组件会记录到 awakeFailures 而不中断启动）。
			scene.awakeAll();
			BootTrace.step('组件 Awake 分发完成，失败 ${scene.awakeFailures.length} 个，跳过 ${scene.skippedAwake.length} 个');
			logAwakeFailures();
			logSkippedAwake();
			// PORT-NOTE: 对应 Unity 在 Awake 之后调用 Start。GameEntrance.Start 里会依次执行
			// main.Initialize()（管理器初始化 + MOD 资源加载）与 main.InitLoad()（MOD 主资源加载）。
			scene.startAll();
			// PORT-NOTE: GameEntrance.Initialize 会把 InitializeAsync 里抛出的异常交给
			// ShowErrorDialog（内部走 Debug.LogException → unity.Application.logMessageReceived），
			// 对话框本身在 prefab 转换前是空引用、可能被吞掉，于是"启动其实失败了"却看不到任何痕迹。
			// 这里把 StartupError 收集到的内容落到 boot-trace，保证被吞掉的错误一定可见。
			dumpStartupErrors();
			BootTrace.finish("GameEntrance.Start 完成，已进入主流程");
		} catch (e:Dynamic) {
			BootTrace.error('MainSceneState.create 抛出：${Std.string(e)}');
			StartupError.record(e);
			// PORT-NOTE: FlxG.switchState 只是登记下一次状态切换，本状态的 update() 还会再跑一帧；
			// 若不先把场景置空，半初始化（资源没加载完）的组件会在那一帧里继续 Update 并二次崩溃。
			scene = null;
			// PORT-NOTE: 原工程的错误会交给 GameEntrance.ShowErrorDialog 弹对话框；移植阶段
			// 对话框依赖尚未转换的 prefab UI，因此降级为 ErrorState 直接显示错误信息。
			FlxG.switchState(new ErrorState());
		}
	}

	override public function update(elapsed:Float):Void {
		// PORT-NOTE: 心跳写在最前面——启动完成后唯一还能观察进程是否健在的途径（lime 的 Windows GUI
		// 程序没有 stdout，画面在 prefab UI 转换完成前也还是空的）。写在 super/scene.update 之前，
		// 这样即使后面的帧内容抛异常也还有痕迹（配合 Main.installFrameHeartbeat 区分
		// 「openfl 主循环在跑」和「FlxState.update 真的被调用」）。
		frames++;
		if (frames == 1) {
			BootTrace.step("update 循环已进入（MainSceneState.update 第 1 帧）");
		} else if (frames == 120) {
			BootTrace.step("update 循环正常（第 120 帧）");
			logUiStats();
		} else if (frames % 1800 == 0) {
			BootTrace.step('运行中：已更新 ${frames} 帧');
			logUiStats();
		}

		super.update(elapsed);

		if (scene != null) {
			// PORT-NOTE: 对应 Unity 每帧对场景内组件调用 Update/协程步进。
			try {
				scene.update(elapsed);
			} catch (e:Dynamic) {
				BootTrace.error('场景 Update 抛出（本状态继续运行）：${Std.string(e)}');
			}
		}
	}

	private var frames:Int = 0;

	/**
	 * 把 UI 渲染桥的统计写进 boot-trace。
	 *
	 * PORT-NOTE: lime 的 Windows 程序是 GUI 子系统，没有 stdout，画面又可能被别的窗口盖住，
	 * 因此"UI 到底画出来没有"必须有一个不依赖截图的客观判据。这里周期性落盘：
	 * 可见渲染项数、Graphic/文本/纯色/世界精灵/跳过 各自的数量、以及取帧失败数
	 * （`SpriteFrameFactory.failureCount` 非 0 = 贴图没解码出来）。
	 */
	private function logUiStats():Void {
		if (uiRenderer == null)
			return;
		BootTrace.step('UI 渲染统计：可见项=${uiRenderer.visibleCount} / 成员=${uiRenderer.length}'
			+ '（Graphic=${UiRenderer.graphicCount} 文本=${UiRenderer.textCount} 纯色=${UiRenderer.solidCount}'
			+ ' 世界精灵=${UiRenderer.spriteRendererCount} 跳过=${UiRenderer.skippedCount}），'
			+ '取帧失败=${mvz2.sprites.SpriteFrameFactory.failureCount}');
		// PORT-NOTE: 「白块」现象 = Image 退化成 1x1 白图拉伸。必须区分两种成因：
		//   * imageWithoutSprite > 0 —— prefab 注入没把 sprite 写进 Image（手工对象图 / 缺注入点）；
		//   * imageFrameFailed > 0   —— sprite 有，但取不到帧（贴图没解码 / 矩形为空）。
		BootTrace.step('  UI 快照（sync 末尾自洽）：${UiRenderer.snapshot}');
		// PORT-NOTE: 协程驱动登记表的状态。关卡场景树的协程原先无人驱动（见
		// unity/BehaviourRegistry.hx），这里落盘一次便于确认「关卡树组件确实被纳入每帧步进」：
		// 进入关卡后 registered 应出现约 +1460 的跃升（Level 场景 2100 个组件里的 MonoBehaviour）。
		// 只在既有的周期性日志点写，不额外增加每帧开销。
		BootTrace.step('  协程登记表：已登记=${unity.BehaviourRegistry.count}'
			+ ' 活跃=${unity.BehaviourRegistry.activeCount}'
			+ ' 已淘汰=${unity.BehaviourRegistry.pruned}'
			+ ' 协程异常=${unity.BehaviourRegistry.failures}');
		BootTrace.step('  updateGraphic 样例：' + UiRenderer.updateGraphicSamples.join(" | "));
		BootTrace.step('UI Image 诊断：有 sprite=${UiRenderer.imageWithSprite}'
			+ ' sprite 为 null=${UiRenderer.imageWithoutSprite} 取帧失败=${UiRenderer.imageFrameFailed}');
		if (UiRenderer.imageWithoutSpriteSamples.length > 0)
			BootTrace.step('  sprite 为 null 的节点（前 ${UiRenderer.imageWithoutSpriteSamples.length} 个）：'
				+ UiRenderer.imageWithoutSpriteSamples.join(" | "));
		if (UiRenderer.imageFrameFailedSamples.length > 0)
			BootTrace.step('  取帧失败的节点（前 ${UiRenderer.imageFrameFailedSamples.length} 个）：'
				+ UiRenderer.imageFrameFailedSamples.join(" | "));
		var clsList:Array<String> = [];
		for (k in UiRenderer.graphicClassCounts.keys())
			clsList.push('$k=${UiRenderer.graphicClassCounts.get(k)}');
		BootTrace.step('  Graphic 具体类分布（有 RectTransform=${UiRenderer.rectGraphicCount}）：' + clsList.join(", "));
		// PORT-NOTE: 命中区诊断原先**从未落盘** —— `hitTargetSamples` 每帧都在填，却没有任何
		// 读取点，于是「可点击=0」或「按钮画得出来但点不到」这类问题只能靠肉眼猜。
		// 这里把每条的**节点路径 + 命中来源 + 屏幕矩形**写出来，命中判定是否落在画面上可一眼核对。
		BootTrace.step('  可点击项（前 ${UiRenderer.hitTargetSamples.length} 个，格式=节点[来源 x,y WxH]）：'
			+ UiRenderer.hitTargetSamples.join(" | "));
		if (UiRenderer.nonRectGraphicSamples.length > 0)
			BootTrace.step('  Graphic 挂在非 RectTransform 上（前 ${UiRenderer.nonRectGraphicSamples.length} 个）：'
				+ UiRenderer.nonRectGraphicSamples.join(" | "));
		if (UiRenderer.lastError != null)
			BootTrace.error('UI 渲染桥上次同步异常：${UiRenderer.lastError}');
	}

	/** 把 StartupError 收集到的信息（含被 ShowErrorDialog 吞掉的异常）写进 boot-trace。 */
	private function dumpStartupErrors():Void {
		var errors = StartupError.all;
		if (errors.length == 0) {
			BootTrace.step("startAll 返回：本次启动未记录任何错误日志");
			return;
		}
		BootTrace.step('startAll 返回：记录到 ${errors.length} 条日志（含被吞掉的异常），逐条如下');
		for (entry in errors) {
			BootTrace.error('[${Std.string(entry.logType)}] ${entry.message}');
			var stack = entry.stackTrace;
			if (stack != null && stack.length > 0) {
				var lines = stack.split("\n");
				for (i in 0...Std.int(Math.min(lines.length, 12))) {
					BootTrace.error('    ${lines[i]}');
				}
			}
		}
	}

	private function logAwakeFailures():Void {
		if (scene.awakeFailures.length == 0)
			return;
		Debug.LogWarning('[MVZ2] 有 ${scene.awakeFailures.length} 个组件的 Awake 失败（通常因为 prefab 引用尚未转换）：');
		for (failure in scene.awakeFailures) {
			Debug.LogWarning('  - $failure');
		}
	}

	/** PORT-NOTE: 这些组件对应于 prefab 里带 [SerializeField] UI 引用的页面控制器，引用未转换前不分发 Awake。 */
	private function logSkippedAwake():Void {
		if (scene.skippedAwake.length == 0)
			return;
		BootTrace.step('跳过 Awake 的页面组件（prefab 引用未转换）：${scene.skippedAwake.join(", ")}');
	}
}
