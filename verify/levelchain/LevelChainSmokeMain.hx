// PORT-NOTE: 验证用（不参与游戏构建）。**关卡协程链路**的运行探针。
//
// 背景（本探针要钉住的两个真实阻断）：
//
//   ① 关卡场景树的协程没有任何人驱动。
//      Unity 由引擎推进**场景内全部** MonoBehaviour 的协程。移植层原先只有
//      `MainGameScene.behaviours`（手工 `new` + `attach` 的那批）被驱动，而
//      `ScenePrefabLoader.InstantiateScene("Level")` / `InstantiateInto` 是用
//      `GameObject.AddComponent` 建组件的 —— 这些组件不在任何 behaviours 表里。
//      于是 `LevelController` / `LevelBlueprintChooseController` 的过渡协程
//      （开场 GameStartTransition、选卡 BlueprintChosenTransition、相机移动、
//      失败结算 GameOverByEnemyTransition）在 start() 的第一段之后永远不再恢复。
//      修复：`unity.BehaviourRegistry`（登记点 = `GameObject.AddComponent`，
//      帧驱动 = `FlxG.signals.postUpdate`）。
//
//   ② `while (!inner.finished) co.waitFrames(1);`（工厂轮询）写法永久挂住。
//      重放模型下每次恢复都会重新调用工厂，拿到一个全新的、无人驱动的子协程，
//      循环条件永远为真。正确写法是 `co.waitCoroutine(inner)`。
//      本探针断言两种写法的**可观察差异**，防止有人改回去。
//
// 运行：bash HaxePort/tools_build/check_level_chain.sh          # 默认 cpp（与游戏同目标，**必须**）
//
// PORT-NOTE: neko 目标不可用 —— 本探针类型到 mvz2.level.LevelController（连带 mvz2.localization），
//   neko 代码生成期报 `Field hashing conflict GetLocalizedStringPlural and _id`（见 PORTING.md
//   §构建与验证；既有 check_scene.sh --neko 同样失败）。
// 运行期 cwd 用 HaxePort/（unity.Application.dataPath = "assets"，与游戏一致）。

package levelchain;

import mvz2.level.LevelController;
import mvz2.scenes.ScenePrefabLoader;
import unity.BehaviourRegistry;
import unity.Coroutine;
import unity.Coroutine.CoroutineContext;
import unity.GameObject;
import unity.MonoBehaviour;
import unity.UnityObject;

class LevelChainSmokeMain {
	static var checks:Int = 0;
	static var failures:Array<String> = [];

	static inline var DT:Float = 1 / 60;

	static function check(label:String, cond:Bool, detail:String = ""):Void {
		checks++;
		if (cond) {
			Sys.println('  [ok]   $label');
		} else {
			failures.push(label + (detail == "" ? "" : ' ($detail)'));
			Sys.println('  [FAIL] $label${detail == "" ? "" : " (" + detail + ")"}');
		}
	}

	static function eq(label:String, actual:Dynamic, expected:Dynamic):Void {
		check(label, actual == expected, 'actual=${Std.string(actual)} expected=${Std.string(expected)}');
	}

	public static function main():Void {
		Sys.println('[LevelChainSmoke] 关卡协程链路探针');
		Sys.println('dataPath=' + unity.Application.dataPath);

		testRegistryDrivesAddComponentBehaviour();
		testInactiveBehaviourNotDriven();
		testDestroyedBehaviourPruned();
		testLevelSceneTreeBehavioursRegistered();
		testWaitCoroutineTerminatesFactoryChild();
		testFactoryPollingLoopHangs();

		Sys.println('');
		if (failures.length == 0) {
			Sys.println('[LevelChainSmoke] 全部通过（$checks 项断言）');
			Sys.exit(0);
		}
		Sys.println('[LevelChainSmoke] 失败 ${failures.length} 项 / 共 $checks 项：');
		for (f in failures)
			Sys.println('  - $f');
		Sys.exit(1);
	}

