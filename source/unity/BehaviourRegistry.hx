package unity;

// PORT-NOTE: 移植层新增（无 C# 对应源码）。**这是「Unity 引擎每帧推进全部 MonoBehaviour 协程」的登记点。**
//
// 背景：Unity 由引擎驱动**场景内全部** MonoBehaviour 的协程 —— 不管组件是场景反序列化出来的、
// prefab 实例化出来的，还是 `AddComponent` 加上的。移植层没有引擎，`MainGameScene.update` 只能
// 驱动它自己手工 `new` 并登记的那批组件（`behaviours`，见 `MainGameScene.attach`），于是两类组件被漏掉：
//
//   1. **关卡场景树**：`ScenePrefabLoader.InstantiateScene("Level")` 走 `GameObject.AddComponent`
//      建组件，这些组件不在任何 `behaviours` 表里。`LevelController` / `LevelBlueprintChooseController`
//      的过渡协程因此在 `start()` 的第一段之后**永远不会恢复** ——
//      关卡开场（GameStartTransition / GameStartToLawnTransition）、选卡进出草坪
//      （BlueprintChosenTransition / BlueprintChooseViewLawnTransition）、
//      相机移动（MoveCameraToLawn/Choose/House）、失败结算（GameOverByEnemyTransition）
//      全部卡在第一个挂起点上（`LevelController.hx:3801~3940`、`LevelBlueprintChooseController.hx:1487~1539`）。
//   2. **页面 prefab 注入出来的子树**：`ScenePrefabLoader.InstantiateInto`（`MainGameScene` 的
//      `InjectPagePrefab`）同样走 `AddComponent`，这些组件上的协程也不被驱动。
//
// 与 `unity.RenderBridge` 是同一模式（SpriteRenderer 的登记点）：**谁创建组件谁登记，帧循环统一驱动**。
// 登记点放在 `GameObject.AddComponent` —— 它是 prefab/场景实例化的唯一入口，不会漏。
//
// 与 `MainGameScene.behaviours` 的关系：两者**不重叠**。`MainGameScene.attach` / `InitState.attach`
// 是显式 `new` + 手工登记，不经过 `AddComponent`，因此不在本表里；本表只收 `AddComponent` 创建的组件。
// 现有驱动路径保持不变（不回退已有修复），本表只补上「没人驱动」的那一半。
//
// 生命周期：只登记，不持有所有权。对象销毁（`UnityObject.destroy` 会把整棵子树的组件置
// `destroyed = true`）后由 `prune()` 淘汰，避免反复进出关卡时无限累积。
class BehaviourRegistry {
	/** 已登记的 MonoBehaviour（顺序 = 登记顺序）。 */
	private static var behaviours:Array<MonoBehaviour> = [];
	/** 是否已挂上 `FlxG.signals.postUpdate`。 */
	private static var installed:Bool = false;
	/** 因已销毁被淘汰的累计数量（诊断用）。 */
	public static var pruned:Int = 0;
	/** 因协程抛异常而停止步进的组件数（等价 Unity 只记录日志、不中断其它组件）。 */
	public static var failures:Int = 0;

	private function new() {}

	// #region 登记
	/**
	 * 登记一个组件。
	 *
	 * PORT-NOTE: 参数类型放宽为 `Dynamic` 是为了和 `GameObject.AddComponent<T>` 的
	 * 无约束泛型参数（可查询接口类型，如 `IModelComponent`）对齐，由本方法自行判型；
	 * 非 MonoBehaviour 直接忽略。
	 */
	public static function register(component:Dynamic):Void {
		if (component == null || !Std.isOfType(component, MonoBehaviour))
			return;
		var behaviour:MonoBehaviour = cast component;
		if (behaviours.indexOf(behaviour) >= 0)
			return;
		behaviours.push(behaviour);
		ensureInstalled();
	}

	/**
	 * 惰性安装每帧驱动。
	 *
	 * PORT-NOTE: 不能在**静态字段初始化**里挂信号 —— hxcpp 会在 `main()` 之前跑完全部静态初始化
	 * （见 PORTING.md「hxcpp 启动期静态初始化约束」），此时 `FlxG.signals` 可能还没建好。
	 * 因此由登记点（`GameObject.AddComponent`）在运行期触发，与 `RenderBridge.ensureInstalled` 一致。
	 *
	 * 用 `FlxG.signals.postUpdate`（而不是各状态自己调）：协程推进是**引擎行为**，与当前处于哪个
	 * FlxState 无关 —— 关卡场景树由 `LevelManager` 建立，而帧循环在 `MainSceneState` 里，
	 * 两者没有直接引用关系。挂在全局信号上才能覆盖「关卡树存活但宿主状态不同」的情况。
	 *
	 * 选 `postUpdate` 而不是 `preUpdate`（`RenderBridge` 用的是后者）：它排在
	 * `_state.tryUpdate` **之后**，与 Unity「先跑完全部 Update、再恢复协程」的顺序一致，
	 * 也保证与 `MainGameScene.update` 里驱动 `behaviours` 的那批协程**同相**（都在 Update 之后），
	 * 不会出现两组协程相差一个阶段的情况。
	 */
	public static function ensureInstalled():Void {
		if (installed)
			return;
		try {
			if (flixel.FlxG.signals == null)
				return;
			flixel.FlxG.signals.postUpdate.add(onPostUpdate);
			installed = true;
		} catch (e:Dynamic) {
			// PORT-NOTE: Flixel 尚未初始化（纯逻辑冒烟测试直接 `new GameObject()`）时静默跳过；
			// 下次登记点会重试。冒烟测试直接调 `step(elapsed)`。
		}
	}

