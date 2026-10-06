// Ported from: (新增文件) 关卡/UI prefab 序列化数据管线的运行期自检（工作包 ②）
package scenes;

import mvz2.grids.GridController;
import mvz2.scenes.ScenePrefabComponentTypes;
import mvz2.scenes.ScenePrefabFieldApplier;
import mvz2.scenes.ScenePrefabInjector;
import mvz2.scenes.ScenePrefabLoader;
import mvz2.ui.level.LevelUIPreset;
import unity.Camera;
import unity.Canvas;
import unity.Component;
import unity.GameObject;
import unity.SpriteRenderer;
import unity.Transform;
import unity.Vector2;

/**
 * ScenePrefabLoader / ScenePrefabInjector 的运行期自检：用 build_scene.py 导出的真实数据
 * 重建场景与若干 prefab，校验节点/组件/引用与**优先字段**（GridController.size、
 * LevelUIPreset 的 4 个 hintArrow offset、LevelCamera 的 cameraAnchor/cameraPosition）是否还原。
 *
 * 用法（在 HaxePort/ 下，先跑过 tools_build/build_scene.py）：
 *
 *   haxe -cp source -cp verify -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl \
 *     -lib hscript -lib hxjsonast -lib json2object -main scenes.ScenePrefabSmokeMain \
 *     -cpp /tmp/scene_smoke -D lime_use_old_deltatime \
 *     --macro "flixel.system.macros.FlxDefines.run()"
 *   # 然后以 HaxePort/ 为工作目录运行产物（unity.Application.dataPath = "assets"）
 *   /tmp/scene_smoke/ScenePrefabSmokeMain.exe
 */
// PORT-NOTE: 被注入的字段在 C# 里是 private [SerializeField]（Unity 用序列化系统写入），
// 自检要直接读它们来断言，所以显式声明跨类访问（与 ScenePrefabInjector 的同一处理）。
@:access(mvz2.grids.GridController)
@:access(mvz2.ui.level.LevelUIPreset)
@:access(mvz2.cameras.LevelCamera)
class ScenePrefabSmokeMain {
	static var checked:Int = 0;
	static var failures:Array<String> = [];
	static var expected:Int = 0;

	public static function main() {
		Sys.println('dataPath=' + unity.Application.dataPath);
		var manifest = ScenePrefabLoader.GetManifest();
		if (manifest == null) {
			Sys.println("FAIL: 场景清单加载失败");
			for (warning in ScenePrefabLoader.loadWarnings)
				Sys.println("  " + warning);
			Sys.exit(1);
		}
		Sys.println('manifest: version=${manifest.version} 场景=${manifest.scenes.length} prefab=${manifest.prefabs.length}');

		// 1) 清单条目
		check(ScenePrefabLoader.GetSceneEntry("Main") != null, "清单里有 Main 场景");
		check(ScenePrefabLoader.GetSceneEntry("Level") != null, "清单里有 Level 场景");
		check(ScenePrefabLoader.GetPrefabEntry("Prefabs/Level/Grid") != null, "清单里有 Prefabs/Level/Grid");
		check(ScenePrefabLoader.GetPrefabEntry("Prefabs/Level/UI/UIPreset") != null, "清单里有 UIPreset");

		// 2) 小 prefab：Grid（含优先字段 size）
		checkPrefabGrid();

		// 3) 场景 Level：整棵树 + 优先字段
		checkSceneLevel();

		// 4) 场景 Main
		checkSceneMain();

		// 5) 定向注入入口（给手工构造的对象图用）
		checkInjector();

		// 6) 手工对象图 + prefab 数据（ApplyTree）
		checkApplyTree();

		// 7) Map 页面 prefab 接管注入（本轮 release 卡点：mapCamera）
		checkMapPageInjection();

		// 8) 统计
		Sys.println('组件类型表：内置=${Lambda.count(ScenePrefabComponentTypes.BuiltinClasses)} '
			+ '脚本=${Lambda.count(ScenePrefabComponentTypes.ScriptClasses)}');
		Sys.println('自检完成：断言 $expected 条，通过 $checked 条，失败 ${failures.length} 条');
		for (failure in failures)
			Sys.println('  FAIL ' + failure);
		if (ScenePrefabLoader.unknownComponents.keys().hasNext()) {
			Sys.println('未知组件类型（运行期统计）：');
			for (key in ScenePrefabLoader.unknownComponents.keys())
				Sys.println('  $key x${ScenePrefabLoader.unknownComponents.get(key)}');
		}
		if (ScenePrefabLoader.missingFields.keys().hasNext()) {
			Sys.println('数据里有、组件上没有的字段：');
			for (key in ScenePrefabLoader.missingFields.keys())
				Sys.println('  $key');
		}
		for (warning in ScenePrefabLoader.loadWarnings)
			Sys.println('告警：$warning');
		Sys.exit(failures.length == 0 ? 0 : 1);
	}

