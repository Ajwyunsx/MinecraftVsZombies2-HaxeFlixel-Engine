// Ported from: (新增文件) 对应 Unity 侧「加载模型 prefab 资产」的能力（无 C# 对应源码）
package mvz2.models;

import haxe.Json;
import mvz2.models.ModelPrefabData;
import sys.io.File;
import unity.Component;
import unity.Debug;
import unity.GameObject;
import unity.MonoBehaviour;
import unity.Quaternion;
import unity.RectTransform;
import unity.Transform;
import unity.UnityObject;
import unity.Vector2;
import unity.Vector3;
import unity.Vector4;

// PORT-NOTE: 本文件是移植层新增的「prefab 资产加载器」，没有 C# 对应源码。
//
// C# 侧模型的创建流程（Assets/Scripts/MVZ2/Models/Utilities/ModelBuilder.cs）：
//   var prefab = ResourceManager.GetModel(modelMeta.Path);            // Addressables 标签 Model
//   var model  = GameObject.Instantiate(prefab, parent).GetComponent<Model>();
//   foreach (参数) parameter.Apply(model); model.SetProperty(...); model.Init(id, camera, seed);
// 移植层没有 Unity 的 prefab 资产，改为读取 tools_build/build_models.py 导出的
// assets/models_manifest.json + assets/model_prefabs/<ns>/<path>.json，按节点表重建
// GameObject 层级（含全部组件与序列化字段），语义等价于 Instantiate(prefab, parent)。
//
// 说明：
//   * 组件顺序、父子顺序、localPosition/localRotation/localScale 均按 prefab 原样恢复；
//     节点的 active（m_IsActive）与 layer 同样恢复。
//   * 序列化字段按 prefab 里保存的值恢复（Unity 运行期直接用这些值，不会重算
//     ModelGroup.UpdateElements；后者只在编辑器 ModelMenu 里运行）。
//   * Unity 的 AddComponent 会立即调用 Awake，这里在字段写入后调用 Awake（见 callAwake 的 PORT-NOTE）。
//   * 组件类通过显式表（ModelPrefabComponentTypes）解析，保证 hxcpp 的 DCE 不会裁掉这些类。
class ModelPrefabLoader {
	// 清单/数据缓存（放在类顶部，便于静态方法引用）。
	private static var manifest:Null<ModelPrefabManifest> = null;
	private static var manifestIndex:Map<String, ModelPrefabManifestEntry> = null;
	private static var dataCache:Map<String, Null<ModelPrefabFile>> = new Map();
	// #region 清单与数据文件
	/** 清单相对路径（由 unity.Application.dataPath 给出 assets 根）。 */
	public static function GetManifestPath():String {
		return unity.Application.dataPath + "/models_manifest.json";
	}
	public static function GetDataDir():String {
		return unity.Application.dataPath + "/model_prefabs";
	}
	// PORT-NOTE: 首次访问时同步加载清单；C# 侧这些数据来自 Unity 资产的导入结果。
	public static function GetManifest(?reload:Bool = false):Null<ModelPrefabManifest> {
		if (manifest == null || reload) {
			manifest = loadManifest();
			manifestIndex = null;
			if (manifest != null && manifest.models != null) {
				manifestIndex = new Map();
				for (entry in manifest.models) {
					if (entry != null && entry.id != null)
						manifestIndex.set(entry.id, entry);
				}
			}
		}
		return manifest;
	}
	/** 按模型 id 取清单条目（models 是数组，这里用运行期建立的索引）。 */
	public static function GetEntry(modelId:String):Null<ModelPrefabManifestEntry> {
		var man = GetManifest();
		if (man == null)
			return null;
		if (manifestIndex == null)
			return null;
		return manifestIndex.exists(modelId) ? manifestIndex.get(modelId) : null;
	}
	private static function loadManifest():Null<ModelPrefabManifest> {
		var path = GetManifestPath();
		if (!sys.FileSystem.exists(path)) {
			loadWarnings.push('模型清单不存在：$path（需先运行 tools_build/build_models.py）');
			return null;
		}
		try {
			return cast Json.parse(File.getContent(path));
		} catch (e:Dynamic) {
			loadWarnings.push('模型清单解析失败：$path：$e');
			return null;
		}
	}
	/** 按模型 id 读取单个模型的数据文件（不存在或未转换时为 null）。 */
	public static function LoadModelData(modelId:String):Null<ModelPrefabFile> {
		if (modelId == null)
			return null;
		if (dataCache.exists(modelId))
			return dataCache.get(modelId);
		var result:Null<ModelPrefabFile> = null;
		var entry = GetEntry(modelId);
		if (entry != null && entry.prefab != null && entry.prefab.data != null) {
			// 清单里的 data 是**相对 assets 根**的路径（与 build_models.py 的字段说明一致）。
			var path = unity.Application.dataPath + "/" + entry.prefab.data;
			if (sys.FileSystem.exists(path)) {
				try {
					result = cast Json.parse(File.getContent(path));
				} catch (e:Dynamic) {
					loadWarnings.push('模型数据解析失败：$path：$e');
				}
			} else {
				loadWarnings.push('模型数据文件不存在：$path');
			}
		}
		dataCache.set(modelId, result);
		return result;
	}
	// #endregion

