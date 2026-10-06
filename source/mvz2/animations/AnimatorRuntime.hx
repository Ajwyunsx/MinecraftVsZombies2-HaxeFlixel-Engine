// Ported from: (新增文件) 运行期动画状态机（Unity Animator 的等价实现）
package mvz2.animations;

import mvz2.animations.AnimData;
import mvz2.states.BootTrace;
import unity.Animator;
import unity.AnimatorStateInfo;
import unity.Component;
import unity.Debug;
import unity.GameObject;
import unity.MonoBehaviour;
import unity.Transform;
import unity.UnityObject;
import unity.Vector3;

// PORT-NOTE: 本文件是移植层新增的「动画状态机运行期」，没有 C# 对应源码。
//
// Unity 的 `Animator` 由引擎驱动：每帧推进当前状态的时间，对 clip 的每条曲线求值并写回
// 目标对象的字段，并在关键帧事件（`m_Events`）处对该 GameObject 调用同名方法
// （`SendMessage` 语义）。移植层没有引擎，这里实现等价的最小版本：
//
//   1. **状态机**：按 `AnimatorControllerFile` 的层/状态机/状态/转移推进。条件比较支持
//      Unity 的 m_ConditionMode（If/IfNot/Greater/Less/Equals/NotEqual）；
//      `hasExitTime` 转移在 normalizedTime 越过 exitTime 时触发。
//   2. **曲线求值**：线性插值（贝塞尔切线不导出，见 build_anim.py 的 PORT-NOTE），
//      按 (path, classID, attribute) 定位目标组件并写字段。
//   3. **动画事件**：时间跨过事件时刻时，对**动画根 GameObject**（Unity 的 SendMessage
//      默认只发给调用 Animator 的那个 GameObject）调用同名方法，并传 data/float/int。
//      这一步是 Splash → Titlescreen、Mainmenu.Init 等页面推进的**唯一途径**。
//
// 与 Unity 的差异（PORT-NOTE）：
//   * BlendTree 按「第一个子 clip」近似（`build_anim.py` 已说明），不做真实混合；
//   * 层权重只用于记录，不做多层的实际混合；
//   * `Animator.Update()` 被显式调用时推进（Unity 里 `enabled=true` 时引擎自动推进）。
class AnimatorRuntime {
	/** 一个运行期状态机实例（对应一个 Animator 组件）。 */
	public function new(animator:Animator) {
		this.animator = animator;
	}

	/**
	 * 绑定 controller 数据（等价于给 Animator 赋 runtimeAnimatorController）。
	 * 会重置到每层的默认状态与参数默认值（Unity 的同一行为）。
	 */
	public function SetController(key:String):Bool {
		controllerKey = key;
		controller = key == null ? null : AnimatorManifestLoader.LoadController(key);
		layerStates = [];
		layerTimes = [];
		if (controller == null)
			return false;
		// 参数默认值（Unity 在 controller 绑定时用 m_Default* 初始化）。
		parameters = new Map();
		for (parameter in controller.parameters) {
			switch (parameter.type) {
				case 1: parameters.set(parameter.name, parameter.defaultFloat);
				case 3: parameters.set(parameter.name, parameter.defaultInt);
				case 4, 9: parameters.set(parameter.name, parameter.defaultBool);
				default: parameters.set(parameter.name, parameter.defaultFloat);
			}
		}
		// 每层进入默认状态。
		for (i in 0...controller.layers.length) {
			var layer = controller.layers[i];
			var machine = getMachine(layer.machine);
			var defaultState = machine != null ? machine.defaultState : null;
			layerStates.push(defaultState);
			layerTimes.push(0);
		}
		return true;
	}