	static function checkPrefabGrid():Void {
		Sys.println("-- Prefabs/Level/Grid --");
		var root = ScenePrefabLoader.InstantiatePrefab("Prefabs/Level/Grid");
		if (root == null) {
			check(false, "Grid prefab 实例化");
			return;
		}
		check(true, "Grid prefab 实例化");
		var grid = root.GetComponent(GridController);
		check(grid != null, "Grid 根上有 GridController");
		if (grid != null) {
			var size = grid.size;
			check(size.x == 0.8 && size.y == 0.8, 'GridController.size == (0.8, 0.8)（实际 $size）');
			// 注入入口也应给出同样的值。
			check(ScenePrefabInjector.ReadVector2("Prefabs/Level/Grid", "MVZ2.Grids.GridController", "size") != null,
				"ReadVector2 能取到 size");
		}
	}

	/**
	 * 场景 Level：整棵树 + 优先字段。
	 *
	 * PORT-NOTE: 这里用 `callAwakeInInstantiate=false`。关卡组件的 Awake 依赖运行期管理器
	 * （`MainManager.Instance` / `OptionsManager` 等），单独重建场景时它们必然抛异常（实测 8 处）；
	 * Unity 里场景加载是「先反序列化整棵树、再由引擎统一分发 Awake」，本自检只验证**反序列化结果**
	 * （节点/组件/引用/字段），因此按同样顺序：先建树、后由 `AwakeTree` 显式分发（可选）。
	 */
	static function checkSceneLevel():Void {
		Sys.println("-- 场景 Level --");
		var root = ScenePrefabLoader.InstantiateScene("Level", null, false);
		if (root == null) {
			check(false, "Level 场景实例化");
			return;
		}
		check(true, "Level 场景实例化");
		check(root.name == "Level", '场景根名 == "Level"（实际 ${root.name}）');
		var nodes = collect(root.transform);
		check(nodes.length == 972, '节点数 == 972（实际 ${nodes.length}）');
		check(root.transform.children.length > 0, "场景根有子节点");

		// 关卡根上的 LevelController（[SerializeField] 引用在重建时已写入）
		var levelController = root.GetComponent(mvz2.level.LevelController);
		check(levelController != null, "场景根上有 LevelController");

		// GridController.size：从场景数据里重建出来的格子
		var grids = collectComponents(root.transform, GridController);
		check(grids.length >= 1, '场景里至少有 1 个 GridController（实际 ${grids.length}）');
		for (grid in grids) {
			check(grid.size.x == 0.8 && grid.size.y == 0.8,
				'GridController(${grid.gameObject.name}).size == (0.8, 0.8)（实际 ${grid.size}）');
		}

		// LevelUIPreset 的 hintArrow offsets：standalone / mobile 各自的真值
		var presets = collectComponents(root.transform, LevelUIPreset);
		check(presets.length == 2, 'LevelUIPreset 数量 == 2（实际 ${presets.length}）');
		for (preset in presets) {
			var name = preset.gameObject.name;
			if (name == "UIPresetStandalone") {
				checkVec2(preset.hintArrowOffsetBlueprint, 24, -108, "$name.hintArrowOffsetBlueprint");
				checkVec2(preset.hintArrowOffsetPickaxe, 0, -72, "$name.hintArrowOffsetPickaxe");
				checkVec2(preset.hintArrowOffsetStarshard, 0, 72, "$name.hintArrowOffsetStarshard");
				checkVec2(preset.hintArrowOffsetTrigger, 0, -72, "$name.hintArrowOffsetTrigger");
				check(preset.hintArrowAngleStarshard == 180, "$name.hintArrowAngleStarshard == 180");
			} else if (name == "UIPresetMobile") {
				checkVec2(preset.hintArrowOffsetBlueprint, 160, -27.5, "$name.hintArrowOffsetBlueprint");
				checkVec2(preset.hintArrowOffsetPickaxe, 0, 72, "$name.hintArrowOffsetPickaxe");
				check(preset.hintArrowAngleBlueprint == 90, "$name.hintArrowAngleBlueprint == 90");
			} else {
				failures.push('意外的 LevelUIPreset 节点名：$name');
			}
		}

		// LevelCamera 的序列化字段
		var cameras = collectComponents(root.transform, mvz2.cameras.LevelCamera);
		check(cameras.length == 1, 'LevelCamera 数量 == 1（实际 ${cameras.length}）');
		for (camera in cameras) {
			check(camera.CameraAnchor.x == 0 && camera.CameraAnchor.y == 0.5,
				'LevelCamera.cameraAnchor == (0, 0.5)（实际 ${camera.CameraAnchor}）');
			check(camera.CameraPosition.x == 0 && camera.CameraPosition.y == 3 && camera.CameraPosition.z == -10,
				'LevelCamera.cameraPosition == (0, 3, -10)（实际 ${camera.CameraPosition}）');
			check(camera.Camera != null, "LevelCamera._camera 引用已解析（同节点上的 Camera 组件）");
		}
	}

