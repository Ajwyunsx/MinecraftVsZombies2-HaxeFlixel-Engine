// Ported from: (新增文件) 场景/prefab 数据里的组件类型 -> Haxe 类
package mvz2.scenes;

import mvz2.scenes.ScenePrefabData.ScenePrefabComponent;

// PORT-NOTE: 本文件是移植层新增的「场景数据组件类型表」，没有 C# 对应源码。
//
// Unity 由引擎按组件类型名（UnityEngine 内置类）或 MonoBehaviour 脚本类名反射创建组件；
// 移植层没有这套反射，改用**显式表**：
//   1. 保证 hxcpp 的 DCE 不会裁掉这些只出现在数据里的类；
//   2. 未支持的脚本类型能被统计（ScenePrefabLoader.unknownComponents）而不是静默丢失。
//
// 表里的键与 `tools_build/build_scene.py` 导出的 `script` 字段一致：
//   * 工程内脚本 = C# 全名（namespace + 类名），例如 MVZ2.Grids.GridController
//   * Unity 包内置组件 = Unity 全名，例如 UnityEngine.UI.Image / TMPro.TextMeshProUGUI
//     （包内 guid 与类型名的对应见 build_scene.py 的 UNITY_PACKAGE_SCRIPTS）
class ScenePrefabComponentTypes {
	/** Unity 内置组件类名（非 MonoBehaviour）-> Haxe 类（unity shim）。 */
	public static var BuiltinClasses:Map<String, Class<Dynamic>> = [
		"SpriteRenderer" => unity.SpriteRenderer,
		"Animator" => unity.Animator,
		"ParticleSystem" => unity.ParticleSystem,
		"ParticleSystemRenderer" => unity.ParticleSystemRenderer,
		"MeshRenderer" => unity.MeshRenderer,
		"SortingGroup" => unity.rendering.SortingGroup,
		"BoxCollider" => unity.BoxCollider,
		"BoxCollider2D" => unity.BoxCollider2D,
		"CircleCollider2D" => unity.CircleCollider2D,
		"CapsuleCollider2D" => unity.CapsuleCollider2D,
		"PolygonCollider2D" => unity.PolygonCollider2D,
		"EdgeCollider2D" => unity.EdgeCollider2D,
		"CompositeCollider2D" => unity.CompositeCollider2D,
		"Collider2D" => unity.Collider2D,
		"Rigidbody2D" => unity.Rigidbody2D,
		"Light" => unity.Light,
		"LineRenderer" => unity.LineRenderer,
		"SpriteMask" => unity.SpriteMask,
		"Camera" => unity.Camera,
		"AudioSource" => unity.AudioSource,
		"Canvas" => unity.Canvas,
		"CanvasGroup" => unity.CanvasGroup,
		"CanvasRenderer" => unity.CanvasRenderer,
		"TextMesh" => unity.tmpro.TextMeshPro,
		// TODO-PORT: Rigidbody / AudioListener / AudioLowPassFilter / AudioDistortionFilter
		// 在关卡数据里出现（Rigidbody 4 个、AudioListener 47 个、音频滤镜各 2 个），
		// 移植层没有对应 shim（物理不参与模拟、3D 音频无实现），会在 unknownComponents 里统计。
	];

	/** MonoBehaviour 脚本（C# 全名 / Unity 包类型全名）-> Haxe 类。 */
	public static var ScriptClasses:Map<String, Class<Dynamic>> = buildScriptClasses();

