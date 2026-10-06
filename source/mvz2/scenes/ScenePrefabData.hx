// Ported from: (新增文件) HaxePort/tools_build/build_scene.py 的输出格式
package mvz2.scenes;

// PORT-NOTE: ModelPrefabTransform 是 mvz2.models.ModelPrefabData 模块内的 typedef，
// 跨模块引用必须显式 import 次类型（与 mvz2.grids.LaneController 导入 GridInitData 同理）。
import mvz2.models.ModelPrefabData.ModelPrefabTransform;

// PORT-NOTE: 本文件是移植层新增的「场景/prefab 序列化数据」类型定义，没有 C# 对应源码。
//
// Unity 侧关卡与 UI 由 `Assets/GameContent/Scenes/{Main,Level}.unity` 里的 prefab 实例反序列化
// 建立对象图，组件的 `[SerializeField]` 字段由 prefab 注入。移植层没有 Unity 资产系统，改由
// `tools_build/build_scene.py` 把场景与 `Assets/Prefabs/**` 的 prefab（含嵌套 PrefabInstance、
// 变体覆盖、删除项）合并导出成下述 JSON，运行期由 `ScenePrefabLoader` 重建 GameObject 层级。
//
// 编码约定与 `mvz2.models.ModelPrefabData` **完全一致**（同一个转换器内核 + 同一套解码器）：
//   * 标量/字符串/布尔 = JSON 原生值
//   * Unity 结构体 = {t:"Vector3", v:[x,y,z]}
//   * 图内引用 = {n:节点下标[, c:组件下标]}：c 缺省 = GameObject，c==0 = Transform，
//                c==k+1 = 该节点 components[k]
//   * 图外资产 = {asset:{guid, fileID(字符串), path, source, address, kind}}
//   * null 引用（fileID: 0）= null

typedef ScenePrefabComponent = {
	/** Unity 组件类名（GameObject 上 m_Component 的顺序保留）；MonoBehaviour 一律写 "MonoBehaviour"。 */
	var type:String;
	/** MonoBehaviour 的 C# 全名，例如 MVZ2.Grids.GridController 或 UnityEngine.UI.Image。 */
	@:optional var script:String;
	/** 脚本源文件路径（诊断用；Unity 包内置组件写 "(Unity 包内置组件)"）。 */
	@:optional var scriptPath:String;
	/** 脚本对应的 Haxe 全限定类名（由 namespace 小写映射得到，诊断用）。 */
	@:optional var haxe:String;
	/** 序列化字段（名字与 C# 字段一致；Unity 头字段已剔除）。 */
	var fields:Dynamic;
}

typedef ScenePrefabNode = {
	var name:String;
	var active:Bool;
	var layer:Int;
	/** 父节点下标；null = 顶层。 */
	var parent:Null<Int>;
	var children:Array<Int>;
	var transform:mvz2.models.ModelPrefabTransform;
	var components:Array<ScenePrefabComponent>;
}

typedef ScenePrefabFile = {
	var version:Int;
	/** 场景名（Main / Level）或 prefab 的 key（相对 Assets 的路径去扩展名）。 */
	var key:String;
	/** "scene" 或 "prefab"。 */
	var kind:String;
	/** 镜像路径（相对 assets）。 */
	@:optional var asset:String;
	/** Unity 工程内路径。 */
	var source:String;
	var guid:String;
	/** 顶层节点下标（Unity 的 prefab 只有一个根）。 */
	var roots:Array<Int>;
	var nodes:Array<ScenePrefabNode>;
	var warnings:Array<String>;
}

/** scene_manifest.json 里的单个场景条目。 */
typedef SceneManifestScene = {
	var key:String;
	var kind:String;
	var asset:String;
	var source:String;
	var guid:String;
	/** 分文件数据路径（相对 assets）。 */
	var data:String;
	var nodeCount:Int;
	var componentCount:Int;
	var rootCount:Int;
	/** 场景根指向的 prefab（镜像路径 / 工程内路径）。 */
	@:optional var prefab:String;
	@:optional var prefabSource:String;
	@:optional var name:String;
	@:optional var danglingRefs:Int;
	@:optional var recoveredRefs:Int;
	@:optional var strayRoots:Int;
	@:optional var unsupportedComponents:Array<String>;
	@:optional var warnings:Array<String>;
}

/** scene_manifest.json 里的单个 prefab 条目。 */
typedef SceneManifestPrefab = {
	var key:String;
	var kind:String;
	var asset:String;
	var source:String;
	var guid:String;
	var data:String;
	var nodeCount:Int;
	var componentCount:Int;
	var rootCount:Int;
	@:optional var danglingRefs:Int;
	@:optional var recoveredRefs:Int;
	@:optional var strayRoots:Int;
	@:optional var unsupportedComponents:Array<String>;
	@:optional var warnings:Array<String>;
}

typedef SceneManifest = {
	var version:Int;
	var assetsRoot:String;
	var dataDir:String;
	/**
	 * 条目数组（元素自带 key）。
	 *
	 * PORT-NOTE: 导出时用数组而不是 JSON 对象——Haxe 侧 Json.parse 得到的是匿名对象，
	 * 不是 haxe.ds.StringMap，直接当 Map 用会在静态目标上运行期报错；
	 * ScenePrefabLoader 在加载时自行建立 key -> 条目的索引。
	 */
	var scenes:Array<SceneManifestScene>;
	var prefabs:Array<SceneManifestPrefab>;
	var stats:Dynamic;
	@:optional var unmappedFields:Dynamic;
	@:optional var warnings:Array<String>;
}