	static function checkSceneMain():Void {
		Sys.println("-- 场景 Main --");
		// 同上：只验证反序列化结果，Awake 由运行期按 MainManager 优先的顺序统一分发。
		var root = ScenePrefabLoader.InstantiateScene("Main", null, false);
		if (root == null) {
			check(false, "Main 场景实例化");
			return;
		}
		check(true, "Main 场景实例化");
		check(root.name == "MainGame", '场景根名 == "MainGame"（场景覆盖了 prefab 的 m_Name；实际 ${root.name}）');
		var nodes = collect(root.transform);
		check(nodes.length == 1798, '节点数 == 1798（实际 ${nodes.length}）');
		var canvases = collectComponents(root.transform, Canvas);
		check(canvases.length > 0, 'Main 场景里有 Canvas（实际 ${canvases.length}）');
		var sprites = collectComponents(root.transform, SpriteRenderer);
		check(sprites.length > 0, 'Main 场景里有 SpriteRenderer（实际 ${sprites.length}）');
	}

	static function checkInjector():Void {
		Sys.println("-- ScenePrefabInjector（手工对象图的定向注入） --");
		var go = new GameObject("Grid");
		var grid:GridController = go.AddComponent(GridController);
		check(grid.size.x == 0, "新建 GridController 的 size 初值为 (0,0)");
		var ok = ScenePrefabInjector.ApplyGridSize(grid);
		check(ok, "ApplyGridSize 成功");
		check(grid.size.x == 0.8 && grid.size.y == 0.8, '注入后 size == (0.8, 0.8)（实际 ${grid.size}）');

		var presetGo = new GameObject("UIPresetStandalone");
		var preset:LevelUIPreset = presetGo.AddComponent(LevelUIPreset);
		var presetOk = ScenePrefabInjector.ApplyLevelUIPreset(preset, false);
		check(presetOk, "ApplyLevelUIPreset(standalone) 成功");
		checkVec2(preset.hintArrowOffsetBlueprint, 24, -108, "注入后的 hintArrowOffsetBlueprint");

		var presetMobileGo = new GameObject("UIPresetMobile");
		var presetMobile:LevelUIPreset = presetMobileGo.AddComponent(LevelUIPreset);
		var mobileOk = ScenePrefabInjector.ApplyLevelUIPreset(presetMobile, true);
		check(mobileOk, "ApplyLevelUIPreset(mobile) 成功");
		checkVec2(presetMobile.hintArrowOffsetBlueprint, 160, -27.5, "注入后的 mobile hintArrowOffsetBlueprint");

		var cameraGo = new GameObject("Camera");
		var camera:mvz2.cameras.LevelCamera = cameraGo.AddComponent(mvz2.cameras.LevelCamera);
		var cameraOk = ScenePrefabInjector.ApplyLevelCamera(camera);
		check(cameraOk, "ApplyLevelCamera 成功");
		check(camera.CameraAnchor.y == 0.5, '注入后 cameraAnchor == (0, 0.5)（实际 ${camera.CameraAnchor}）');
	}