	private static function buildScriptClasses():Map<String, Class<Dynamic>> {
		var map:Map<String, Class<Dynamic>> = [
			// ---- UnityEngine.UI（Assets/Prefabs/** 里由 Unity 包 guid 反查得到）----
			"UnityEngine.UI.Image" => unity.ui.Image,
			"UnityEngine.UI.RawImage" => unity.ui.RawImage,
			"UnityEngine.UI.Button" => unity.ui.Button,
			"UnityEngine.UI.Toggle" => unity.ui.Toggle,
			"UnityEngine.UI.ToggleGroup" => unity.ui.ToggleGroup,
			"UnityEngine.UI.Slider" => unity.ui.Slider,
			"UnityEngine.UI.Scrollbar" => unity.ui.Scrollbar,
			"UnityEngine.UI.ScrollRect" => unity.ui.ScrollRect,
			"UnityEngine.UI.Shadow" => unity.ui.Shadow,
			"UnityEngine.UI.Outline" => unity.ui.Shadow.Outline,
			"UnityEngine.UI.Mask" => unity.ui.Mask,
			"UnityEngine.UI.LayoutElement" => unity.ui.LayoutElement,
			"UnityEngine.UI.VerticalLayoutGroup" => unity.ui.HorizontalOrVerticalLayoutGroup.VerticalLayoutGroup,
			"UnityEngine.UI.HorizontalLayoutGroup" => unity.ui.HorizontalOrVerticalLayoutGroup.HorizontalLayoutGroup,
			"UnityEngine.UI.GridLayoutGroup" => unity.ui.HorizontalOrVerticalLayoutGroup.GridLayoutGroup,
			"UnityEngine.UI.ContentSizeFitter" => unity.ui.HorizontalOrVerticalLayoutGroup.ContentSizeFitter,
			"UnityEngine.UI.AspectRatioFitter" => unity.ui.HorizontalOrVerticalLayoutGroup.AspectRatioFitter,
			"UnityEngine.UI.CanvasScaler" => unity.ui.CanvasScaler,
			"UnityEngine.UI.GraphicRaycaster" => unity.ui.CanvasScaler.GraphicRaycaster,
			// ---- UnityEngine.EventSystems ----
			"UnityEngine.EventSystems.EventSystem" => unity.eventsystems.EventSystem,
			// TODO-PORT: StandaloneInputModule / PhysicsRaycaster 没有 shim（移植层输入由
			// mvz2.inputs.InputManager + mvz2.level.LevelRaycaster 自行实现），
			// 会在 unknownComponents 里统计。
			// ---- TMPro ----
			"TMPro.TextMeshProUGUI" => unity.tmpro.TextMeshProUGUI,
			"TMPro.TextMeshPro" => unity.tmpro.TextMeshPro,
			"TMPro.TMP_InputField" => unity.tmpro.TMP_InputField,
			"TMPro.TMP_Dropdown" => unity.tmpro.TMP_Dropdown,
			// ---- MVZ2 / 工程脚本（关卡与 UI 图）----
			"MVZ2.Grids.GridController" => mvz2.grids.GridController,
			"MVZ2.Grids.GridView" => mvz2.grids.GridView,
			"MVZ2.Grids.LaneController" => mvz2.grids.LaneController,
			"MVZ2.Grids.GridLayoutController" => mvz2.grids.GridLayoutController,
			"MVZ2.Cameras.LevelCamera" => mvz2.cameras.LevelCamera,
			"MVZ2.Level.CameraLimiter" => mvz2.level.CameraLimiter,
			"MVZ2.Level.LevelRaycaster" => mvz2.level.LevelRaycaster,
			"MVZ2.Level.LevelController" => mvz2.level.LevelController,
			"MVZ2.Level.LevelBlueprintController" => mvz2.level.LevelBlueprintController,
			"MVZ2.Level.LevelBlueprintChooseController" => mvz2.level.LevelBlueprintChooseController,
			"MVZ2.Level.ClassicBlueprintController" => mvz2.level.ClassicBlueprintController,
			"MVZ2.Level.ConveyorBlueprintController" => mvz2.level.ConveyorBlueprintController,
			"MVZ2.Level.ChosenBlueprintController" => mvz2.level.ChosenBlueprintController,
			"MVZ2.Level.PoolColorSetter" => mvz2.level.PoolColorSetter,
			"MVZ2.Level.PoolAnimator" => mvz2.level.PoolAnimator,
			"MVZ2.Level.NightmareSkyAnimator" => mvz2.level.NightmareSkyAnimator,
			"MVZ2.Level.LevelTalkSystem" => mvz2.level.LevelTalkSystem,
			"MVZ2.UI.Level.LevelUI" => mvz2.ui.level.LevelUI,
			"MVZ2.UI.Level.LevelUIPreset" => mvz2.ui.level.LevelUIPreset,
			"MVZ2.UI.Level.HintArrow" => mvz2.ui.level.HintArrow,
			"MVZ2.UI.DragMover" => mvz2.ui.DragMover,
			"MVZ2.UI.ElementList" => mvz2.ui.ElementList,
			"MVZ2.Models.LightController" => mvz2.models.LightController,
			// ---- 关卡/UI 图里出现次数最多、且运行期必须能实例化的脚本 ----
			// PORT-NOTE: 这些类的**唯一**引用点是运行期数据（prefab JSON 里的 `haxe` 字段），
			// `Type.resolveClass` 在 hxcpp 上对**被 DCE 裁掉**的类返回 null。真实构建里它们通常
			// 因为游戏代码引用而存活，但只包含场景子系统的构建（如 verify/scenes 的冒烟工程）
			// 会把它们全裁掉，表现为 unknownComponents 一大片。列进本表即产生静态引用，DCE 必然保留。
			"MVZ2.Audios.SoundPlayer" => mvz2.audios.SoundPlayer,
			"MVZ2.UI.Deselector" => mvz2.ui.Deselector,
			"MVZ2.UI.CursorHandler" => mvz2.ui.CursorHandler,
			"MVZ2.UI.TooltipAnchor" => mvz2.ui.TooltipAnchor,
			"MVZ2.UI.TooltipHandler" => mvz2.ui.TooltipHandler,
			"MVZ2.UI.TextButton" => mvz2.ui.TextButton,
			"MVZ2.UI.LayoutSizeLimiter" => mvz2.ui.LayoutSizeLimiter,
			"MVZ2.UI.ElementListUI" => mvz2.ui.ElementListUI,
			"MVZ2.UI.ElementArray" => mvz2.ui.ElementArray,
			"MVZ2.UI.Blueprint" => mvz2.ui.Blueprint,
			"MVZ2.UI.BlueprintDisplayer" => mvz2.ui.BlueprintDisplayer,
			"MVZ2.UI.BlueprintDisplayerMobile" => mvz2.ui.BlueprintDisplayerMobile,
			"MVZ2.UI.BlueprintDisplayerStandalone" => mvz2.ui.BlueprintDisplayerStandalone,
			"MVZ2.UI.BlueprintDisplayerStandalonePage" => mvz2.ui.BlueprintDisplayerStandalonePage,
			"MVZ2.UI.Level.BlueprintArray" => mvz2.ui.level.BlueprintArray,
			"MVZ2.UI.Level.BlueprintList" => mvz2.ui.level.BlueprintList,
			"MVZ2.UI.Level.BlueprintChoosePanel" => mvz2.ui.level.BlueprintChoosePanel,
			"MVZ2.UI.Level.CommandBlockChoosePanel" => mvz2.ui.level.CommandBlockChoosePanel,
			"MVZ2.UI.Level.LevelUIBlueprintChoose" => mvz2.ui.level.LevelUIBlueprintChoose,
			"MVZ2.UI.Level.LevelUIBlueprints" => mvz2.ui.level.LevelUIBlueprints,
			"MVZ2.UI.Level.EnergyPanel" => mvz2.ui.level.EnergyPanel,
			"MVZ2.UI.Level.PickaxeSlot" => mvz2.ui.level.PickaxeSlot,
			"MVZ2.UI.Level.TriggerSlot" => mvz2.ui.level.TriggerSlot,
			"MVZ2.UI.Level.ProgressBar" => mvz2.ui.level.ProgressBar,
			"MVZ2.UI.Level.ProgressBarBanner" => mvz2.ui.level.ProgressBarBanner,
			"MVZ2.UI.Level.StarshardPanel" => mvz2.ui.level.StarshardPanel,
			"MVZ2.UI.Level.StarshardPanelIcon" => mvz2.ui.level.StarshardPanelIcon,
			"MVZ2.UI.Level.StarshardPanelPoint" => mvz2.ui.level.StarshardPanelPoint,
			"MVZ2.UI.Level.MoneyPanel" => mvz2.ui.MoneyPanel,
			"MVZ2.UI.Level.Conveyor" => mvz2.ui.level.Conveyor,
			"MVZ2.UI.Level.LawnRaycastReceiver" => mvz2.ui.level.LawnRaycastReceiver,
			"MVZ2.UI.Level.ArtifactShaderController" => mvz2.ui.level.ArtifactShaderController,
			"MVZ2.UI.Level.PauseDialog" => mvz2.ui.level.PauseDialog,
			"MVZ2.ChapterTransition.ChapterTransitionBlurer" => mvz2.chaptertransition.ChapterTransitionBlurer,
			"MVZ2.UI.Level.GameOverDialog" => mvz2.ui.level.GameOverDialog,
			"MVZ2.View.Level.LevelPointerInteractionHandler" => mvz2.view.level.LevelPointerInteractionHandler,
			"MVZ2.Models.AnimationImageSetter" => mvz2.models.AnimationImageSetter,
			"MVZ2.Models.StarshardRotationSetter" => mvz2.models.StarshardRotationSetter,
			"MVZ2.Localization.ImageTranslator" => mvz2.localization.ImageTranslator,
			"MVZ2.Localization.TextMeshProTranslator" => mvz2.localization.TextMeshProTranslator,
			"MVZ2.Localization.TextMeshProUGUITranslator" => mvz2.localization.TextMeshProUGUITranslator,
			// ---- 模型 prefab 里也会出现的脚本（关卡图里带模型零件，见 build_models.py 的同一批表）----
			"MVZ2.Models.ModelGroup" => mvz2.models.ModelGroup,
			"MVZ2.Models.ModelGroupEntity" => mvz2.models.ModelGroupEntity,
			"MVZ2.Models.ModelGroupUI" => mvz2.models.ModelGroupUI,
			"MVZ2.Models.ModelAnchor" => mvz2.models.ModelAnchor,
			"MVZ2.Models.ModelBone" => mvz2.models.ModelBone,
			"MVZ2.Models.EntityModel" => mvz2.models.EntityModel,
			"MVZ2.Models.RendererElement" => mvz2.models.RendererElement,
			"MVZ2.Models.AnimatorElement" => mvz2.models.AnimatorElement,
			"MVZ2.Models.TransformElement" => mvz2.models.TransformElement,
			"MVZ2.Models.SortingGroupElement" => mvz2.models.SortingGroupElement,
			"MVZ2.Models.GraphicElement" => mvz2.models.GraphicElement,
			"MVZ2.Models.ParticlePlayer" => mvz2.models.ParticlePlayer,
			"MVZ2.Models.AnimationSpriteSetter" => mvz2.models.AnimationSpriteSetter,
			"MVZ2.Localization.SpriteRendererTranslator" => mvz2.localization.SpriteRendererTranslator,
			// PORT-NOTE: C# 里这个脚本的文件名是 PositionTranslator.cs、类名是 PositionTransition，
			// 移植层按「模块名 == 主类型名」命名为 tools.PositionTransition.hx（见该文件头部注释）。
			// 导出数据的 script 字段是 C# 类名，所以键写 PositionTransition。
			"Tools.PositionTransition" => tools.PositionTransition,
			// ---- 其余脚本（反射兜底）----
			// PORT-NOTE: 关卡/UI 图里有 245 个不同的脚本类，逐个列进显式表既冗长又容易漏；
			// `GetClass` 对表里查不到的名字走 `Type.resolveClass`（见 resolveByReflection）。
			// 显式表仍保留上面这些关键类，原因是 DCE：只出现在运行期数据里的类不会因为
			// 「表里有一项」而被静态引用到（表本身也是静态字段），所以两处都要在：
			// 显式表给最关键的关卡类兜底，反射覆盖其余。
		];
		return map;
	}

