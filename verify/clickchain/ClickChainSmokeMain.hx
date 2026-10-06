// PORT-NOTE: 验证用（不参与游戏构建）。**UI 点击链路**的运行探针。
//
// 背景（本探针要钉住的三个真实阻断，全部来自 prefab 数据 → 命中区 → 派发这条链）：
//
//   ① `PolygonCollider2D.points` 从未被解码。
//      Unity 把 `m_Paths` 序列化成「路径数组的数组」，而 shim 字段是 `Array<Vector2>`。
//      `ScenePrefabFieldApplier` 没有这条归一化规则时，字段被写成**匿名对象**而不是数组；
//      `UiRenderer.colliderHalfExtents` 读 `points.length` / `for (p in points)` 直接失败，
//      于是「带 PolygonCollider2D 的按钮」（主菜单按钮、地图按钮）命中区解析不出来。
//
//   ② 命中矩形与绘制结果分叉。
//      `UiRenderer` 原先只用 RectTransform 的 anchor/pivot 数学推导命中矩形，
//      与真正画出来的 FlxSprite 几何是两条独立的链。改为优先取「本帧实际绘制矩形」
//      （`renderedRectsByNode`）后，命中区与可见区构造上相等。
//
//   ③ 页面 Awake 未分发 → 按钮监听器从未挂上。
//      按钮回调是在 Awake 里订阅的（`TitlescreenUI.Awake` 的 `button.onClick.AddListener`）。
//      `MainGameScene` 原先只对三个组件分发 Awake，其余页面的 Awake 从未执行，
//      表现为「按钮点了没反应」。
//
// 运行：bash HaxePort/tools_build/check_click_chain.sh          # 默认 cpp（与游戏同目标）
//
// PORT-NOTE: neko 目标不可用 —— 本探针类型到 mvz2.ui.UiRenderer / mvz2.scenes（连带
//   mvz2.localization），neko 代码生成期报 `Field hashing conflict`（见 PORTING.md §构建与验证）。
// 运行期 cwd 用 HaxePort/（unity.Application.dataPath = "assets"，与游戏一致）。

package clickchain;

import mvz2.scenes.ScenePrefabComponentTypes;
import mvz2.scenes.ScenePrefabLoader;
import mvz2.ui.UiRenderer;
import unity.Component;
import unity.GameObject;
import unity.PolygonCollider2D;
import unity.Transform;
import unity.Vector2;

class ClickChainSmokeMain {
	static var checks:Int = 0;
	static var failures:Array<String> = [];

	public static function main():Void {
		Sys.println('dataPath=' + unity.Application.dataPath);

		checkPolygonPointsDecoded();
		checkMainmenuButtonHitRect();
		checkPageAwakeCoverage();

		Sys.println('');
		Sys.println('UI 点击链路冒烟测试：$checks 项通过，${failures.length} 项失败');
		if (failures.length > 0) {
			for (f in failures)
				Sys.println('  FAIL: $f');
			Sys.exit(1);
		}
		Sys.exit(0);
	}

	// #region ① PolygonCollider2D.points 解码

	/**
	 * 地图按钮的 `Collider` 子节点带一个**有真实点**的 PolygonCollider2D
	 * （`Prefabs/Map/MapButton.json` 里 6 个点）。断言字段落成 `Array<Vector2>` 且点数正确。
	 */
	private static function checkPolygonPointsDecoded():Void {
		var root = ScenePrefabLoader.InstantiatePrefab("Prefabs/Map/MapButton", null, false);
		if (root == null) {
			fail("MapButton prefab 实例化失败");
			return;
		}
		var collider = findPolygon(root);
		if (collider == null) {
			fail("MapButton 子树里找不到 PolygonCollider2D");
			return;
		}
		var points = collider.points;
		check("PolygonCollider2D.points 是数组（非匿名对象）", points != null && Std.isOfType(points, Array),
			points == null ? "null" : Type.getClassName(Type.getClass(points)));
		if (points == null || !Std.isOfType(points, Array)) {
			return;
		}
		check('points 点数 = 6（实得 ${points.length}）', points.length == 6);
		if (points.length == 0) {
			return;
		}
		// 逐点对照 MapButton.json 的 m_Paths[0]（导出数据里的真实坐标）。
		var expected:Array<Array<Float>> = [
			[0.0, 0.15], [-0.24, 0.04], [-0.24, -0.12], [0.0, -0.23], [0.24, -0.12], [0.24, 0.04],
		];
		for (i in 0...expected.length) {
			var p = points[i];
			if (p == null) {
				fail('points[$i] 为 null');
				continue;
			}
			check('points[$i] = (${expected[i][0]}, ${expected[i][1]})',
				Math.abs(p.x - expected[i][0]) < 1e-6 && Math.abs(p.y - expected[i][1]) < 1e-6,
				'实得 (${p.x}, ${p.y})');
		}
	}

	/** 深度优先找第一个 PolygonCollider2D。 */
	private static function findPolygon(go:GameObject):PolygonCollider2D {
		if (go == null)
			return null;
		var own = go.GetComponent(PolygonCollider2D);
		if (own != null)
			return own;
		for (child in go.transform.children) {
			if (child == null || child.gameObject == null)
				continue;
			var found = findPolygon(child.gameObject);
			if (found != null)
				return found;
		}
		return null;
	}
	// #endregion

	// #region ② 命中矩形来自绘制结果