	/**
	 * `ScenePrefabInjector.ApplyTree`：手工构造的对象图 + prefab 数据。
	 *
	 * 用真实数据里的 `Prefabs/Level/UI/UIPresetStandalone`（有 52 个 `[SerializeField]` 字段）
	 * 手工建一个同名层级，再灌数据，验证「字段写入 + 图内引用重映射」。
	 */
	static function checkApplyTree():Void {
		Sys.println("-- ScenePrefabInjector.ApplyTree（手工对象图 + prefab 数据） --");
		ScenePrefabInjector.ResetStats();

		// 手工建一棵与 UIPresetStandalone.prefab 同名的最小层级：根 + 几个会被引用的子节点。
		var root = new GameObject("UIPresetStandalone");
		var preset:LevelUIPreset = root.AddComponent(LevelUIPreset);
		check(preset.hintArrowOffsetBlueprint.x == 0, "手工构造的 preset 初值为 (0,0)");

		var count = ScenePrefabInjector.ApplyTree(root, "Prefabs/Level/UI/UIPresetStandalone");
		check(count > 0, 'ApplyTree 写入了字段（实际 $count）');
		checkVec2(preset.hintArrowOffsetBlueprint, 24, -108, "ApplyTree 后的 hintArrowOffsetBlueprint");
		check(preset.hintArrowAngleStarshard == 180, "ApplyTree 后的 hintArrowAngleStarshard");
		check(preset.cameraLimitWidth == 220, 'ApplyTree 后的 cameraLimitWidth（实际 ${preset.cameraLimitWidth}）');
		Sys.println('ApplyTree 未匹配节点数=${ScenePrefabInjector.unmatchedNodes} '
			+ '写不进去的字段=${Lambda.count(ScenePrefabInjector.missingFields)} 种');

		// 真机数据里 UIPresetStandalone 的 hintArrowOffsetBlueprint 是 (24,-108)（场景实际生效值）。
		var standalone = ScenePrefabInjector.ReadVector2("Level", "MVZ2.UI.Level.LevelUIPreset",
			"hintArrowOffsetBlueprint", "UIPresetStandalone");
		check(standalone != null && standalone.x == 24 && standalone.y == -108,
			'从 "Level" 场景数据读到 standalone 的 offset（实际 ${standalone == null ? "null" : Std.string(standalone)}）');
	}

	/**
	 * Map 页面的「根对象接管」注入：`MapController.mapCamera` 等引用必须被写入。
	 *
	 * 复刻 `MainGameScene.page()` 的做法：手工建一个名为 "Map" 的根 + `MapController`，
	 * 再 `InstantiateInto("Prefabs/Map/Map", root)`，然后断言 `mapCamera` 已被注入
	 * （`MapController.SetCameraBackgroundColor` 会直接读它，缺了就是 release 段错误）。
	 */
	@:access(mvz2.map.MapController)
	static function checkMapPageInjection():Void {
		Sys.println("-- Map 页面 prefab 接管注入（mapCamera） --");
		var root = new GameObject("Map");
		var controller:mvz2.map.MapController = root.AddComponent(mvz2.map.MapController);
		check(controller.mapCamera == null, "手工构造的 MapController.mapCamera 初值为 null");

		var written = ScenePrefabLoader.InstantiateInto("Prefabs/Map/Map", root, null, false);
		check(written > 0, 'InstantiateInto 写入了字段（实际 $written）');
		check(controller.mapCamera != null, "注入后 MapController.mapCamera != null");
		check(controller.ui != null, "注入后 MapController.ui != null");
		check(controller.mapCameraShakeRoot != null, "注入后 MapController.mapCameraShakeRoot != null");
		check(controller.modelRoot != null, "注入后 MapController.modelRoot != null");
		check(controller.raycastHitbox != null, "注入后 MapController.raycastHitbox != null");
		// 相机节点整棵新建出来了（节点 7 `Camera`，挂在节点 13 `Cameras` 下）。
		var cameras = collectComponents(root.transform, Camera);
		check(cameras.length >= 1, 'Map 页面里有 Camera 组件（实际 ${cameras.length}）');
		if (controller.mapCamera != null)
			check(controller.mapCamera == cameras[0] || cameras.indexOf(controller.mapCamera) >= 0,
				"mapCamera 指向重建出来的 Camera 组件");
	}

	// #region 辅助
	static function check(condition:Bool, message:String):Void {
		expected++;
		if (condition) {
			checked++;
		} else {
			failures.push(message);
		}
	}

	static function checkVec2(actual:Vector2, x:Float, y:Float, message:String):Void {
		check(actual != null && actual.x == x && actual.y == y,
			'$message == ($x, $y)（实际 ${actual == null ? "null" : Std.string(actual)}）');
	}

	static function collect(transform:Transform):Array<Transform> {
		var result = [transform];
		for (child in transform.children)
			result = result.concat(collect(child));
		return result;
	}

	static function collectComponents<T:Component>(transform:Transform, type:Class<T>):Array<T> {
		var result:Array<T> = [];
		for (t in collect(transform)) {
			var comp = t.gameObject.GetComponent(type);
			if (comp != null)
				result.push(comp);
		}
		return result;
	}
	// #endregion
}
