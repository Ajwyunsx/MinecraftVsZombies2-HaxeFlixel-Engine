// Ported from: (新增文件) 按导出的 prefab 数据给「手工构造的」组件补 [SerializeField] 字段
package mvz2.scenes;

import mvz2.models.ModelPrefabContext;
import mvz2.scenes.ScenePrefabData;
import mvz2.scenes.ScenePrefabData.ScenePrefabComponent;
import mvz2.scenes.ScenePrefabData.ScenePrefabFile;
import unity.Component;
import unity.Debug;
import unity.GameObject;
import unity.Vector2;
import unity.Vector3;

// PORT-NOTE: 本文件是移植层新增的「prefab 字段定向注入」，没有 C# 对应源码。
//
// 背景：Unity 里关卡/UI 组件的 `[SerializeField]` 字段由 prefab 注入。移植层有两类构造方式：
//   1. **从 prefab 数据重建整棵树**（`ScenePrefabLoader.InstantiateKey`）：字段在重建时自动写入，
//      不需要本文件；
//   2. **手工构造的对象图**（启动链路的 `MainGameScene`、关卡构建里的单点对象）：这些对象没有
//      经过数据重建，字段停在声明初值。本文件为它们提供「按导出数据定向注入」的入口，
//      语义等价于 Unity 的 prefab 注入，且**不改动任何 states/ 代码**。
//
// 定位方式与 Unity 的对应关系：
//   * `prefabKey` = 导出数据的 key（场景名 "Main"/"Level"，或 "Prefabs/Level/Grid" 这类路径）；
//   * `script`    = C# 全名（如 "MVZ2.Grids.GridController"）；
//   * `nodeName`  = prefab 里的 GameObject 名（同名多实例时用 `occurrence` 选第几个）。
@:access(mvz2.grids.GridController)
@:access(mvz2.ui.level.LevelUIPreset)
@:access(mvz2.cameras.LevelCamera)
@:access(mvz2.level.PoolColorSetter)
@:access(mvz2.ui.DragMover)
@:access(mvz2.ui.level.HintArrow)
@:access(mvz2.models.LightController)
@:access(mvz2.map.MapController)
class ScenePrefabInjector {
	/** 注入结果（诊断用）。 */
	public static var injectedFields:Int = 0;
	public static var missingTargets:Array<String> = [];

	/**
	 * 按 GameObject 名 + 脚本名在 prefab 数据里定位组件，并写入它的全部序列化字段。
	 *
	 * @param target    要注入的组件实例（必须已挂在 GameObject 上）。
	 * @param prefabKey 导出数据的 key。
	 * @param script    C# 全名（或 Unity 包类型全名）。
	 * @param nodeName  GameObject 名；null = 不限名字。
	 * @param occurrence 同名/同脚本的第几个（0 起）。
	 * @return 写入的字段数；找不到目标时返回 -1 并记入 missingTargets。
	 */
	public static function Apply(target:Component, prefabKey:String, script:String, ?nodeName:String,
			?occurrence:Int = 0):Int {
		var data = ScenePrefabLoader.LoadData(prefabKey);
		if (data == null) {
			missingTargets.push('$prefabKey（数据未转换）');
			return -1;
		}
		var seen = 0;
		var ctx = new ModelPrefabContext(cast data);
		// 引用解析需要一份「节点下标 -> 真实对象」的表。这里注入的目标是外部对象，
		// 数据里的图内引用（{n,c}）没有对应的真实对象，因此只保留可用的部分：
		// 结构体/标量正常解码，图内引用解码为 null（调用方按 null 处理，与 C# 缺引用一致）。
		for (i in 0...data.nodes.length) {
			var node = data.nodes[i];
			if (nodeName != null && node.name != nodeName)
				continue;
			for (ci in 0...node.components.length) {
				var rec = node.components[ci];
				if (rec.type != "MonoBehaviour" || rec.script != script)
					continue;
				if (seen < occurrence) {
					seen++;
					continue;
				}
				var missing = ScenePrefabFieldApplier.Apply(target, rec, ctx);
				var count = rec.fields == null ? 0 : Reflect.fields(rec.fields).length;
				if (missing != null)
					count -= missing.length;
				injectedFields += count;
				return count;
			}
		}
		missingTargets.push('$prefabKey/$nodeName/$script#$occurrence');
		return -1;
	}

