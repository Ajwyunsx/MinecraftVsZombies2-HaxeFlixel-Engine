// Ported from: (新增文件) HaxePort/tools_build/build_models.py 的输出格式
package mvz2.models;

// PORT-NOTE: Unity 的模型是 prefab 资产（GameObject 层级 + 组件序列化字段），C# 侧由
// ResourceManager.GetModel() 取到 prefab、GameObject.Instantiate 克隆、Model.Init() 初始化
// （见 Assets/Scripts/MVZ2/Models/Utilities/ModelBuilder.cs）。移植层没有 prefab 资产，
// 改由 tools_build/build_models.py 把 prefab（含嵌套 PrefabInstance、变体覆盖、删除项）
// 合并导出成下述 JSON，运行期由 ModelPrefabLoader 重建 GameObject 层级。
//
// 字段编码约定（与 build_models.py 头部注释一一对应）：
//   * 标量/字符串/布尔 = JSON 原生值
//   * Unity 结构体 = {t:"Vector3", v:[x,y,z]}（v 的分量顺序见脚本；浮点已保证是 Float）
//   * 图内引用 = {n:节点下标[, c:组件下标]}：c 缺省 = GameObject 本身，c==0 = Transform，
//                c==k+1 = 该节点 components[k]
//   * 图外资产 = {asset:{guid, fileID(字符串，避免 19 位整数丢精度), path, source, address, kind}}

typedef ModelPrefabStruct = {
	/** Unity 结构体类型名：Vector2 / Vector3 / Vector4 / Color / Rect。 */
	var t:String;
	/** 按 Unity 字段顺序排列的分量。 */
	var v:Array<Float>;
}

typedef ModelPrefabAssetRef = {
	@:optional var guid:String;
	/** Unity fileID（字符串形式；子资源用，例如贴图里的某一帧精灵）。 */
	@:optional var fileID:String;
	/** 相对 HaxePort/assets 的路径（镜像后的资源文件）。 */
	@:optional var path:String;
	/** Unity 工程内路径（Assets/...）。 */
	@:optional var source:String;
	/** Addressables 地址（若有）。 */
	@:optional var address:String;
	/** 资产种类：Image / AnimatorController / Material / Model / Font / Other ... */
	@:optional var kind:String;
}

typedef ModelPrefabObjectRef = {
	/** 节点下标。 */
	var n:Int;
	/** 组件下标：缺省/Null = GameObject；0 = Transform；k+1 = components[k]。 */
	@:optional var c:Null<Int>;
}

typedef ModelPrefabComponent = {
	/** Unity 组件类名（GameObject 上 m_Component 的顺序保留）。 */
	var type:String;
	/** MonoBehaviour 的 C# 全名，例如 MVZ2.Models.ModelAnchor。 */
	@:optional var script:String;
	/** 脚本源文件路径（诊断用）。 */
	@:optional var scriptPath:String;
	/** 脚本对应的 Haxe 全限定类名（由 namespace 小写映射得到，诊断用）。 */
	@:optional var haxe:String;
	/** 序列化字段（名字与 C# 字段一致；Unity 头字段已剔除）。 */
	var fields:Dynamic;
}

typedef ModelPrefabRectTransform = {
	var anchoredPosition:Array<Float>;
	var sizeDelta:Array<Float>;
	var anchorMin:Array<Float>;
	var anchorMax:Array<Float>;
	var pivot:Array<Float>;
}

typedef ModelPrefabTransform = {
	/** m_LocalPosition。 */
	var pos:Array<Float>;
	/** m_LocalRotation（x,y,z,w）。 */
	var rot:Array<Float>;
	/** m_LocalScale。 */
	var scale:Array<Float>;
	/** m_LocalEulerAnglesHint（Unity 只在编辑器里用，重建时仅记录）。 */
	var hint:Array<Float>;
	/** 仅 RectTransform 节点有。 */
	@:optional var rect:ModelPrefabRectTransform;
}

typedef ModelPrefabNode = {
	var name:String;
	var active:Bool;
	var layer:Int;
	/** 父节点下标；null = 顶层。 */
	var parent:Null<Int>;
	var children:Array<Int>;
	var transform:ModelPrefabTransform;
	var components:Array<ModelPrefabComponent>;
}

typedef ModelPrefabFile = {
	var version:Int;
	/** 模型 id（NamespaceID，例如 mvz2:contraption/prologue/dispenser）。 */
	var model:String;
	/** 镜像路径（相对 assets）。 */
	var asset:String;
	/** prefab 资产的 GUID。 */
	var guid:String;
	var labels:Array<String>;
	/** 顶层节点下标（正常只有一个）。 */
	var roots:Array<Int>;
	var nodes:Array<ModelPrefabNode>;
	var warnings:Array<String>;
}

/** models_manifest.json 里的单个模型条目（对应 C# ModelMeta + 转换信息）。 */
typedef ModelPrefabManifestEntry = {
	var id:String;
	var type:String;
	var name:String;
	var metaId:String;
	var shot:Bool;
	var width:Int;
	var height:Int;
	var xOffset:Float;
	var yOffset:Float;
	@:optional var armorConfig:String;
	var animatorUpdateOnShot:Bool;
	var animatorParameters:Array<Dynamic>;
	var properties:Dynamic;
	/** 转换失败时会有 error（此时没有 prefab 字段）。 */
	@:optional var error:String;
	@:optional var prefab:ModelPrefabManifestPrefab;
	@:optional var danglingRefs:Int;
	@:optional var recoveredRefs:Int;
	@:optional var orphanRoots:Int;
	@:optional var unsupportedComponents:Array<String>;
	@:optional var warnings:Array<String>;
}

typedef ModelPrefabManifestPrefab = {
	/** 镜像路径。 */
	var asset:String;
	/** Unity 工程内路径。 */
	var source:String;
	var guid:String;
	var labels:Array<String>;
	var group:String;
	/** 分文件数据路径（相对 assets）。 */
	var data:String;
	var nodeCount:Int;
	var componentCount:Int;
	var rootCount:Int;
}

typedef ModelPrefabManifest = {
	var version:Int;
	var namespace:String;
	var assetsRoot:String;
	var armorConfigs:Array<String>;
	/** 成功转换的模型数量。 */
	var count:Int;
	/**
	 * 模型条目数组（元素自带 id）。
	 *
	 * PORT-NOTE: 导出时用数组而不是 JSON 对象——Haxe 侧 Json.parse 得到的是匿名对象，
	 * 不是 haxe.ds.StringMap，直接当 Map 用会在静态目标上运行期报错；
	 * ModelPrefabLoader 在加载时自行建立 id -> 条目的索引。
	 */
	var models:Array<ModelPrefabManifestEntry>;
	var stats:Dynamic;
	var warnings:Array<String>;
}
