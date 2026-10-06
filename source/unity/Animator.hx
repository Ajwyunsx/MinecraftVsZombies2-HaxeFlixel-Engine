package unity;

import flixel.FlxSprite;
import flixel.animation.FlxAnimationController;
import mvz2.animations.AnimatorManifestLoader;
import mvz2.animations.AnimatorRuntime;

// Minimal UnityEngine.Animator shim, backed by flixel.animation.FlxAnimationController.
// PORT-NOTE: Unity 的 Animator 状态机/参数由游戏逻辑自行驱动，这里只保留动画播放与参数存储。
//
// PORT-NOTE（2026-10-05 工作包③）：**动画事件链路**是本移植的关键路径 —— Splash 页推进到标题页
// 靠的就是 `splash.anim` 在 2.5 s 处的事件 `EnterTitleScreen`（见 build_anim.py 的说明）。
// 因此本 shim 现在把状态机/曲线/事件交给 `mvz2.animations.AnimatorRuntime`：
//   * `runtimeAnimatorController` 由 `ScenePrefabFieldApplier` 写成**数据 key**
//     （如 "Animation/Init/Splash/splash.controller"），赋值即绑定（见 set_runtimeAnimatorController）；
//   * `Update(dt)` 交给 runtime 推进（含触发动画事件）；
//   * 参数读写走 runtime 的参数表，`Model` 的序列化恢复（`Animator.parameters` 遍历）保持兼容。
class Animator extends Behaviour {
	public var controller:FlxAnimationController;
	// PORT-NOTE: Unity 中 Animator 继承 Behaviour（enabled / isActiveAndEnabled 来自 Behaviour），
	// 补全 Unity 的 runtimeAnimatorController。
	// 移植层里这个字段是**数据 key 字符串**（"Animation/.../x.controller"）或
	// `unity.RuntimeAnimatorController` 实例；赋值时由 runtime 加载对应 controller 数据。
	public var runtimeAnimatorController(get, set):Dynamic;
	function get_runtimeAnimatorController():Dynamic return _runtimeAnimatorController;
	function set_runtimeAnimatorController(value:Dynamic):Dynamic {
		_runtimeAnimatorController = value;
		// PORT-NOTE: 赋 controller 即绑定（Unity 的同一语义：Animator 在 controller 被赋值时
		// 重置到默认状态与参数默认值）。字符串 = 数据 key；其它值（RuntimeAnimatorController
		// shim 实例）没有数据来源，按「无 controller」处理。
		if (Std.isOfType(value, String))
			bindController(cast value);
		else
			bindController(null);
		return value;
	}
	private var _runtimeAnimatorController:Dynamic = null;
	public var logWarnings:Bool = true;
	public var applyRootMotion:Bool = false;
	public var speed:Float = 1;

	// PORT-NOTE: C# 的 Animator.parameters 为公开属性，这里改为 public。
	public var parameters:Map<String, Dynamic> = new Map();

	public function new() {
		super();
	}

	// PORT-NOTE: 对应 UnityEngine.Animator.StringToHash。Haxe 的 String 没有 hashCode，
	// 这里用稳定的 FNV-1a 实现，保证同名参数得到同一个 Int，供 AnimatorStateInfo.IsName 比较。
	public static function StringToHash(str:String):Int {
		if (str == null)
			return 0;
		var hash:Int = 0x811C9DC5;
		for (i in 0...str.length) {
			hash = (hash ^ str.charCodeAt(i)) * 0x01000193;
		}
		return hash;
	}

	// 绑定实际驱动动画的 FlxSprite（Unity 中由同一个 GameObject 上的组件决定）。
	public function SetTarget(sprite:FlxSprite):Void {
		controller = sprite != null ? sprite.animation : null;
	}

	// #region 状态机运行期（工作包③）
	/** 绑定 controller 数据（null = 解绑）。由 `runtimeAnimatorController` 的 setter 调用。 */
	private function bindController(key:String):Void {
		if (runtime == null)
			runtime = new AnimatorRuntime(this);
		runtime.SetController(key);
	}
	/** 数据驱动的动画状态机；未绑定 controller 时为 null。 */
	public var runtime(default, null):AnimatorRuntime;
	/** 是否已绑定可用的 controller 数据（诊断用）。 */
	public function HasController():Bool return runtime != null && runtime.HasController();
	// #endregion

	public function Play(name:String, ?layer:Int = -1, ?normalizedTime:Float = 0):Void {
		if (controller == null)
			return; // TODO-PORT: 未绑定 FlxSprite 时无动画控制器。
		controller.play(name, true);
	}
	public function Stop():Void {
		if (controller != null)
			controller.stop();
	}
	public function GetCurrentAnimationName():String {
		if (runtime != null && runtime.HasController())
			return runtime.GetCurrentAnimationName();
		if (controller == null || controller.curAnim == null)
			return "";
		return controller.name;
	}
	public function IsPlaying():Bool {
		if (runtime != null && runtime.HasController())
			return runtime.IsPlaying();
		return controller != null && controller.curAnim != null && !controller.paused;
	}
	public function SetPaused(value:Bool):Void {
		if (controller != null)
			controller.paused = value;
	}