	// #region 整棵对象图的注入（把「手工构造的对象图」接上 prefab 数据）
	/**
	 * 把导出的场景/prefab 数据按**名字层级**灌进一棵已存在的对象图。
	 *
	 * 这是「手工构造对象图」（如启动链路的 `MainGameScene`）与「prefab 数据」之间的桥：
	 * 逐个匹配节点名 -> 逐个匹配组件类型 -> 用 `ScenePrefabFieldApplier` 写字段，
	 * 并把数据里的图内引用（`{n,c}`）**重映射到运行期对象**（不是新造对象）。
	 * 语义等价于 Unity 用 prefab 覆盖场景里已存在的对象。
	 *
	 * @param root     运行期对象图的根（名字应与数据里的根节点名一致）。
	 * @param prefabKey 导出数据的 key（场景名 "Main"/"Level"，或 "Prefabs/..." 路径）。
	 * @return 实际写入的字段数（-1 = 数据不存在）。
	 */
	public static function ApplyTree(root:GameObject, prefabKey:String):Int {
		if (root == null)
			return -1;
		var data = ScenePrefabLoader.LoadData(prefabKey);
		if (data == null) {
			missingTargets.push('$prefabKey（数据未转换）');
			return -1;
		}
		if (data.nodes == null || data.nodes.length == 0)
			return -1;

		// 1) 建立「导出节点下标 -> 运行期 GameObject」的映射（按名字层级递归匹配）。
		var nodeToObject:Array<GameObject> = [];
		nodeToObject.resize(data.nodes.length);
		var matched = 0;
		for (rootIndex in data.roots) {
			if (rootIndex < 0 || rootIndex >= data.nodes.length)
				continue;
			nodeToObject[rootIndex] = root;
			matched += matchChildren(data, rootIndex, root, nodeToObject);
		}

		// 2) 建立解码上下文：把 {n,c} 解析到运行期对象。
		var ctx = new ModelPrefabContext(cast data);
		ctx.gameObjects = nodeToObject;
		ctx.components = [];
		for (i in 0...data.nodes.length) {
			var go = nodeToObject[i];
			var list:Array<Component> = [];
			if (go != null) {
				list.push(go.transform);
				var used:Array<Component> = [];
				for (rec in data.nodes[i].components) {
					var comp = findRuntimeComponent(go, rec, used);
					if (comp != null)
						used.push(comp);
					list.push(comp);
				}
			}
			ctx.components.push(list);
		}

		// 3) 逐节点写字段。
		var count = 0;
		for (i in 0...data.nodes.length) {
			var go = nodeToObject[i];
			if (go == null)
				continue;
			var node = data.nodes[i];
			for (ci in 0...node.components.length) {
				var comp = ctx.components[i][ci + 1];
				if (comp == null)
					continue;
				var rec = node.components[ci];
				var missing = ScenePrefabFieldApplier.Apply(comp, rec, ctx);
				var fields = rec.fields == null ? 0 : Reflect.fields(rec.fields).length;
				if (missing != null)
					fields -= missing.length;
				if (fields > 0)
					count += fields;
				var label = rec.script != null ? rec.script : rec.type;
				if (missing != null) {
					for (field in missing) {
						var key = label + "." + field;
						if (!missingFields.exists(key))
							missingFields.set(key, 1);
					}
				}
			}
		}
		injectedFields += count;
		if (matched < data.nodes.length)
			unmatchedNodes += data.nodes.length - matched;
		return count;
	}

	/** 数据里有、运行期对象图里没匹配上的节点数（诊断用）。 */
	public static var unmatchedNodes:Int = 0;
	/** 数据里有、运行期组件上写不进去的字段 -> 出现次数。 */
	public static var missingFields:Map<String, Int> = new Map();