	// #region 实例化
	/** 按模型 id 重建 GameObject 层级并挂到 parent 下（对应 Instantiate(prefab, parent)）。 */
	public static function Instantiate(modelId:String, ?parent:Transform):Null<GameObject> {
		var data = LoadModelData(modelId);
		if (data == null) {
			instantiateFailures++;
			return null;
		}
		return InstantiateData(data, parent);
	}
	/** 按已解析的数据重建 GameObject 层级。 */
	public static function InstantiateData(data:ModelPrefabFile, ?parent:Transform):Null<GameObject> {
		if (data == null || data.nodes == null || data.nodes.length == 0) {
			instantiateFailures++;
			return null;
		}
		var ctx = new ModelPrefabContext(data);

		// 1) 先建 GameObject + Transform（此时还没有组件，引用解析放到第 3 步）。
		for (i in 0...data.nodes.length) {
			var node = data.nodes[i];
			var go = new GameObject(node.name);
			go.name = node.name;
			go.layer = node.layer;
			ctx.gameObjects.push(go);
			ctx.components.push([]);

			var tr = go.transform;
			var td = node.transform;
			if (td != null) {
				tr.localPosition = _v3(td.pos, 0, 0, 0);
				tr.localRotation = _quat(td.rot);
				tr.localScale = _v3(td.scale, 1, 1, 1);
				if (td.rect != null) {
					var rt = new RectTransform();
					rt.name = tr.name;
					rt.gameObject = go;
					rt.localPosition = tr.localPosition;
					rt.localRotation = tr.localRotation;
					rt.localScale = tr.localScale;
					rt.anchoredPosition = _v2(td.rect.anchoredPosition, 0, 0);
					rt.sizeDelta = _v2(td.rect.sizeDelta, 0, 0);
					rt.anchorMin = _v2(td.rect.anchorMin, 0.5, 0.5);
					rt.anchorMax = _v2(td.rect.anchorMax, 0.5, 0.5);
					rt.pivot = _v2(td.rect.pivot, 0.5, 0.5);
					go.transform = rt;
					tr = rt;
				}
			}
			// 组件下标 0 = Transform（见 ModelPrefabData 的编码约定）。
			ctx.components[i].push(tr);
			go.SetActive(node.active);
		}

		// 2) 建组件实例（顺序 = prefab 的 m_Component 顺序，GetComponents 顺序与此一致）。
		for (i in 0...data.nodes.length) {
			var node = data.nodes[i];
			for (ci in 0...node.components.length) {
				var rec = node.components[ci];
				var cls = ModelPrefabComponentTypes.GetClass(rec);
				if (cls == null) {
					var key = rec.type == "MonoBehaviour" ? (rec.script == null ? "(unknown script)" : rec.script) : rec.type;
					unknownComponents.set(key, (unknownComponents.exists(key) ? unknownComponents.get(key) : 0) + 1);
					ctx.components[i].push(null);
					continue;
				}
				var comp:Component = ctx.gameObjects[i].AddComponent(cls);
				// Unity 里组件的 name 就是类型名；移植层 AddComponent 不会设置，这里补上，
				// 便于日志/调试定位（ModelPrefabLoader.callAwake 的告警会用到）。
				comp.name = Type.getClassName(cls);
				ctx.components[i].push(comp);
			}
		}

		// 2.5) Unity 里 ParticleSystem 的 renderer 就是同 GameObject 上的 ParticleSystemRenderer
		// 组件；shim 的 ps.renderer 是普通字段，等所有组件建好后补上绑定（否则 systemRenderer 的
		// 字段无处可写）。
		for (i in 0...data.nodes.length) {
			var ps = ctx.gameObjects[i].GetComponent(unity.ParticleSystem);
			if (ps == null)
				continue;
			var psr = ctx.gameObjects[i].GetComponent(unity.ParticleSystemRenderer);
			if (psr != null)
				ps.renderer = psr;
		}

		// 3) 写序列化字段（要等所有组件都建好，引用才能互相解析）。
		for (i in 0...data.nodes.length) {
			var node = data.nodes[i];
			for (ci in 0...node.components.length) {
				var comp = ctx.components[i][ci + 1];
				if (comp == null)
					continue;
				applyFields(comp, node.components[ci], ctx);
			}
		}

		// 4) 恢复父子关系（按 m_Children 顺序）。
		for (i in 0...data.nodes.length) {
			var node = data.nodes[i];
			if (node.parent != null && node.parent >= 0 && node.parent < ctx.gameObjects.length) {
				ctx.gameObjects[i].transform.SetParent(ctx.gameObjects[node.parent].transform, false);
			}
		}

		// 5) 挂到目标父级（对应 Instantiate 的 parent 参数）。
		for (root in data.roots) {
			if (root < 0 || root >= ctx.gameObjects.length)
				continue;
			var tr = ctx.gameObjects[root].transform;
			if (parent != null) {
				tr.SetParent(parent, false);
			}
			rootObject = ctx.gameObjects[root];
		}

		// 6) Unity 的 AddComponent 语义：组件加入后立即 Awake。
		for (i in 0...data.nodes.length) {
			for (ci in 0...data.nodes[i].components.length) {
				var comp = ctx.components[i][ci + 1];
				if (comp != null)
					callAwake(comp);
			}
		}
		instantiatedModels++;
		return ctx.gameObjects.length > 0 ? ctx.gameObjects[data.roots[0]] : null;
	}
	/** 按模型 id 重建并返回根上的 Model 组件（等价于 Instantiate(prefab).GetComponent<Model>()）。 */
	public static function CreateModel(modelId:String, ?parent:Transform):Null<Model> {
		var go = Instantiate(modelId, parent);
		if (go == null)
			return null;
		return go.GetComponent(Model);
	}
	// #endregion