	/**
	 * 推进 dt 秒（对应 `Animator.Update(dt)`）。
	 *
	 * PORT-NOTE: **不检查 `animator.enabled`** —— Unity 里 `enabled=false` 只关掉「引擎自动推进」，
	 * 显式调 `Update()` 仍然生效。C# 里正好有这种用法：`LevelController.UpdateEntityAnimators`
	 * 先 `animator.enabled = false` 再 `animator.Update(dt * speed)`（限流更新），
	 * 若在这里判 enabled 会让关卡里所有模型动画停摆。
	 * 自动推进由 `AnimatorAutoUpdater`（见本文件底部）按 `enabled` 过滤。
	 */
	public function Update(deltaTime:Float):Void {
		if (controller == null)
			return;
		for (i in 0...layerStates.length) {
			updateLayer(i, deltaTime);
		}
	}

	private function updateLayer(layerIndex:Int, deltaTime:Float):Void {
		if (layerIndex >= controller.layers.length)
			return;
		var layer = controller.layers[layerIndex];
		var machine = getMachine(layer.machine);
		if (machine == null)
			return;

		// 1) 任意状态转移优先（Unity 的 AnyStateTransitions）。
		var any = evaluateTransitions(machine.anyTransitions, null, 0);
		if (any != null) {
			enterState(layerIndex, any);
			return;
		}

		var stateId = layerStates[layerIndex];
		var state = getState(stateId);
		if (state == null) {
			// 默认状态缺失时不做任何事（与 Unity 空状态机一致）。
			return;
		}
		var clip = state.clip == null ? null : AnimatorManifestLoader.LoadClip(state.clip);
		var length = clip != null ? clip.length : 0;

		// 2) 当前状态的转移检查（条件 + hasExitTime）。
		var time = layerTimes[layerIndex];
		var normalized = length > 0 ? time / length : 0;
		var next = evaluateTransitions(state.transitions, stateId, normalized);
		if (next != null) {
			enterState(layerIndex, next);
			return;
		}

		// 3) 推进时间 + 触发事件 + 求值曲线。
		var previous = time;
		time += deltaTime * state.speed;
		layerTimes[layerIndex] = time;
		if (clip != null) {
			fireEvents(clip, previous, time);
			applyCurves(clip, time);
		}
	}

	/** 从当前状态评估一组转移，返回命中的目标状态 fileID（无命中返回 null）。 */
	private function evaluateTransitions(transitionIds:Array<String>, fromStateId:Null<String>, normalized:Float):Null<String> {
		if (transitionIds == null)
			return null;
		for (transitionId in transitionIds) {
			var transition = getTransition(transitionId);
			if (transition == null || transition.dst == null)
				continue;
			if (!conditionsMet(transition))
				continue;
			// hasExitTime：需要播放到 exitTime 之后（Unity 的退出时间语义）。
			if (transition.hasExitTime && normalized < transition.exitTime)
				continue;
			// 无条件的转移必须靠 hasExitTime 触发；否则会每帧自转（Unity 同样要求二者之一）。
			if (transition.conditions.length == 0 && !transition.hasExitTime)
				continue;
			return transition.dst;
		}
		return null;
	}

	private function conditionsMet(transition:AnimTransition):Bool {
		// PORT-NOTE: `condition` 是 Haxe 关键字（switch 的 case 子句），循环变量改名 `cond`。
		for (cond in transition.conditions) {
			var value:Dynamic = parameters.exists(cond.event) ? parameters.get(cond.event) : null;
			if (value == null)
				return false;
			var ok = false;
			switch (cond.mode) {
				case 1: // If（布尔真）
					ok = toBool(value);
				case 2: // IfNot
					ok = !toBool(value);
				case 3: // Greater
					ok = toFloat(value) > cond.threshold;
				case 4: // Less
					ok = toFloat(value) < cond.threshold;
				case 6: // Equals
					ok = toFloat(value) == cond.threshold;
				case 7: // NotEqual
					ok = toFloat(value) != cond.threshold;
				default:
					ok = toBool(value);
			}
			if (!ok)
				return false;
		}
		return true;
	}