	/** 按子节点名递归匹配（同名子节点按出现顺序配对）。 */
	private static function matchChildren(data:ScenePrefabFile, index:Int, go:GameObject,
			nodeToObject:Array<GameObject>):Int {
		var matched = 0;
		var children = data.nodes[index].children;
		if (children == null || children.length == 0)
			return 0;
		var runtimeChildren = go.transform.children;
		var used:Array<Bool> = [for (_ in runtimeChildren) false];
		for (childIndex in children) {
			if (childIndex < 0 || childIndex >= data.nodes.length)
				continue;
			var childName = data.nodes[childIndex].name;
			var target:GameObject = null;
			for (i in 0...runtimeChildren.length) {
				if (used[i])
					continue;
				if (runtimeChildren[i].gameObject.name == childName) {
					target = runtimeChildren[i].gameObject;
					used[i] = true;
					break;
				}
			}
			if (target == null)
				continue;
			nodeToObject[childIndex] = target;
			matched += 1 + matchChildren(data, childIndex, target, nodeToObject);
		}
		return matched;
	}

	/** 在运行期 GameObject 上按导出记录的类型找组件（同名多实例按 used 顺序配对）。 */
	private static function findRuntimeComponent(go:GameObject, rec:ScenePrefabComponent,
			used:Array<Component>):Null<Component> {
		var cls = ScenePrefabComponentTypes.GetClass(rec);
		if (cls == null)
			return null;
		for (comp in go.GetAllComponents()) {
			if (used.indexOf(comp) >= 0)
				continue;
			if (Std.isOfType(comp, cls))
				return comp;
		}
		return null;
	}
	// #endregion

	// #region 优先字段（工作包 ② 的 ③ 项）
	/**
	 * `GridController.size`。
	 *
	 * C#：`Assets/Scripts/MVZ2/Grids/GridController.cs:236` `[SerializeField] private Vector2 size;`
	 * 真值：`Assets/Prefabs/Level/Grid.prefab` 的 `size: {x: 0.8, y: 0.8}`（Lane.prefab 的
	 * ElementList 以它为模板，所以每个格子的 size 都是 (0.8, 0.8)）。
	 *
	 * 不注入的后果：`SetDisplaySection`/`SetColliderBevel` 拿到零尺寸，
	 * `TransformWorld2ColliderPosition` 的 `slope = BevelHeight / size.x` 除零（Inf/NaN），
	 * 格子拾取判定全错。
	 */
	public static function ApplyGridSize(grid:mvz2.grids.GridController):Bool {
		var value = ReadVector2("Prefabs/Level/Grid", "MVZ2.Grids.GridController", "size");
		if (value == null)
			return false;
		grid.size = value;
		injectedFields++;
		return true;
	}

	/**
	 * `LevelUIPreset` 的 hintArrow 4 个 offset + 4 个 angle。
	 *
	 * C#：`Assets/Scripts/View/Level/LevelUIPreset.cs`（8 个 `[SerializeField]`）。
	 * 真值：`Assets/Prefabs/Level/UI/UIPreset.prefab`，但**场景里实际生效的是
	 * `Level.prefab` 的实例覆盖值**（standalone 与 mobile 不同），所以这里按节点名
	 * （UIPresetStandalone / UIPresetMobile）从 "Level" 数据取。
	 *
	 * 不注入的后果：`LevelUIPreset.hx:283/289/295/301` 的
	 * `hintArrow.SetTarget(target, offset*0.01, angle)` 全部用 (0,0) 与 0 度，
	 * 提示箭头指向错误位置/朝向（Starshard 的 180 度尤其明显）。
	 */
	public static function ApplyLevelUIPreset(preset:mvz2.ui.level.LevelUIPreset, mobile:Bool):Bool {
		var nodeName = mobile ? "UIPresetMobile" : "UIPresetStandalone";
		var data = ScenePrefabLoader.LoadData("Level");
		if (data == null)
			return false;
		var ctx = new ModelPrefabContext(cast data);
		for (node in data.nodes) {
			if (node.name != nodeName)
				continue;
			for (rec in node.components) {
				if (rec.type != "MonoBehaviour" || rec.script != "MVZ2.UI.Level.LevelUIPreset")
					continue;
				var fields = rec.fields;
				if (fields == null)
					continue;
				preset.hintArrowOffsetBlueprint = readStruct(fields, "hintArrowOffsetBlueprint", preset.hintArrowOffsetBlueprint);
				preset.hintArrowOffsetPickaxe = readStruct(fields, "hintArrowOffsetPickaxe", preset.hintArrowOffsetPickaxe);
				preset.hintArrowOffsetStarshard = readStruct(fields, "hintArrowOffsetStarshard", preset.hintArrowOffsetStarshard);
				preset.hintArrowOffsetTrigger = readStruct(fields, "hintArrowOffsetTrigger", preset.hintArrowOffsetTrigger);
				preset.hintArrowAngleBlueprint = readFloat(fields, "hintArrowAngleBlueprint", preset.hintArrowAngleBlueprint);
				preset.hintArrowAnglePickaxe = readFloat(fields, "hintArrowAnglePickaxe", preset.hintArrowAnglePickaxe);
				preset.hintArrowAngleStarshard = readFloat(fields, "hintArrowAngleStarshard", preset.hintArrowAngleStarshard);
				preset.hintArrowAngleTrigger = readFloat(fields, "hintArrowAngleTrigger", preset.hintArrowAngleTrigger);
				injectedFields += 8;
				return true;
			}
		}
		missingTargets.push('Level/$nodeName/MVZ2.UI.Level.LevelUIPreset');
		return false;
	}