	// #region 字段写入
	/**
	 * 把 prefab 里保存的组件字段写到组件实例上（实现见 ModelPrefabFieldApplier）。
	 *
	 * PORT-NOTE: C# 侧由 Unity 的序列化系统自动填充 [SerializeField] 字段；移植层按名字写入。
	 * 只写组件上真实存在的字段，导出数据里多出的键记入 missingFields 统计。
	 */
	public static function applyFields(comp:Component, rec:ModelPrefabComponent, ctx:ModelPrefabContext):Void {
		ModelPrefabFieldApplier.Apply(comp, rec, ctx);
	}
	/** Unity 的 AddComponent 会同步调用 Awake；移植层手动触发（找不到 Awake 时什么都不做）。 */
	public static function callAwake(comp:Component):Void {
		var fn = Reflect.field(comp, "Awake");
		if (fn == null || !Reflect.isFunction(fn))
			return;
		try {
			Reflect.callMethod(comp, fn, []);
		} catch (e:Dynamic) {
			// PORT-NOTE: Unity 的 AddComponent 里 Awake 抛异常也会被 Unity 记录并继续；
			// 这里保持同样的容错，并把组件类型带进日志便于定位（comp.name 在移植层通常为空）。
			Debug.LogWarning('[ModelPrefabLoader] ${Type.getClassName(Type.getClass(comp))} 的 Awake 抛出异常：$e');
		}
	}
	// #endregion

