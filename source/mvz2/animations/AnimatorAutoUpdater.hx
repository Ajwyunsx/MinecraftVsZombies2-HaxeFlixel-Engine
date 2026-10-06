// Ported from: (新增文件) 场景级的 Animator 自动推进
package mvz2.animations;

import mvz2.states.BootTrace;
import unity.Animator;
import unity.Debug;
import unity.GameObject;
import unity.Transform;

/**
 * 场景级的 Animator 自动推进（对应 Unity「引擎每帧推进所有 enabled 的 Animator」）。
 *
 * PORT-NOTE: 移植层没有引擎，`MainGameScene.update()` 只驱动 MonoBehaviour 的协程与显式登记的
 * `updateSteps`，Animator 不在其中 —— 于是 Splash 页的 `Animator` 永远不会播放，
 * `splash.anim` 的 `EnterTitleScreen` 事件也永远不会触发（这正是**黑屏卡在 Splash 的根因**）。
 * 本类在场景构建时登记全部 Animator（含 prefab 注入后新建出来的），每帧按 Unity 语义推进：
 * `enabled && gameObject.activeInHierarchy`。
 *
 * 显式 `animator.Update(dt)` 的调用点（`LevelController.UpdateEntityAnimators` 等）不受影响：
 * 它们先 `enabled=false` 再手动 Update，本类会因为 `enabled=false` 跳过，语义与 Unity 一致。
 */
class AnimatorAutoUpdater {
	public function new() {}

	/** 登记一个 Animator（重复登记会被忽略）。 */
	public function add(animator:Animator):Void {
		if (animator == null || animators.indexOf(animator) >= 0)
			return;
		animators.push(animator);
	}

	/**
	 * 递归登记一棵子树里的全部 Animator（prefab 注入后调用）。
	 *
	 * PORT-NOTE: 显式按 `transform.children` 走，**不看激活状态**。原因是页面根在
	 * `MainGameScene.page()` 里被 `SetActive(false)`（由 `MainSceneController.DisplayPage`
	 * 切换），而 `GameObject.GetComponentsInChildren` 的 `includeInactive=false` 分支会跳过
	 * 未激活子树（`unity/GameObject.hx:61`）—— 漏掉它们等于 Splash 的 Animator 永远不推进。
	 *
	 * 另一个**同样重要**的点是调用时机：必须在 `InjectPagePrefab` 里对**每个页面根**调用一次，
	 * 不能只在 `MainGameScene.build()` 末尾对 `root` 调一次。实测（21:23 产物）：
	 * 只在末尾调时登记到 8 个，改为在注入点逐页调 + 末尾兜底后是 43 个。
	 * 末尾那次兜底保留，用于覆盖不经 `InjectPagePrefab` 的对象（如手工建的管理器子树）。
	 */
	public function addTree(root:GameObject):Void {
		if (root == null)
			return;
		walk(root.transform);
	}

	private function walk(transform:Transform):Void {
		if (transform == null)
			return;
		var go = transform.gameObject;
		if (go != null) {
			for (comp in go.GetAllComponents()) {
				if (Std.isOfType(comp, Animator))
					add(cast comp);
			}
		}
		for (child in transform.children)
			walk(child);
	}

	/** 已登记但未绑定 controller 数据的 Animator 数（诊断用）。 */
	public var unboundCount(get, never):Int;
	function get_unboundCount():Int {
		var n = 0;
		for (animator in animators)
			if (animator.runtime == null || !animator.runtime.HasController())
				n++;
		return n;
	}

	public function update(elapsed:Float):Void {
		frames++;
		// PORT-NOTE: 诊断 —— 启动后第 1 帧与第 600 帧各落盘一次「登记/启用/激活/已绑定」四项计数，
		// 用来区分「Animator 没登记」「对象未激活」「controller 未绑定」「时间没推进」这四类原因
		//（lime 的 Windows GUI 程序没有 stdout，只能写 boot-trace）。
		// 这组计数正是本轮定位「Splash 页不推进」的关键证据（第 1 帧 Splash 激活 → 第 200 帧已切到
		// Titlescreen），保留下来供后续页面推进问题排查。
		if (frames == 1 || frames == 600) {
			BootTrace.step('Animator 推进第 $frames 帧：登记 ${animators.length}'
				+ '，enabled=${countEnabled()}，activeInHierarchy=${countActive()}'
				+ '，已绑定 controller=${animators.length - unboundCount}');
		}
		for (animator in animators) {
			if (animator == null || !animator.enabled)
				continue;
			if (animator.gameObject == null || !animator.gameObject.activeInHierarchy)
				continue;
			if (animator.runtime == null || !animator.runtime.HasController())
				continue;
			try {
				animator.runtime.Update(elapsed);
			} catch (e:Dynamic) {
				// PORT-NOTE: Unity 里动画状态机里的异常由引擎记录后继续（不中断其它 Animator）。
				BootTrace.error('Animator 更新失败（${animator.gameObject.name}）：${Std.string(e)}');
				Debug.LogError('[AnimatorAutoUpdater] ${animator.gameObject.name} 更新失败：$e');
			}
		}
	}

	private function countEnabled():Int {
		var n = 0;
		for (animator in animators)
			if (animator != null && animator.enabled)
				n++;
		return n;
	}

	private function countActive():Int {
		var n = 0;
		for (animator in animators)
			if (animator != null && animator.gameObject != null && animator.gameObject.activeInHierarchy)
				n++;
		return n;
	}

	private var frames:Int = 0;

	/** 已登记的 Animator 数（诊断用）。 */
	public var count(get, never):Int;
	function get_count():Int return animators.length;

	private var animators:Array<Animator> = [];
}