	// PORT-NOTE: 补全 Animator 的 Layer 相关 API（Unity 动画层）；
	// 移植层只保留单层，因此按名字记录权重。
	public var layerCount(get, never):Int;
	function get_layerCount():Int return 1;
	private var layerWeights:Map<String, Float> = new Map();
	public function GetLayerIndex(layerName:String):Int return layerName == null ? -1 : 0;
	public function GetLayerWeight(layerIndex:Int):Float {
		return layerWeights.exists(Std.string(layerIndex)) ? layerWeights.get(Std.string(layerIndex)) : 1;
	}
	public function SetLayerWeight(layerIndex:Int, weight:Float):Void {
		layerWeights.set(Std.string(layerIndex), weight);
	}
	public function GetCurrentAnimatorStateInfo(layerIndex:Int):AnimatorStateInfo {
		var info = new AnimatorStateInfo();
		info.fullPathHash = StringToHash(GetCurrentAnimationName());
		info.shortNameHash = info.fullPathHash;
		return info;
	}

	// PORT-NOTE: 补全 Unity Animator 的 hash 播放/切换 API（Model 的序列化恢复需要）。
	public function GetNextAnimatorStateInfo(layerIndex:Int):AnimatorStateInfo {
		var info = new AnimatorStateInfo();
		info.fullPathHash = StringToHash(GetCurrentAnimationName());
		info.shortNameHash = info.fullPathHash;
		return info;
	}
	public function GetAnimatorTransitionInfo(layerIndex:Int):AnimatorTransitionInfo {
		return new AnimatorTransitionInfo();
	}
	public function PlayHash(stateNameHash:Int, layer:Int = -1, normalizedTime:Float = 0):Void {
		Play(GetCurrentAnimationName(), layer, normalizedTime);
	}
	public function CrossFadeInFixedTime(stateHashName:Int, transitionDuration:Float, layer:Int = -1, fixedTime:Float = 0, normalizedTime:Float = 0):Void {}
	public function CrossFadeHash(stateHashName:Int, transitionDuration:Float, layer:Int = -1, normalizedTime:Float = 0, transitionOffset:Float = 0):Void {}
	public function Update(deltaTime:Float):Void {
		// PORT-NOTE: Unity 在 `enabled=true` 时由引擎每帧推进 Animator。移植层没有引擎，
		// 由场景（`MainGameScene` 的 updateSteps / `MainSceneController.Update`）显式调用本方法；
		// 有 controller 数据时交给 `AnimatorRuntime` 推进（含**触发动画事件**）。
		if (runtime != null && runtime.HasController())
			runtime.Update(deltaTime);
	}

	// PORT-NOTE: 参数读写同时更新本地表（`parameters`，`Model.SerializableAnimator` 的序列化读它）
	// 与运行期状态机（`runtime`）。二者都写是为了保持向后兼容：
	// `mvz2.models.Model` 的 `for (para in animator.parameters)` 遍历的是**值**（Haxe 的 Map 迭代
	// 语义），而值只有 Bool/Float/Int，`para.name` 恒为 null —— 这是 Model.hx 侧的既有缺陷，
	// 不在本工作包范围（已记入 tools_build/scene_inject_findings.md 的跨域清单）。
	public function SetBool(name:String, value:Bool):Void {
		parameters.set(name, value);
		if (runtime != null)
			runtime.SetBool(name, value);
	}
	public function GetBool(name:String):Bool {
		if (runtime != null && runtime.HasController())
			return runtime.GetBool(name);
		return parameters.exists(name) ? cast(parameters.get(name), Bool) : false;
	}
	public function SetFloat(name:String, value:Float):Void {
		parameters.set(name, value);
		if (runtime != null)
			runtime.SetFloat(name, value);
	}
	public function GetFloat(name:String):Float {
		if (runtime != null && runtime.HasController())
			return runtime.GetFloat(name);
		return parameters.exists(name) ? cast(parameters.get(name), Float) : 0;
	}
	public function SetInteger(name:String, value:Int):Void {
		parameters.set(name, value);
		if (runtime != null)
			runtime.SetInteger(name, value);
	}
	public function GetInteger(name:String):Int {
		if (runtime != null && runtime.HasController())
			return runtime.GetInteger(name);
		return parameters.exists(name) ? cast(parameters.get(name), Int) : 0;
	}
	public function SetTrigger(name:String):Void {
		parameters.set(name, true);
		if (runtime != null)
			runtime.SetTrigger(name);
	}
	public function ResetTrigger(name:String):Void {
		parameters.set(name, false);
		if (runtime != null)
			runtime.ResetTrigger(name);
	}
}
