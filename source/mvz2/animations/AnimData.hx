// Ported from: (新增文件) HaxePort/tools_build/build_anim.py 的输出格式
package mvz2.animations;

// PORT-NOTE: 本文件是移植层新增的「AnimatorController / AnimationClip 数据」类型定义，
// 没有 C# 对应源码。
//
// Unity 侧 UI/场景的动画来自 `Assets/Animation/**`：`.controller`（状态机）与 `.anim`（clip）。
// 移植层没有 Unity 资产系统，改由 `tools_build/build_anim.py` 导出成下述 JSON，
// 运行期由 `AnimatorManifestLoader` + `AnimatorRuntime` 重建状态机并驱动。
//
// 编码约定（与导出脚本一一对应）：
//   * 关键帧 = `[time, value]` 两元数组（Unity 的 inSlope/outSlope 贝塞尔切线不导出，线性插值）；
//   * 曲线定位 = `path`（GameObject 层级路径）+ `classID`（组件类型）+ `attribute`（字段名），
//     MonoBehaviour 额外带 `script`（脚本 guid）；
//   * 状态机里的 fileID 是 Unity 的 64 位整数，JSON 里存成**字符串**（Haxe 的 Int 是 32 位，
//     fileID 会溢出；导出脚本已转成十进制字符串）。

/** 一条关键帧：[时间, 值]。 */
typedef AnimKeyframe = Array<Float>;

/** 一条 float 曲线（对应 Unity 的 m_FloatCurves 记录）。 */
typedef AnimCurve = {
	/** GameObject 层级路径（相对动画根；空串 = 根自身）。 */
	var path:String;
	/** Unity classID（4=Transform、212=SpriteRenderer、224=RectTransform、225=CanvasGroup…）。 */
	var classID:Int;
	/** 字段名（Unity 序列化名，如 m_Color.a / m_AnchoredPosition.x / m_IsActive）。 */
	var attribute:String;
	/** MonoBehaviour 的脚本 guid（非 MonoBehaviour 为 null）。 */
	@:optional var script:String;
	/** 关键帧（按时间升序）。 */
	var keys:Array<AnimKeyframe>;
}

/** 一条动画事件（对应 Unity 的 AnimationEvent）。 */
typedef AnimEvent = {
	var time:Float;
	/**
	 * 目标 GameObject 上的方法名（Unity 用 SendMessage 语义调用同名方法）。
	 *
	 * PORT-NOTE: 字段名用 `functionName` 而不是 Unity 的 `function` —— `function` 是 Haxe 关键字，
	 * 不能做字段名（与 `mvz2.talkdata.TalkScript` 的同一处理）。
	 */
	var functionName:String;
	@:optional var data:String;
	@:optional var floatParam:Float;
	@:optional var intParam:Int;
}

typedef AnimClipFile = {
	var kind:String;
	var name:String;
	/** clip 长度（秒） = 关键帧与事件时间的最大值。 */
	var length:Float;
	var sampleRate:Float;
	var wrapMode:Int;
	var legacy:Int;
	var curves:Array<AnimCurve>;
	var events:Array<AnimEvent>;
}

typedef AnimParameter = {
	var name:String;
	/** 1=Float、3=Int、4=Bool、9=Trigger（与 UnityEngine.AnimatorControllerParameterType 一致）。 */
	var type:Int;
	var defaultFloat:Float;
	var defaultInt:Int;
	var defaultBool:Bool;
}

/** BlendTree 的一个子 clip（按 x/y 阈值混合）。 */
typedef AnimBlendChild = {
	var clip:Null<String>;
	var threshold:Float;
	var x:Float;
	var y:Float;
}

typedef AnimBlendTree = {
	var blendX:Null<String>;
	var blendY:Null<String>;
	var children:Array<AnimBlendChild>;
}

typedef AnimState = {
	var name:String;
	/** clip 的 key（相对 assets 的路径，含扩展名），例如 "Animation/Init/Splash/splash.anim"。 */
	var clip:Null<String>;
	@:optional var blend:Null<AnimBlendTree>;
	var speed:Float;
	/** 转移的 fileID（字符串，对应 transitions 表的键）。 */
	var transitions:Array<String>;
}

typedef AnimTransition = {
	/** 条件列表；空数组 = 无条件（靠 hasExitTime 转移）。 */
	var conditions:Array<AnimCondition>;
	/** 目标状态的 fileID（字符串）；null = 退出/结束。 */
	var dst:Null<String>;
	var hasExitTime:Bool;
	var exitTime:Float;
	var duration:Float;
}

typedef AnimCondition = {
	/** 1=If（布尔真）、2=IfNot、3=Greater、4=Less、6=Equals、7=NotEqual（Unity 的 m_ConditionMode）。 */
	var mode:Int;
	var event:String;
	var threshold:Float;
}

typedef AnimStateMachine = {
	var name:String;
	/** 状态 fileID（字符串）。 */
	var states:Array<String>;
	/** 默认状态 fileID（字符串）。PORT-NOTE: 字段名用 `defaultState` 而不是 Unity 的 `default`
	 * —— `default` 是 Haxe 关键字，不能做字段名。 */
	var defaultState:Null<String>;
	var anyTransitions:Array<String>;
}

typedef AnimLayer = {
	var name:String;
	/** 状态机 fileID（字符串，对应 machines 表的键）。 */
	var machine:Null<String>;
	var defaultWeight:Float;
}

typedef AnimControllerFile = {
	var kind:String;
	var name:String;
	var parameters:Array<AnimParameter>;
	var layers:Array<AnimLayer>;
	/** fileID（字符串）-> 状态机。 */
	var machines:Dynamic;
	/** fileID（字符串）-> 状态。 */
	var states:Dynamic;
	/** fileID（字符串）-> 转移。 */
	var transitions:Dynamic;
}

/** anim_manifest.json 的单个条目。 */
typedef AnimManifestEntry = {
	/** 相对 assets 的路径（含扩展名），例如 "Animation/Init/Splash/splash.controller"。 */
	var key:String;
	/** "controller" 或 "clip"。 */
	var kind:String;
	/** Unity 工程内路径。 */
	var asset:String;
	/** 分文件数据路径（相对 assets）。 */
	var data:String;
	@:optional var stateCount:Int;
	@:optional var parameterCount:Int;
	@:optional var curveCount:Int;
	@:optional var eventCount:Int;
	@:optional var length:Float;
}

typedef AnimManifest = {
	var version:Int;
	var assetsRoot:String;
	var dataDir:String;
	var entries:Array<AnimManifestEntry>;
	var stats:Dynamic;
	@:optional var warnings:Array<String>;
}