	private function enterState(layerIndex:Int, stateId:String):Void {
		layerStates[layerIndex] = stateId;
		layerTimes[layerIndex] = 0;
		// PORT-NOTE: Unity 在进入状态时对 StateMachineBehaviour 调 OnStateEnter。
		// 移植层只有 3 个 behaviour 类（AutoDestroy/AutoDisable/ReadySetBuild），它们都只用 OnStateExit，
		// 因此这里不派发 OnStateEnter（避免空实现带来的误导）。
	}

	/**
	 * 触发 clip 里 [previous, current) 区间内的事件（Unity 在关键帧处调用同名方法）。
	 *
	 * PORT-NOTE: 用 `Reflect.field` + `callMethod` 而不是 `GameObject.SendMessage`——
	 * 移植层没有 SendMessage（Unity 的 C# 反射版），而且这批事件目标都是同一 GameObject 上的
	 * 已移植组件（`SplashController.EnterTitleScreen`、`MainmenuController.Init`、
	 * `ChapterTransitionController.CallEnd`、`SoundPlayer.Play2D`…），反射调用语义等价。
	 */
	private function fireEvents(clip:AnimClipFile, previous:Float, current:Float):Void {
		if (clip.events == null || clip.events.length == 0)
			return;
		for (event in clip.events) {
			if (event.time <= previous || event.time > current)
				continue;
			invokeEvent(event);
		}
	}

	private function invokeEvent(event:AnimEvent):Void {
		var target:GameObject = animator.gameObject;
		if (target == null)
			return;
		// PORT-NOTE: `component` 是 Haxe 关键字，循环变量改名 `comp`。
		for (comp in target.GetAllComponents()) {
			var fn = Reflect.field(comp, event.functionName);
			if (fn == null || !Reflect.isFunction(fn))
				continue;
			try {
				Reflect.callMethod(comp, fn, []);
			} catch (e:Dynamic) {
				// PORT-NOTE: Unity 里动画事件里抛的异常由引擎记录后继续播放（不中断其它组件）。
				// 移植层保持同样的容错，并把组件类型带进日志便于定位。
				Debug.LogError('[AnimatorRuntime] ${Type.getClassName(Type.getClass(comp))}.${event.functionName} 抛出异常：$e');
			}
			return;
		}
		// 找不到方法时与 Unity 的 SendMessage 一致：记一条告警（Unity 会报
		// "has no receiver"），但不中断。
		if (warnMissingEvents)
			Debug.LogWarning('[AnimatorRuntime] ${target.name} 上没有动画事件方法 "${event.functionName}"（clip=${clipNameForLog}）');
	}

	/** 对 clip 的所有曲线求值并写回目标字段。 */
	private function applyCurves(clip:AnimClipFile, time:Float):Void {
		// PORT-NOTE: `curve` 是 Haxe 关键字（用于结构体类型的简写），循环变量改名 `c`。
		for (c in clip.curves) {
			var value = sampleCurve(c, time);
			if (value == null)
				continue;
			writeCurve(c, value);
		}
	}

	/** 线性插值求值（贝塞尔切线不导出，见 build_anim.py 的 PORT-NOTE）。 */
	private static function sampleCurve(curve:AnimCurve, time:Float):Null<Float> {
		var keys = curve.keys;
		if (keys == null || keys.length == 0)
			return null;
		if (time <= keys[0][0])
			return keys[0][1];
		var last = keys[keys.length - 1];
		if (time >= last[0])
			return last[1];
		for (i in 0...keys.length - 1) {
			var a = keys[i];
			var b = keys[i + 1];
			if (time < a[0] || time > b[0])
				continue;
			var span = b[0] - a[0];
			if (span <= 0)
				return b[1];
			var t = (time - a[0]) / span;
			return a[1] + (b[1] - a[1]) * t;
		}
		return last[1];
	}