	// #region 诊断
	/** 上次实例化的根对象（调试用）。 */
	public static var rootObject:GameObject;
	public static var instantiatedModels:Int = 0;
	public static var instantiateFailures:Int = 0;
	/** 无法解析的组件类型 -> 出现次数。 */
	public static var unknownComponents:Map<String, Int> = new Map();
	/** 导出数据里有、但 Haxe 组件上不存在的字段 -> 出现次数。 */
	public static var missingFields:Map<String, Int> = new Map();
	/** 加载过程中的告警（清单/数据文件缺失等）。 */
	public static var loadWarnings:Array<String> = [];
	public static function ResetStats():Void {
		instantiatedModels = 0;
		instantiateFailures = 0;
		unknownComponents.clear();
		missingFields.clear();
		loadWarnings = [];
	}
	// #endregion

	// #region 小工具
	static function _v2(a:Array<Float>, dx:Float, dy:Float):Vector2 {
		return a != null && a.length >= 2 ? new Vector2(a[0], a[1]) : new Vector2(dx, dy);
	}
	static function _v3(a:Array<Float>, dx:Float, dy:Float, dz:Float):Vector3 {
		return a != null && a.length >= 3 ? new Vector3(a[0], a[1], a[2]) : new Vector3(dx, dy, dz);
	}
	static function _quat(a:Array<Float>):Quaternion {
		return a != null && a.length >= 4 ? new Quaternion(a[0], a[1], a[2], a[3]) : new Quaternion(0, 0, 0, 1);
	}
	// #endregion
}

/**
 * Unity 组件类名 / MonoBehaviour 脚本类名 -> Haxe 类。
 *
 * PORT-NOTE: 用显式表而不是 Type.resolveClass，一是保证 hxcpp 的 DCE 不会裁掉这些只在数据里
 * 出现的类（例如 EntityModel、ModelGroupEntity），二是未支持的脚本类型能被统计出来（见
 * ModelPrefabLoader.unknownComponents）而不是静默丢失。
 */
class ModelPrefabComponentTypes {
	/** Unity 内置组件类名 -> Haxe 类（unity shim）。 */
	public static var BuiltinClasses:Map<String, Class<Dynamic>> = [
		"SpriteRenderer" => unity.SpriteRenderer,
		"Animator" => unity.Animator,
		"ParticleSystem" => unity.ParticleSystem,
		"ParticleSystemRenderer" => unity.ParticleSystemRenderer,
		"MeshRenderer" => unity.MeshRenderer,
		// TODO-PORT: MeshFilter 没有 shim（FBX 网格在 HaxeFlixel 端无法直接渲染），
		// 出现在 47 个 3D 模型节点上（wither / red_dragon 等），会在 unknownComponents 里被统计。
		"BoxCollider" => unity.BoxCollider,
		"SortingGroup" => unity.rendering.SortingGroup,
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
	];