	// ① 核心修复：AddComponent 建出来的组件，其协程会被 BehaviourRegistry 每帧推进。
	static function testRegistryDrivesAddComponentBehaviour():Void {
		Sys.println('');
		Sys.println('① AddComponent 组件的协程被帧驱动推进');

		var go = new GameObject("Level");
		var behaviour:SmokeBehaviour = go.AddComponent(SmokeBehaviour);
		check("AddComponent 成功", behaviour != null);
		check('组件已登记（实际 ${BehaviourRegistry.count}）', BehaviourRegistry.count >= 1);

		var routine = behaviour.startCounting(3);
		// PORT-NOTE: Unity 的 StartCoroutine 会**同步执行到第一个 yield**（`CoroutineRunner.start`
		//   刻意保持该语义），因此 start 之后循环已经跑完第一轮：steps == 1 且停在 waitFrames(1) 上。
		eq("start 后已执行挂起点之前的语句（同步跑到第一个 yield）", behaviour.steps, 1);
		check("start 后协程未结束（停在挂起点上）", !routine.finished);

		// PORT-NOTE: 剩余 2 轮各需要 1 次帧推进；但**第 3 次**推进才让循环条件失效、函数体返回
		//   （重放模型下「一次 update 只消耗一个挂起点」，见 unity/Coroutine.hx）：
		//   start 消耗第 1 个挂起点，之后每次 update 消耗一个，最后一次 update 越过循环末尾。
		for (_ in 0...3)
			BehaviourRegistry.step(DT);
		eq("帧推进后循环走完", behaviour.steps, 3);
		check("协程结束", routine.finished);
	}

	// ② 未激活对象上的协程不推进（Unity 语义）。
	static function testInactiveBehaviourNotDriven():Void {
		Sys.println('');
		Sys.println('② 未激活对象上的协程不推进');

		var go = new GameObject("Inactive");
		var behaviour:SmokeBehaviour = go.AddComponent(SmokeBehaviour);
		var routine = behaviour.startCounting(3);
		var stepsAfterStart = behaviour.steps;
		go.SetActive(false);

		for (_ in 0...5)
			BehaviourRegistry.step(DT);
		eq("未激活时不推进", behaviour.steps, stepsAfterStart);
		check("未激活时协程未结束", !routine.finished);

		go.SetActive(true);
		for (_ in 0...5)
			BehaviourRegistry.step(DT);
		eq("重新激活后继续推进到结束", behaviour.steps, 3);
		check("重新激活后协程结束", routine.finished);
	}

	// ③ 销毁后从登记表淘汰（反复进出关卡不会无限累积）。
	static function testDestroyedBehaviourPruned():Void {
		Sys.println('');
		Sys.println('③ 销毁的对象从登记表淘汰');

		var go = new GameObject("Disposable");
		var behaviour:SmokeBehaviour = go.AddComponent(SmokeBehaviour);
		behaviour.startCounting(1000);
		var before = BehaviourRegistry.count;
		var prunedBefore = BehaviourRegistry.pruned;

		UnityObject.destroy(go);
		BehaviourRegistry.step(DT);

		check('销毁后登记数下降（$before -> ${BehaviourRegistry.count}）',
			BehaviourRegistry.count < before);
		check("淘汰计数增加", BehaviourRegistry.pruned > prunedBefore);

		// 已销毁的组件不能再被推进。
		var stepsAfterDestroy = behaviour.steps;
		for (_ in 0...3)
			BehaviourRegistry.step(DT);
		eq("销毁后不再推进", behaviour.steps, stepsAfterDestroy);
	}

	/**
	 * ④ 真实关卡场景数据：用 ScenePrefabLoader 重建 Level 场景树，
	 *    断言根上有 LevelController，且**它的**协程会被帧驱动推进。
	 *
	 * PORT-NOTE: 这是「关卡能实例化并找到 LevelController」的直接证据，
	 * 同时也是 ① 在真实数据上的复现 —— LevelController 就是走 AddComponent 建出来的。
	 */
	static function testLevelSceneTreeBehavioursRegistered():Void {
		Sys.println('');
		Sys.println('④ 真实 Level 场景：实例化 + 找到 LevelController + 协程被驱动');

		var root = ScenePrefabLoader.InstantiateScene("Level", null, false);
		if (root == null) {
			check("Level 场景实例化（需先运行 tools_build/build_scene.py）", false);
			for (warning in ScenePrefabLoader.loadWarnings)
				Sys.println('    ' + warning);
			return;
		}
		check("Level 场景实例化", true);
		eq('场景根名 == "Level"', root.name, "Level");

		var controller = root.GetComponent(LevelController);
		check("场景根上能找到 LevelController", controller != null);
		if (controller == null)
			return;

		var registeredBefore = BehaviourRegistry.count;
		// 场景树里的 MonoBehaviour 应当已经全部登记（AddComponent 时登记）。
		check('场景树组件已登记（实际 $registeredBefore）', registeredBefore > 0);

		// PORT-NOTE: 关卡场景根在 prefab 数据里是**未激活**的（`Level.json` root `active=false`），
		//   这与 C# 一致 —— `LevelController.InitLevel` 会 `SetActive(true)`，
		//   `LevelManager.GotoLevelSceneAsync` 拿到控制器后也会 `SetActive(false)` 等 InitLevel。
		//   因此这里必须先激活，协程才会被帧驱动（未激活对象上的协程不推进，见 ②）。
		eq("关卡场景根初始为未激活（与 prefab 数据一致）", root.active, false);
		root.SetActive(true);

		// 在真实的 LevelController 上启动一个协程，确认帧驱动真的会推进它。
		// PORT-NOTE: 不调用真实的过渡协程（它们依赖已初始化的 LevelEngine / 管理器），
		// 这里只验证「关卡组件上的协程会被推进」这一机制。
		var probe:ProbeBehaviour = root.AddComponent(ProbeBehaviour);
		var routine = probe.startCounting(2);
		eq("协程同步跑到第一个 yield", probe.steps, 1);

		for (_ in 0...2)
			BehaviourRegistry.step(DT);
		eq("帧推进后该协程走完", probe.steps, 2);
		check("协程结束", routine.finished);

		Sys.println('    登记组件类型数=${Lambda.count(BehaviourRegistry.classCounts())}'
			+ ' 已登记=${BehaviourRegistry.count} 活跃=${BehaviourRegistry.activeCount}');
	}