	/** 把一条曲线的值写到 (path, classID, attribute) 定位的目标字段上。 */
	private function writeCurve(curve:AnimCurve, value:Float):Void {
		var target = findTarget(curve);
		if (target == null)
			return;
		var attribute = curve.attribute;
		switch (curve.classID) {
			case 1: // GameObject.m_IsActive
				if (attribute == "m_IsActive")
					target.SetActive(value != 0);
			case 4: // Transform
				writeTransform(target.transform, attribute, value);
			case 224: // RectTransform
				writeRectTransform(target.transform, attribute, value);
			case 212: // SpriteRenderer
				writeSpriteRenderer(target, attribute, value);
			case 225: // CanvasGroup.m_Alpha
				if (attribute == "m_Alpha") {
					var group = target.GetComponent(unity.CanvasGroup);
					if (group != null)
						group.alpha = value;
				}
			default:
				// 114（MonoBehaviour 自定义字段）/ 198（ParticleSystem）等：按字段名反射写入。
				writeByReflection(target, curve, value);
		}
	}

	private static function writeTransform(transform:Transform, attribute:String, value:Float):Void {
		if (transform == null)
			return;
		switch (attribute) {
			case "m_LocalPosition.x":
				transform.localPosition = new Vector3(value, transform.localPosition.y, transform.localPosition.z);
			case "m_LocalPosition.y":
				transform.localPosition = new Vector3(transform.localPosition.x, value, transform.localPosition.z);
			case "m_LocalPosition.z":
				transform.localPosition = new Vector3(transform.localPosition.x, transform.localPosition.y, value);
			case "m_LocalScale.x":
				transform.localScale = new Vector3(value, transform.localScale.y, transform.localScale.z);
			case "m_LocalScale.y":
				transform.localScale = new Vector3(transform.localScale.x, value, transform.localScale.z);
			case "m_LocalScale.z":
				transform.localScale = new Vector3(transform.localScale.x, transform.localScale.y, value);
			case "localEulerAnglesRaw.x", "m_LocalEulerAngles.x":
				var e = transform.localEulerAngles;
				transform.localEulerAngles = new Vector3(value, e.y, e.z);
			case "localEulerAnglesRaw.y", "m_LocalEulerAngles.y":
				var e = transform.localEulerAngles;
				transform.localEulerAngles = new Vector3(e.x, value, e.z);
			case "localEulerAnglesRaw.z", "m_LocalEulerAngles.z":
				var e = transform.localEulerAngles;
				transform.localEulerAngles = new Vector3(e.x, e.y, value);
			default:
		}
	}

	private static function writeRectTransform(transform:Transform, attribute:String, value:Float):Void {
		var rect = Std.isOfType(transform, unity.RectTransform) ? cast(transform, unity.RectTransform) : null;
		if (rect == null)
			return;
		switch (attribute) {
			case "m_AnchoredPosition.x":
				rect.anchoredPosition = new unity.Vector2(value, rect.anchoredPosition.y);
			case "m_AnchoredPosition.y":
				rect.anchoredPosition = new unity.Vector2(rect.anchoredPosition.x, value);
			case "m_SizeDelta.x":
				rect.sizeDelta = new unity.Vector2(value, rect.sizeDelta.y);
			case "m_SizeDelta.y":
				rect.sizeDelta = new unity.Vector2(rect.sizeDelta.x, value);
			case "m_AnchorMin.x":
				rect.anchorMin = new unity.Vector2(value, rect.anchorMin.y);
			case "m_AnchorMin.y":
				rect.anchorMin = new unity.Vector2(rect.anchorMin.x, value);
			case "m_AnchorMax.x":
				rect.anchorMax = new unity.Vector2(value, rect.anchorMax.y);
			case "m_AnchorMax.y":
				rect.anchorMax = new unity.Vector2(rect.anchorMax.x, value);
			case "m_Pivot.x":
				rect.pivot = new unity.Vector2(value, rect.pivot.y);
			case "m_Pivot.y":
				rect.pivot = new unity.Vector2(rect.pivot.x, value);
			default:
				writeTransform(transform, attribute, value);
		}
	}