	/** 从导出数据里取组件类（找不到返回 null，调用方记入 unknownComponents）。 */
	public static function GetClass(rec:ScenePrefabComponent):Null<Class<Dynamic>> {
		if (rec == null)
			return null;
		if (rec.type == "MonoBehaviour") {
			if (rec.script == null)
				return null;
			var cls = ScriptClasses.get(rec.script);
			if (cls != null)
				return cls;
			return resolveByReflection(rec);
		}
		var builtin = BuiltinClasses.get(rec.type);
		if (builtin != null)
			return builtin;
		return resolveByReflection(rec);
	}

	/**
	 * 显式表查不到时按类名反射解析（Haxe 全限定名，与导出数据的 `haxe` 字段一致）。
	 *
	 * PORT-NOTE: 关卡/UI 图里有 245 个不同的脚本类，逐个列进 ScriptClasses 既冗长又容易漏
	 * （漏掉的组件会被静默丢弃，而它们上面的 `[SerializeField]` 引用正是关卡依赖的数据）。
	 * 因此这里用 `Type.resolveClass` 兜底：脚本类都在同一份编译单元里，Haxe 的
	 * `Type.resolveClass` 在 hxcpp 上可用；DCE 也不会裁掉它们 —— 关卡图是运行期数据，
	 * 不能靠静态引用保住，所以 `ScenePrefabComponentTypes` 用 `@:keep` 的显式表 + 这里
	 * 的反射解析配合（显式表保证最关键的类一定在，反射覆盖其余）。
	 *
	 * 未注册的类（例如未移植的脚本）返回 null，调用方记入 `unknownComponents`。
	 */
	static function resolveByReflection(rec:ScenePrefabComponent):Null<Class<Dynamic>> {
		var name = rec.haxe;
		if (name == null && rec.script != null) {
			// 兜底：按 PORTING.md 的映射规则（namespace 全小写）现算 Haxe 类名。
			var dot = rec.script.lastIndexOf(".");
			if (dot > 0)
				name = rec.script.substr(0, dot).toLowerCase() + "." + rec.script.substr(dot + 1);
		}
		if (name == null)
			return null;
		var cls = Type.resolveClass(name);
		if (cls != null)
			return cls;
		return null;
	}
}
