// Ported from: (新增文件) 模型 prefab 管线的运行期自检（工作包 ⑤）
package models;

import mvz2.models.EntityModel;
import mvz2.models.Model;
import mvz2.models.ModelAnchor;
import mvz2.models.ModelPrefabAssets;
import mvz2.models.ModelPrefabLoader;
import unity.SpriteRenderer;
import unity.Transform;

/**
 * ModelPrefabLoader 的运行期自检：用 build_models.py 导出的真实数据重建若干代表性模型，
 * 校验节点/组件/引用/锚点/资源引用是否按预期还原。
 *
 * 用法（在 HaxePort/ 下，先跑过 tools_build/build_models.py）：
 *
 *   haxe -cp source -cp verify -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl \
 *     -lib hscript -lib hxjsonast -lib json2object -main models.ModelPrefabSmokeMain \
 *     -cpp /tmp/model_smoke -D lime_use_old_deltatime \
 *     --macro "flixel.system.macros.FlxDefines.run()"
 *   # 然后以 HaxePort/ 为工作目录运行产物（资源路径是相对的 assets/）
 *   /tmp/model_smoke/ModelPrefabSmokeMain-debug.exe
 *
 * PORT-NOTE: 当前 `haxelib run lime build windows` 因若干**其它包**的
 * “On static platforms, null can't be used as basic type Bool/Float”类型错误而失败
 * （mvz2/io/XMLHelper.hx 的 GetAttributeBool 返回 null 却声明为 Bool，以及 mvz2/metas/* 里
 * 同类写法），并且 hxcpp 的类静态初始化会在 `Global.BuiltinNamespace` 未就绪时抛
 * Null Object Reference（mvz2/level/components/*.hx 的 componentID 静态字段）。
 * 因此本地跑本自检时，需要在一份**源码副本**上先修掉这两处（或等对应工作包修好），
 * 本文件本身不依赖它们，只是被同一个编译单元牵连。
 */
class ModelPrefabSmokeMain {
	static var checked:Int = 0;
	static var failures:Array<String> = [];

	public static function main() {
		Sys.println('dataPath=' + unity.Application.dataPath);
		var ids = [
			"mvz2:contraption/prologue/dispenser",
			"mvz2:enemy/prologue/zombie",
			"mvz2:boss/red_dragon",
			"mvz2:grid/placeholder",
			"mvz2:effect/pow",
			"mvz2:held/sword",
		];
		var manifest = ModelPrefabLoader.GetManifest();
		if (manifest == null) {
			Sys.println("FAIL: 清单加载失败");
			for (warning in ModelPrefabLoader.loadWarnings)
				Sys.println("  " + warning);
			Sys.exit(1);
		}
		Sys.println('manifest: version=${manifest.version} count=${manifest.count} 条目=${manifest.models.length}');
		for (id in ids) {
			var entry = ModelPrefabLoader.GetEntry(id);
			if (entry == null) {
				Sys.println('  SKIP $id（清单里没有）');
				continue;
			}
			ModelPrefabLoader.ResetStats();
			ModelPrefabAssets.ResetStats();
			var root = ModelPrefabLoader.Instantiate(id);
			if (root == null) {
				failures.push('$id：实例化失败');
				continue;
			}
			checked++;
			var nodes = collect(root.transform);
			var sprites = 0;
			var anchors = 0;
			var components = 0;
			for (t in nodes) {
				components += t.gameObject.GetAllComponents().length;
				if (t.gameObject.GetComponent(SpriteRenderer) != null)
					sprites++;
				if (t.gameObject.GetComponent(ModelAnchor) != null)
					anchors++;
			}
			var model:Model = root.GetComponent(Model);
			if (model == null)
				failures.push('$id：根节点上没有 Model 组件');
			var group = model == null ? null : model.GraphicGroup;
			if (group == null)
				failures.push('$id：Model.GraphicGroup 为空');
			var anchorNames:Array<String> = [];
			if (group != null) {
				for (anchor in group.GetAllAnchors()) {
					if (anchor != null && anchor.key != null)
						anchorNames.push(anchor.key);
				}
			}
			var found:Array<String> = [];
			if (group != null) {
				for (key in ["center", "root", "main", "armor", "head", "shield", "shield_hands"]) {
					var anchor = group.GetAnchor(key);
					if (anchor != null && anchor.key == key)
						found.push(key);
				}
				if (anchorNames.length > 0 && found.length == 0)
					failures.push('$id：有锚点但 GetAnchor 按 key 都查不到（哈希/字段写入有问题）');
				if (group.GetAnimatorElement("main") == null)
					failures.push('$id：找不到名为 main 的 AnimatorElement');
			}
			Sys.println('  OK $id: 节点=${nodes.length} 组件=$components 精灵=$sprites 锚点=$anchors '
				+ 'Model=${model != null} 名称=${root.name}');
			Sys.println('       anchors=[${anchorNames.join(",")}] GetAnchor命中=[${found.join(",")}]');
			if (Std.isOfType(model, EntityModel)) {
				var entityModel:EntityModel = cast model;
				Sys.println('       collider=${entityModel.Collider} sortingOrder=${entityModel.SortingOrder}');
				if (entityModel.Collider == null)
					failures.push('$id：EntityModel.modelCollider 为空');
			}
			Sys.println('       资产引用：成功=${ModelPrefabAssets.resolvedCount} 失败=${ModelPrefabAssets.unresolvedCount}');
			for (warning in ModelPrefabLoader.loadWarnings)
				Sys.println('       告警：' + warning);
			var unknown:Array<String> = [for (k in ModelPrefabLoader.unknownComponents.keys()) k];
			if (unknown.length > 0)
				Sys.println('       未知组件类型：' + unknown.join(","));
		}
		Sys.println('自检完成：通过 $checked 个，失败 ${failures.length} 个');
		for (failure in failures)
			Sys.println('  FAIL ' + failure);
		Sys.exit(failures.length == 0 ? 0 : 1);
	}

	static function fail(message:String):Void {
		failures.push(message);
	}

	static function collect(transform:Transform):Array<Transform> {
		var result = [transform];
		for (child in transform.children)
			result = result.concat(collect(child));
		return result;
	}
}