	private static function onPostUpdate():Void {
		step(flixel.FlxG.elapsed);
	}
	// #endregion

	// #region 步进
	/**
	 * 推进全部已登记组件的协程（等价 Unity 引擎每帧对场景内组件的协程步进）。
	 *
	 * 语义对齐 Unity：
	 *   * 未激活（`activeInHierarchy == false`）的对象上的协程**不**推进；
	 *   * 某个组件的协程抛异常只影响它自己（记录日志后继续跑其它组件），
	 *     否则一个坏协程会打断整帧的协程推进。
	 */
	public static function step(elapsed:Float):Void {
		prune();
		// PORT-NOTE: 按**下标**遍历而不是 `behaviours.copy()`：本方法每帧都跑，而登记表里
		//   会有上千个组件（关卡场景树 2100 个组件几乎全是 Image/CanvasRenderer），
		//   每帧复制一次数组是纯浪费。协程体在步进期间新建组件会被追加到表尾，
		//   下一帧才被步进 —— 与 Unity「新组件下一帧开始收到引擎回调」一致。
		var count = behaviours.length;
		for (i in 0...count) {
			if (i >= behaviours.length)
				break;
			var behaviour = behaviours[i];
			if (behaviour == null || behaviour.destroyed || behaviour.gameObject == null)
				continue;
			if (!behaviour.gameObject.activeInHierarchy)
				continue;
			var runner = behaviour.coroutineRunner;
			// PORT-NOTE: 空 runner 直接跳过（绝大多数组件从不启动协程）。这一步让
			//   「登记全部组件」的语义代价降到可忽略，同时不影响任何真实协程。
			if (runner == null || runner.isEmpty)
				continue;
			try {
				runner.update(elapsed);
			} catch (e:Dynamic) {
				failures++;
				var message = '${Type.getClassName(Type.getClass(behaviour))}: ${Std.string(e)}';
				Debug.LogError('[MVZ2] 协程 Update 失败（该组件已停止步进协程）- $message');
			}
		}
	}

	/**
	 * 淘汰已销毁的组件（对应 Unity 在对象销毁时把它移出引擎的组件表）。
	 *
	 * PORT-NOTE: `GameObject.destroy` 会把整棵子树的组件置 `destroyed = true`，
	 * 因此退出关卡（`LevelManager.ExitLevelSceneAsync` → `DestroyLevelSceneRoot`）后
	 * 这棵树的组件会在这里被清掉。
	 */
	public static function prune():Void {
		var i = behaviours.length - 1;
		while (i >= 0) {
			var behaviour = behaviours[i];
			if (behaviour == null || behaviour.destroyed || behaviour.gameObject == null) {
				behaviours.splice(i, 1);
				pruned++;
			}
			i--;
		}
	}
	// #endregion

	// #region 诊断
	/** 已登记的组件数。 */
	public static var count(get, never):Int;
	static function get_count():Int return behaviours.length;

	/** 其中「当前帧会真的被步进」的个数（已销毁 / 未激活的不算）。 */
	public static var activeCount(get, never):Int;
	static function get_activeCount():Int {
		var n = 0;
		for (behaviour in behaviours)
			if (behaviour != null && !behaviour.destroyed && behaviour.gameObject != null
				&& behaviour.gameObject.activeInHierarchy)
				n++;
		return n;
	}

	/** 已登记的组件类型名 -> 个数（诊断用）。 */
	public static function classCounts():Map<String, Int> {
		var result = new Map<String, Int>();
		for (behaviour in behaviours) {
			if (behaviour == null)
				continue;
			var key = Type.getClassName(Type.getClass(behaviour));
			result.set(key, (result.exists(key) ? result.get(key) : 0) + 1);
		}
		return result;
	}

	/** 清空（测试用）。 */
	public static function reset():Void {
		behaviours = [];
		pruned = 0;
		failures = 0;
	}
	// #endregion
}