	// ⑤ 正确写法：co.waitCoroutine(工厂()) 会驱动子协程并正常结束。
	static function testWaitCoroutineTerminatesFactoryChild():Void {
		Sys.println('');
		Sys.println('⑤ co.waitCoroutine(工厂()) 正常结束');

		var go = new GameObject("WaitCoroutine");
		var behaviour:SmokeBehaviour = go.AddComponent(SmokeBehaviour);
		var done = behaviour.startWaitCoroutineChild(2);

		for (_ in 0...200)
			BehaviourRegistry.step(DT);
		check("父协程结束（子协程被驱动）", done.finished);
	}

	// ⑥ 错误写法：工厂轮询循环在重放模型下**不会**结束（钉住已知限制）。
	static function testFactoryPollingLoopHangs():Void {
		Sys.println('');
		Sys.println('⑥ 工厂轮询写法仍然挂住（已知限制，调用点已改用 waitCoroutine）');

		var go = new GameObject("FactoryPolling");
		var behaviour:SmokeBehaviour = go.AddComponent(SmokeBehaviour);
		var routine = behaviour.startFactoryPollingChild();

		for (_ in 0...200)
			BehaviourRegistry.step(DT);
		check("工厂轮询写法不会结束（这正是被修掉的写法）", !routine.finished,
			'finished=${routine.finished}');
	}
}

/**
 * 探针用的 MonoBehaviour：进度用「幂等写入 + 局部累计量」度量
 * （重放模型下非幂等自增会被重复执行，不能作为进度，见 unity/Coroutine.hx）。
 */
class SmokeBehaviour extends MonoBehaviour {
	/** 已完成的循环步数（幂等写入）。 */
	public var steps:Int = 0;

	public function new() {
		super();
	}

	/** 每帧推进 1 步、共 count 步后结束。 */
	public function startCounting(count:Int):Coroutine {
		return StartCoroutine(Coroutine.create(function(co:CoroutineContext) {
			var i = 0;
			while (i < count) {
				i++;
				steps = i;
				co.waitFrames(1);
			}
		}));
	}

	/** 正确写法：等待一个由工厂产出的子协程。 */
	public function startWaitCoroutineChild(childSteps:Int):Coroutine {
		return StartCoroutine(Coroutine.create(function(co:CoroutineContext) {
			co.waitCoroutine(makeChild(childSteps));
		}));
	}

	/** 错误写法（被修掉的形状）：工厂轮询 + 轮询 `.finished`。 */
	public function startFactoryPollingChild():Coroutine {
		return StartCoroutine(Coroutine.create(function(co:CoroutineContext) {
			var inner = makeChild(2);
			while (inner != null && !inner.finished) {
				co.waitFrames(1);
			}
			steps = 999;
		}));
	}

	private function makeChild(count:Int):Coroutine {
		return Coroutine.create(function(co:CoroutineContext) {
			var i = 0;
			while (i < count) {
				i++;
				co.waitFrames(1);
			}
		});
	}
}

/** 挂在真实 Level 场景根上的探针组件（与 SmokeBehaviour 同类，名字区分便于日志定位）。 */
class ProbeBehaviour extends SmokeBehaviour {
	public function new() {
		super();
	}
}