	/**
	 * `LevelCamera.cameraAnchor` / `cameraPosition`。
	 *
	 * C#：`Assets/Scripts/MVZ2/Cameras/LevelCamera.cs:87-90`（两者都是 `[SerializeField]`）。
	 * 真值：`Assets/Prefabs/Level/Level.prefab` 的 `cameraAnchor: {x: 0, y: 0.5}`、
	 * `cameraPosition: {x: 0, y: 3, z: -10}`。
	 *
	 * PORT-NOTE: `cameraShakeOffset`（`:91`）**没有** `[SerializeField]`，C# 初值就是
	 * `Vector3.zero`，只能由 `ShakeOffset` setter 写入 —— 所以它没有 prefab 真值，
	 * 移植层的零值初始化已经是正确行为（工作包 ② 的任务描述里把它列为「优先拿真值」，
	 * 实测确认它本就不该有 prefab 值，见 tools_build/scene_pipeline_findings.md §3.3）。
	 *
	 * 注意：`LevelController.SetCameraPosition` 会用 C# 自带初值的
	 * cameraHouse/Lawn/Choose 覆盖这两个字段，所以只有在关卡尚未调用 SetCameraPosition 时
	 * 才看得出差别；注入它主要是保证 `OnEnable`/`Update` 里的 `UpdatePosition()`
	 * 在第一次 SetCameraPosition 之前不会把相机放到原点。
	 */
	public static function ApplyLevelCamera(camera:mvz2.cameras.LevelCamera):Bool {
		var anchor = ReadVector2("Level", "MVZ2.Cameras.LevelCamera", "cameraAnchor");
		var position = ReadVector3("Level", "MVZ2.Cameras.LevelCamera", "cameraPosition");
		if (anchor == null && position == null)
			return false;
		if (anchor != null)
			camera.cameraAnchor = anchor;
		if (position != null)
			camera.cameraPosition = position;
		injectedFields += (anchor != null ? 1 : 0) + (position != null ? 1 : 0);
		return true;
	}