	private static function writeSpriteRenderer(target:GameObject, attribute:String, value:Float):Void {
		var renderer = target.GetComponent(unity.SpriteRenderer);
		if (renderer == null)
			return;
		switch (attribute) {
			case "m_FlipX":
				renderer.flipX = value != 0;
			case "m_SortingOrder":
				renderer.sortingOrder = Std.int(value);
			case "m_Color.a":
				var c = renderer.color;
				renderer.color = new unity.Color(c.r, c.g, c.b, value);
			case "m_Color.r":
				var c = renderer.color;
				renderer.color = new unity.Color(value, c.g, c.b, c.a);
			case "m_Color.g":
				var c = renderer.color;
				renderer.color = new unity.Color(c.r, value, c.b, c.a);
			case "m_Color.b":
				var c = renderer.color;
				renderer.color = new unity.Color(c.r, c.g, value, c.a);
			default:
		}
	}

	/**
	 * classID 114（MonoBehaviour 自定义字段）等：按字段名反射写入。
	 *
	 * PORT-NOTE: Unity 的曲线 attribute 就是 C# 字段名（如 `hue`、`titleBlur`、`enableB`）。
	 * 移植层的 shim 里同名 private 字段在 hxcpp 上 `Reflect.setField` 可以写入
	 * （见 ScenePrefabFieldApplier 的同一处理）；写不进去时静默跳过（不影响主流程）。
	 */
	private static function writeByReflection(target:GameObject, curve:AnimCurve, value:Float):Void {
		var attribute = curve.attribute;
		// PORT-NOTE: `component` 是 Haxe 关键字，循环变量改名 `comp`。
		for (comp in target.GetAllComponents()) {
			if (comp == null)
				continue;
			if (curve.script != null && !scriptMatches(comp, curve.script))
				continue;
			var setter = Reflect.field(comp, "set_" + attribute);
			if (setter != null && Reflect.isFunction(setter)) {
				try {
					Reflect.callMethod(comp, setter, [value]);
				} catch (e:Dynamic) {}
				return;
			}
			var current:Dynamic = Reflect.field(comp, attribute);
			if (current == null)
				continue;
			try {
				Reflect.setField(comp, attribute, value);
			} catch (e:Dynamic) {}
			return;
		}
	}

	/** 曲线带的 script guid 是否能对上组件类型（只用于缩小反射写入的范围）。 */
	private static function scriptMatches(component:Component, guid:String):Bool {
		var cls = Type.getClass(component);
		if (cls == null)
			return false;
		return ScriptGuidMap.matches(cls, guid);
	}

	/** 按曲线路径定位 GameObject（相对动画根，Unity 的 `Transform.Find` 语义）。 */
	private function findTarget(curve:AnimCurve):Null<GameObject> {
		if (animator == null || animator.gameObject == null)
			return null;
		var path = curve.path;
		if (path == null || path.length == 0)
			return animator.gameObject;
		var current = animator.gameObject.transform;
		for (part in path.split("/")) {
			if (part.length == 0)
				continue;
			var next:Transform = null;
			for (child in current.children) {
				if (child.gameObject != null && child.gameObject.name == part) {
					next = child;
					break;
				}
			}
			if (next == null)
				return null;
			current = next;
		}
		return current.gameObject;
	}

	// #region 状态/参数访问（供 Animator shim 的 API 使用）
	public function SetFloat(name:String, value:Float):Void parameters.set(name, value);
	public function GetFloat(name:String):Float return toFloat(parameters.exists(name) ? parameters.get(name) : 0);
	public function SetInteger(name:String, value:Int):Void parameters.set(name, value);
	public function GetInteger(name:String):Int return Std.int(toFloat(parameters.exists(name) ? parameters.get(name) : 0));
	public function SetBool(name:String, value:Bool):Void parameters.set(name, value);
	public function GetBool(name:String):Bool return toBool(parameters.exists(name) ? parameters.get(name) : false);
	public function SetTrigger(name:String):Void parameters.set(name, true);
	public function ResetTrigger(name:String):Void parameters.set(name, false);