	/** MonoBehaviour 脚本（C# 全名）-> Haxe 类。 */
	public static var ScriptClasses:Map<String, Class<Dynamic>> = [
		// MVZ2.Models（Assets/Scripts/View/Models/**）
		"MVZ2.Models.AnimationRotator" => mvz2.models.AnimationRotator,
		"MVZ2.Models.AnimationSpriteSetter" => mvz2.models.AnimationSpriteSetter,
		"MVZ2.Models.AnimatorElement" => mvz2.models.AnimatorElement,
		"MVZ2.Models.BlueprintSprite" => mvz2.models.BlueprintSprite,
		"MVZ2.Models.CartChargeBarModel" => mvz2.models.CartChargeBarModel,
		"MVZ2.Models.CircleFillSpriteSetter" => mvz2.models.CircleFillSpriteSetter,
		"MVZ2.Models.ColorOffsetSetter" => mvz2.models.ColorOffsetSetter,
		"MVZ2.Models.CrushingWallsModelPlatform" => mvz2.models.CrushingWallsModelPlatform,
		"MVZ2.Models.DamagePercentGameObjectActivator" => mvz2.models.DamagePercentGameObjectActivator,
		"MVZ2.Models.DamagePercentSpriteSetter" => mvz2.models.DamagePercentSpriteSetter,
		"MVZ2.Models.EntityModel" => mvz2.models.EntityModel,
		"MVZ2.Models.FireTimeRunner" => mvz2.models.FireTimeRunner,
		"MVZ2.Models.HSVOffsetSetter" => mvz2.models.HSVOffsetSetter,
		"MVZ2.Models.ImageElement" => mvz2.models.ImageElement,
		"MVZ2.Models.LightController" => mvz2.models.LightController,
		"MVZ2.Models.LightningGenerator" => mvz2.models.LightningGenerator,
		"MVZ2.Models.LineRendererPointLocker" => mvz2.models.LineRendererPointLocker,
		"MVZ2.Models.LocalSpriteRectSetter" => mvz2.models.LocalSpriteRectSetter,
		"MVZ2.Models.MobileColliderExpander" => mvz2.models.MobileColliderExpander,
		"MVZ2.Models.ModelAnchor" => mvz2.models.ModelAnchor,
		"MVZ2.Models.ModelBone" => mvz2.models.ModelBone,
		"MVZ2.Models.ModelGroupEntity" => mvz2.models.ModelGroupEntity,
		"MVZ2.Models.ModelGroupUI" => mvz2.models.ModelGroupUI,
		"MVZ2.Models.ModelPropertyGameObjectActivatorBoolean" => mvz2.models.ModelPropertyGameObjectActivatorBoolean,
		"MVZ2.Models.ModelPropertyGameObjectActivatorInt" => mvz2.models.ModelPropertyGameObjectActivatorInt,
		"MVZ2.Models.ModelPropertySpriteSetterBoolean" => mvz2.models.ModelPropertySpriteSetterBoolean,
		"MVZ2.Models.ModelPropertySpriteSetterInt" => mvz2.models.ModelPropertySpriteSetterInt,
		"MVZ2.Models.ModelPropertySpriteSetterReference" => mvz2.models.ModelPropertySpriteSetterReference,
		"MVZ2.Models.NightmareEye" => mvz2.models.NightmareEye,
		"MVZ2.Models.ParticlePlayer" => mvz2.models.ParticlePlayer,
		"MVZ2.Models.PositionLocker" => mvz2.models.PositionLocker,
		"MVZ2.Models.RendererElement" => mvz2.models.RendererElement,
		"MVZ2.Models.RotationLocker" => mvz2.models.RotationLocker,
		"MVZ2.Models.SlendermanTentacle" => mvz2.models.SlendermanTentacle,
		"MVZ2.Models.SortingGroupElement" => mvz2.models.SortingGroupElement,
		"MVZ2.Models.SpriteMaskController" => mvz2.models.SpriteMaskController,
		"MVZ2.Models.SpriteSizeFitter" => mvz2.models.SpriteSizeFitter,
		"MVZ2.Models.TrailController" => mvz2.models.TrailController,
		"MVZ2.Models.TransformElement" => mvz2.models.TransformElement,
		"MVZ2.Models.UIModel" => mvz2.models.UIModel,
		"MVZ2.Models.WitherArmor" => mvz2.models.WitherArmor,
		// 其它命名空间里也会出现在模型 prefab 上的脚本
		"MVZ2.Localization.SpriteRendererTranslator" => mvz2.localization.SpriteRendererTranslator,
		"MVZ2.UI.ElementList" => mvz2.ui.ElementList,
		"Tools.PositionParabola" => tools.PositionParabola,
	];

	/** 从导出数据里取组件类。 */
	public static function GetClass(rec:ModelPrefabComponent):Null<Class<Dynamic>> {
		if (rec == null)
			return null;
		if (rec.type == "MonoBehaviour") {
			if (rec.script == null)
				return null;
			return ScriptClasses.get(rec.script);
		}
		return BuiltinClasses.get(rec.type);
	}
}