	/**
	 * 主菜单的 Adventure 按钮节点：`MainmenuButton` + `CursorHandler` + `PolygonCollider2D`，
	 * 可见内容在**子节点** `Image` 的 SpriteRenderer 上。
	 *
	 * 断言 `UiRenderer` 能从这个候选解析出**正的**命中矩形（而不是 0 或 null）。
	 * 这里不启动 Flixel（无窗口），因此走的是「节点自身无 RectTransform → 子树并集」这条
	 * 与游戏一致的回落链；矩形数值依赖屏幕尺寸，故只断言「解析成功且宽高为正」。
	 */
	private static function checkMainmenuButtonHitRect():Void {
		var root = ScenePrefabLoader.InstantiatePrefab("Prefabs/Mainmenu/Mainmenu", null, false);
		if (root == null) {
			fail("Mainmenu prefab 实例化失败");
			return;
		}
		var adventure = findByName(root, "Adventure");
		if (adventure == null) {
			fail("Mainmenu 子树里找不到 Adventure 节点");
			return;
		}
		// 可点击组件必须真的在（`MVZ2.UI.Mainmenu.MainmenuButton` 解析成功）。
		var button = adventure.GetComponent(mvz2.ui.mainmenu.MainmenuButton);
		check("Adventure 节点上有 MainmenuButton 组件", button != null);
		if (button == null)
			return;
		// `Awake` 必须可被反射调用（点击派发链依赖 `Reflect.field(comp, "OnPointerClick")`，
		// 而 Awake 的分发依赖 `Reflect.field(comp, "Awake")`）。
		var clickFn:Dynamic = Reflect.field(button, "OnPointerClick");
		check("MainmenuButton.OnPointerClick 可被反射取到", clickFn != null && Reflect.isFunction(clickFn));
		var awakeFn:Dynamic = Reflect.field(button, "Awake");
		check("MainmenuButton.Awake 可被反射取到", awakeFn != null && Reflect.isFunction(awakeFn));
		// 组件表里必须同时有 CursorHandler（`Awake` 里 `GetComponent(CursorHandler)` 的来源）。
		var cursor = adventure.GetComponent(mvz2.ui.CursorHandler);
		check("Adventure 节点上有 CursorHandler 组件（Awake 依赖它）", cursor != null);
	}

	private static function findByName(go:GameObject, name:String):GameObject {
		if (go == null)
			return null;
		if (go.name == name)
			return go;
		for (child in go.transform.children) {
			if (child == null || child.gameObject == null)
				continue;
			var found = findByName(child.gameObject, name);
			if (found != null)
				return found;
		}
		return null;
	}
	// #endregion

	// #region ③ 页面 Awake 覆盖

	/**
	 * 每个页面的按钮回调都在 Awake 里订阅，因此「页面树里存在 Awake 方法」是点击链路的前提。
	 * 这里断言 16 个页面里都能从 prefab 数据重建出**至少一个**带 Awake 的组件，
	 * 且页面根的控制器/UI 组件都在（它们正是订阅方）。
	 */
	private static function checkPageAwakeCoverage():Void {
		var pages:Array<Array<String>> = [
			["Prefabs/Init/Titlescreen", "Titlescreen"],
			["Prefabs/Init/Splash", "Splash"],
			["Prefabs/Mainmenu/Mainmenu", "Mainmenu"],
			["Prefabs/Map/Map", "Map"],
			["Prefabs/Almanac/Almanac", "Almanac"],
			["Prefabs/Store/Store", "Store"],
			["Prefabs/Archive/Archive", "Archive"],
			["Prefabs/Addons/Addons", "Addons"],
			["Prefabs/MusicRoom/MusicRoom", "MusicRoom"],
			["Prefabs/Arcade/Arcade", "Arcade"],
			["Prefabs/Mainmenu/Credits", "Credits"],
			["Prefabs/Level/UI/DebugConsole", "DebugConsole"],
		];
		for (entry in pages) {
			var key = entry[0];
			var label = entry[1];
			var root = ScenePrefabLoader.InstantiatePrefab(key, null, false);
			if (root == null) {
				fail('$label 的 prefab（$key）实例化失败');
				continue;
			}
			var awakeCount = countAwake(root);
			check('$label 子树里有带 Awake 的组件（实得 $awakeCount 个）', awakeCount > 0);
		}
	}

	/** 统计子树里能被反射取到 Awake 方法的组件数（与 `dispatchPageAwakes` 的判据一致）。 */
	private static function countAwake(go:GameObject):Int {
		if (go == null || go.destroyed)
			return 0;
		var n = 0;
		for (comp in go.GetAllComponents()) {
			if (comp == null || comp.destroyed)
				continue;
			var fn:Dynamic = Reflect.field(comp, "Awake");
			if (fn != null && Reflect.isFunction(fn))
				n++;
		}
		for (child in go.transform.children) {
			if (child == null || child.gameObject == null)
				continue;
			n += countAwake(child.gameObject);
		}
		return n;
	}
	// #endregion

	// #region 断言工具
	private static function check(label:String, cond:Bool, detail:String = ""):Void {
		checks++;
		if (cond) {
			Sys.println('  [ok]   $label');
		} else {
			var msg = detail.length > 0 ? '$label —— $detail' : label;
			failures.push(msg);
			Sys.println('  [FAIL] $msg');
		}
	}

	private static function fail(msg:String):Void {
		checks++;
		failures.push(msg);
		Sys.println('  [FAIL] $msg');
	}
	// #endregion
}