	/** 当前层的动画名（对应 `Animator.GetCurrentAnimationName()`）。 */
	public function GetCurrentAnimationName():String {
		if (layerStates.length == 0)
			return "";
		var state = getState(layerStates[0]);
		if (state == null)
			return "";
		var clip = state.clip == null ? null : AnimatorManifestLoader.LoadClip(state.clip);
		return clip != null ? clip.name : state.name;
	}

	public function GetCurrentAnimatorStateInfo(layerIndex:Int):AnimatorStateInfo {
		var info = new AnimatorStateInfo();
		var state = layerIndex >= 0 && layerIndex < layerStates.length ? getState(layerStates[layerIndex]) : null;
		if (state == null)
			return info;
		info.shortNameHash = Animator.StringToHash(state.name);
		info.fullPathHash = info.shortNameHash;
		var clip = state.clip == null ? null : AnimatorManifestLoader.LoadClip(state.clip);
		info.length = clip != null ? clip.length : 0;
		info.speed = state.speed;
		var time = layerIndex < layerTimes.length ? layerTimes[layerIndex] : 0;
		info.normalizedTime = info.length > 0 ? time / info.length : 0;
		info.loop = clip != null && clip.wrapMode == 2;
		return info;
	}

	public function IsPlaying():Bool return controller != null && animator.enabled;
	public function HasController():Bool return controller != null;

	private function getState(id:Null<String>):Null<AnimState> {
		if (id == null || controller == null || controller.states == null)
			return null;
		return cast Reflect.field(controller.states, id);
	}
	private function getMachine(id:Null<String>):Null<AnimStateMachine> {
		if (id == null || controller == null || controller.machines == null)
			return null;
		return cast Reflect.field(controller.machines, id);
	}
	private function getTransition(id:Null<String>):Null<AnimTransition> {
		if (id == null || controller == null || controller.transitions == null)
			return null;
		return cast Reflect.field(controller.transitions, id);
	}

	private static function toFloat(value:Dynamic):Float {
		if (value == null)
			return 0;
		return switch (Type.typeof(value)) {
			case TInt, TFloat: cast value;
			case TBool: (cast value:Bool) ? 1 : 0;
			default: 0;
		}
	}
	private static function toBool(value:Dynamic):Bool {
		if (value == null)
			return false;
		return switch (Type.typeof(value)) {
			case TInt, TFloat: toFloat(value) != 0;
			case TBool: cast value;
			default: false;
		}
	}
	// #endregion

	// #region 诊断
	/** 找不到事件接收者时是否记告警（默认开；批量驱动时可关）。 */
	public static var warnMissingEvents:Bool = true;
	private var clipNameForLog:String = "";
	// #endregion

	public var animator(default, null):Animator;
	public var controllerKey(default, null):String;
	private var controller:Null<AnimControllerFile> = null;
	private var parameters:Map<String, Dynamic> = new Map();
	private var layerStates:Array<String> = [];
	private var layerTimes:Array<Float> = [];
}

// PORT-NOTE: 曲线里的 `script` 是 Unity 的脚本 guid；移植层组件类上带着同名 guid 的元数据
// 不存在（`@:` 元数据运行期读不到，见 PORTING.md），所以这里只按**类名**做一次宽松匹配：
// guid -> 类名的表由 build_anim.py 的清单提供不了，改为「不校验」——即对所有组件尝试反射写入，
// 命中第一个能写的字段即返回（`writeByReflection` 的顺序遍历）。
private class ScriptGuidMap {
	public static function matches(cls:Class<Dynamic>, guid:String):Bool return true;
}