	/**
	 * `MapController.mapCamera`（以及同 prefab 的其余引用）。
	 *
	 * C#：`Assets/Scripts/MVZ2/Map/MapController.cs` 的 `[SerializeField] private Camera mapCamera`。
	 * 真值：`Assets/Prefabs/Map/Map.json` 节点 14（`Map`）的 `mapCamera: {n: 7, c: 1}`
	 * —— 指向节点 7 `Camera` 上的 `Camera` 组件。
	 *
	 * 不注入的后果（本轮实测的 release 卡点）：`GameEntrance.StartGame → DisplayPage(Splash) →
	 * MapController.Hide → SetCameraBackgroundColor` 的 `mapCamera.backgroundColor` 空引用
	 * （`mvz2/map/MapController.hx:299`），release 下是直接访问违例。
	 *
	 * 优先用「重建整棵树」的方式（`ScenePrefabLoader.InstantiateInto`，页面根接管），
	 * 这样同 prefab 的 `ui` / `mapCameraShakeRoot` / `modelRoot` / `raycastHitbox` 也一并注入；
	 * 只有在数据缺失时才退回「只补 mapCamera」的保守路径。
	 */
	public static function ApplyMapPage(pageRoot:GameObject):Bool {
		if (pageRoot == null)
			return false;
		var written = ScenePrefabLoader.InstantiateInto("Prefabs/Map/Map", pageRoot, null, false);
		if (written >= 0) {
			injectedFields += written;
			return true;
		}
		return false;
	}

	/**
	 * `MapController.mapCamera` 的保守兜底：只在页面的子树里找一个 `unity.Camera` 组件。
	 *
	 * PORT-NOTE: 与 `ApplyMapPage` 的差别是不重建任何节点，仅解掉空引用。数据缺失时用它保命。
	 */
	public static function ApplyMapCameraFallback(controller:mvz2.map.MapController):Bool {
		if (controller == null || controller.gameObject == null)
			return false;
		var camera = controller.gameObject.GetComponentInChildren(unity.Camera, true);
		if (camera == null)
			return false;
		controller.mapCamera = camera;
		injectedFields++;
		return true;
	}
	// #endregion

	// #region 读取辅助
	/** 在 prefab 数据里读一个 Vector2 字段（找不到返回 null）。 */
	public static function ReadVector2(prefabKey:String, script:String, field:String, ?nodeName:String):Null<Vector2> {
		var value = readStructRaw(prefabKey, script, field, nodeName);
		return value == null ? null : new Vector2(value.x, value.y);
	}
	public static function ReadVector3(prefabKey:String, script:String, field:String, ?nodeName:String):Null<Vector3> {
		var value = readStructRaw(prefabKey, script, field, nodeName);
		return value == null ? null : new Vector3(value.x, value.y, value.z);
	}
	private static function readStructRaw(prefabKey:String, script:String, field:String, ?nodeName:String):Null<Vector3> {
		var data = ScenePrefabLoader.LoadData(prefabKey);
		if (data == null)
			return null;
		var ctx = new ModelPrefabContext(cast data);
		for (node in data.nodes) {
			if (nodeName != null && node.name != nodeName)
				continue;
			for (rec in node.components) {
				if (rec.type != "MonoBehaviour" || rec.script != script)
					continue;
				var fields = rec.fields;
				if (fields == null || !Reflect.hasField(fields, field))
					continue;
				var decoded:Dynamic = ctx.decode(Reflect.field(fields, field), null);
				if (decoded == null)
					continue;
				return switch (Type.typeof(decoded)) {
					case TClass(c):
						if (c == unity.Vector2Data)
							new Vector3((cast decoded:Vector2).x, (cast decoded:Vector2).y, 0);
						else if (c == unity.Vector3Data)
							cast decoded;
						else
							null;
					default: null;
				}
			}
		}
		return null;
	}
	private static function readStruct(fields:Dynamic, name:String, current:Vector2):Vector2 {
		if (!Reflect.hasField(fields, name))
			return current;
		var raw:Dynamic = Reflect.field(fields, name);
		if (raw == null || !Reflect.hasField(raw, "v"))
			return current;
		var v:Array<Float> = Reflect.field(raw, "v");
		if (v == null || v.length < 2)
			return current;
		return new Vector2(v[0], v[1]);
	}
	private static function readFloat(fields:Dynamic, name:String, current:Float):Float {
		if (!Reflect.hasField(fields, name))
			return current;
		var raw:Dynamic = Reflect.field(fields, name);
		return raw == null ? current : (raw:Float);
	}
	// #endregion

	public static function ResetStats():Void {
		injectedFields = 0;
		missingTargets = [];
		unmatchedNodes = 0;
		missingFields.clear();
	}
}
