// PORT-NOTE: 验证用（不参与游戏构建）。渲染桥（unity → Flixel）的端到端冒烟测试：
//   A. `SortingLayer` 的层表与 `ProjectSettings/TagManager.asset` 一致，名字↔ID 可互查；
//   B. `Camera.ScreenToWorldPoint` / `WorldToScreenPoint` 的 **Y 轴方向** 与往返一致性；
//   C. `Camera.backgroundColor` 真正写进 `FlxG.cameras.bgColor`（`MapController.Hide` 的路径）；
//   D. `Camera.pixelsPerUnit` 与正交尺寸的关系；
//   E. `RenderBridge` 把 transform.lossyScale / GameObject 激活状态同步到 `renderSprite`；
//   F. `UnityObject.destroy(GameObject)` 递归摘除子树（显示列表据此淘汰）。
//
// 运行：bash HaxePort/tools_build/check_render_bridge.sh            # 默认 cpp（与游戏同目标）
//       bash HaxePort/tools_build/check_render_bridge.sh --neko     # neko（快）
package renderbridge;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import unity.Camera;
import unity.Color;
import unity.GameObject;
import unity.RenderBridge;
import unity.SortingLayer;
import unity.SpriteRenderer;
import unity.Transform;
import unity.UnityObject;
import unity.Vector2;
import unity.Vector3;

class RenderBridgeSmokeMain {
    private static var checks:Int = 0;
    private static var failures:Array<String> = [];

    public static function main():Void {
        // PORT-NOTE: **刻意不初始化 Flixel**（不建 FlxGame / 不开窗口）：
        //   1. lime 的窗口初始化在 `Sys.exit` 前会留下活动窗口，且 Flixel 的
        //      `FlxG.init` 需要真实的 stage（neko 下直接 `Invalid field access : window`）；
        //   2. 渲染桥的换算逻辑本身不依赖渲染后端 —— `RenderBridge.logicalWidth/Height`
        //      在 Flixel 未初始化时回退到 `Main.gameWidth/Height`（1280x720），
        //      这正是游戏运行时的同一组值，因此断言结果对游戏有效。
        // 需要 Flixel 才能验证的部分（真正写 `FlxG.cameras.bgColor`）在 cpp 目标下单独跑，
        // 见 §C 的 `flixelReady()` 分支。
        checkSortingLayers();
        checkScreenWorldRoundTrip();
        checkBackgroundColor();
        checkPixelsPerUnit();
        checkRenderBridgeSync();
        checkRotation();
        checkDestroyRemovesSubtree();

        echo('');
        echo('渲染桥冒烟测试：$checks 项通过，${failures.length} 项失败');
        if (failures.length > 0) {
            for (f in failures)
                echo('  FAIL: $f');
            Sys.exit(1);
        }
        Sys.exit(0);
    }

    // #region A. 排序层表
    private static function checkSortingLayers():Void {
        // 逐条对照 ProjectSettings/TagManager.asset 的 m_SortingLayers（顺序即层级）。
        eq("SortingLayer.NameToID(Background)", SortingLayer.NameToID("Background"), -2057763135);
        eq("SortingLayer.NameToID(Default)", SortingLayer.NameToID("Default"), 0);
        eq("SortingLayer.NameToID(Almanac)", SortingLayer.NameToID("Almanac"), 1742501395);
        eq("SortingLayer.NameToID(Talk)", SortingLayer.NameToID("Talk"), 1660876549);
        eq("SortingLayer.NameToID(ScreenCover)", SortingLayer.NameToID("ScreenCover"), 1206696159);
        eq("SortingLayer.NameToID(BackUI)", SortingLayer.NameToID("BackUI"), -2092243167);
        eq("SortingLayer.NameToID(未知层)", SortingLayer.NameToID("NoSuchLayer"), 0);

        eq("SortingLayer.IDToName(-2057763135)", SortingLayer.IDToName(-2057763135), "Background");
        eq("SortingLayer.IDToName(0)", SortingLayer.IDToName(0), "Default");
        eq("SortingLayer.IDToName(未知ID)", SortingLayer.IDToName(12345), "");

        // 层顺序（SortingLayer.value）必须与 TagManager 的声明顺序一致。
        eq("GetLayerValueFromID(Background)", SortingLayer.GetLayerValueFromID(-2057763135), 0);
        eq("GetLayerValueFromID(Default)", SortingLayer.GetLayerValueFromID(0), 8);
        eq("GetLayerValueFromID(ScreenCover)", SortingLayer.GetLayerValueFromID(1206696159), 19);
        // 层级顺序：Background(0) < Default(8) < Almanac(17) < ScreenCover(19)
        ok("层序 Background < Default",
            SortingLayer.GetLayerValueFromID(-2057763135) < SortingLayer.GetLayerValueFromID(0));
        ok("层序 Default < Almanac",
            SortingLayer.GetLayerValueFromID(0) < SortingLayer.GetLayerValueFromID(1742501395));
        ok("层序 Almanac < ScreenCover",
            SortingLayer.GetLayerValueFromID(1742501395) < SortingLayer.GetLayerValueFromID(1206696159));

        eq("layers.length", SortingLayer.layers.length, 20);

        // Mainmenu.prefab 实测：背景（MainmenuDark/Submenu/Ceiling/Floor/…）用 Background 层，
        // 按钮根（Elements，带 SortingGroup）用 BackUI 层。TagManager 的声明顺序是
        // Background(0) … BackUI(7) … Default(8)，因此背景必须**先画**（在按钮之后）。
        ok("层序 Background < BackUI（背景在按钮之下）",
            SortingLayer.GetLayerValueFromID(-2057763135) < SortingLayer.GetLayerValueFromID(-2092243167));

        // Mainmenu.prefab 的 WindowView 与背景**同层**（Background）但 sortingOrder = -10，
        // 必须排在同层其它精灵之前（`UiRenderer.stableSortWorldSprites` 的次级键）。
        var windowViewKey = SortingLayer.SortKeyOf(-2057763135, -10);
        var floorKey = SortingLayer.SortKeyOf(-2057763135, 0);
        ok("同层 sortingOrder=-10 排在 0 之前（WindowView 不盖住背景）", windowViewKey < floorKey);
        // 层是主键：低层的任何 order 都排在高层之前。
        ok("层优先于同层 order",
            SortingLayer.SortKeyOf(-2057763135, 9999) < SortingLayer.SortKeyOf(-2092243167, -9999));
    }
    // #endregion

    // #region B. 屏幕 / 世界换算
    private static function checkScreenWorldRoundTrip():Void {
        var go = new GameObject("Camera");
        var cam:Camera = go.AddComponent(Camera);
        cam.orthographic = true;
        cam.orthographicSize = 3;   // 视野高 6 世界单位；屏幕 720 ⇒ ppu = 120
        cam.rect = new unity.Rect(0, 0, 1, 1);
        go.transform.position = new Vector3(0, 0, 0);

        eq("pixelsPerUnit(orthographicSize=3, h=720)", cam.pixelsPerUnit(), 120.0);
        eq("pixelWidth", cam.pixelWidth, 1280);
        eq("pixelHeight", cam.pixelHeight, 720);

        // 屏幕中心 → 相机世界位置。
        var center = cam.ScreenToWorldPoint(new Vector3(640, 360, 0));
        approx("屏幕中心 → 世界原点 x", center.x, 0);
        approx("屏幕中心 → 世界原点 y", center.y, 0);

        // Y 轴方向：**屏幕 y 越小（越靠上）世界 y 越大**（见 Camera.hx 的 PORT-NOTE）。
        var top = cam.ScreenToWorldPoint(new Vector3(640, 0, 0));
        var bottom = cam.ScreenToWorldPoint(new Vector3(640, 720, 0));
        ok('屏幕顶部(y=0) 的世界 y 为正（实得 ${top.y}）', top.y > 0);
        ok('屏幕底部(y=720) 的世界 y 为负（实得 ${bottom.y}）', bottom.y < 0);
        approx("屏幕顶部 → 世界 y = +orthographicSize", top.y, 3);
        approx("屏幕底部 → 世界 y = -orthographicSize", bottom.y, -3);

        // x 方向不受影响：屏幕左侧世界 x 为负。
        var left = cam.ScreenToWorldPoint(new Vector3(0, 360, 0));
        var right = cam.ScreenToWorldPoint(new Vector3(1280, 360, 0));
        ok('屏幕左侧的世界 x 为负（实得 ${left.x}）', left.x < 0);
        ok('屏幕右侧的世界 x 为正（实得 ${right.x}）', right.x > 0);
        approx("屏幕左侧 → 世界 x = -aspect*orthographicSize", left.x, -3 * (1280 / 720));

        // 往返一致（WorldToScreenPoint 必须与 ScreenToWorldPoint 互为逆）。
        for (p in [new Vector2(0, 0), new Vector2(640, 360), new Vector2(1280, 720), new Vector2(123, 456)]) {
            var world = cam.ScreenToWorldPoint(new Vector3(p.x, p.y, 0));
            var back = cam.WorldToScreenPoint(world);
            approx('往返 x（屏幕 ${p.x},${p.y}）', back.x, p.x);
            approx('往返 y（屏幕 ${p.x},${p.y}）', back.y, p.y);
        }

        // 相机移动后换算跟着移动。
        go.transform.position = new Vector3(5, -2, 0);
        var moved = cam.ScreenToWorldPoint(new Vector3(640, 360, 0));
        approx("相机移到 (5,-2) 后屏幕中心世界 x", moved.x, 5);
        approx("相机移到 (5,-2) 后屏幕中心世界 y", moved.y, -2);

        // ViewportToWorldPoint：Unity 语义是 y 向上（0=下边，1=上边）。
        var vTop = cam.ViewportToWorldPoint(new Vector3(0.5, 1, 0));
        var vBottom = cam.ViewportToWorldPoint(new Vector3(0.5, 0, 0));
        approx("viewport y=1 → 世界上边", vTop.y, -2 + 3);
        approx("viewport y=0 → 世界下边", vBottom.y, -2 - 3);
    }
    // #endregion

    // #region C. 底色
    private static function checkBackgroundColor():Void {
        var go = new GameObject("BgCamera");
        var cam:Camera = go.AddComponent(Camera);

        if (!RenderBridge.flixelReady()) {
            // PORT-NOTE: Flixel 未初始化（无窗口的纯逻辑环境）时 `applyBackgroundColor` 按设计
            // 静默跳过，只保留字段语义。这里只断言字段读写正确，真正的清屏色写入在游戏/带窗口的
            // cpp 运行里验证（见 tools_build/render_bridge_work.md §验证）。
            note("跳过 FlxG.cameras.bgColor 断言（Flixel 未初始化）");
            cam.backgroundColor = Color.black;
            eq("backgroundColor 字段读回 r", cam.backgroundColor.r, 0.0);
            cam.backgroundColor = new Color(0.2, 0.4, 0.6, 1);
            eq("backgroundColor 字段读回 g", cam.backgroundColor.g, 0.4);
            return;
        }

        // PORT-NOTE: 对应 `MapController.Hide → SetCameraBackgroundColor(Color.black)`。
        cam.backgroundColor = Color.black;
        eq("backgroundColor 写入 FlxG.cameras.bgColor（黑）", FlxG.cameras.bgColor, FlxColor.BLACK);

        cam.backgroundColor = new Color(0.2, 0.4, 0.6, 1);
        var expected = FlxColor.fromRGBFloat(0.2, 0.4, 0.6, 1);
        eq("backgroundColor 写入 FlxG.cameras.bgColor（自定义色）", FlxG.cameras.bgColor, expected);

        // 全透明（Unity 的"不清屏"）不应覆盖已有底色。
        cam.backgroundColor = new Color(1, 0, 0, 0);
        eq("全透明 backgroundColor 不覆盖清屏色", FlxG.cameras.bgColor, expected);

        // 读回语义不变。
        cam.backgroundColor = Color.white;
        eq("backgroundColor 读回 r", cam.backgroundColor.r, 1.0);
        eq("backgroundColor 读回 a", cam.backgroundColor.a, 1.0);
    }
    // #endregion

    // #region D. pixelsPerUnit
    private static function checkPixelsPerUnit():Void {
        var go = new GameObject("PpuCamera");
        var cam:Camera = go.AddComponent(Camera);
        cam.orthographic = true;
        cam.rect = new unity.Rect(0, 0, 1, 1);
        cam.orthographicSize = 1;
        eq("orthographicSize=1 ⇒ ppu=360", cam.pixelsPerUnit(), 360.0);
        cam.orthographicSize = 5;
        eq("orthographicSize=5 ⇒ ppu=72", cam.pixelsPerUnit(), 72.0);
        // 透视相机在移植层退化为 1 世界单位 = 1 像素。
        cam.orthographic = false;
        eq("透视相机 ppu 退化为 1", cam.pixelsPerUnit(), 1.0);
        cam.orthographic = true;
        // orthographicSize=0 不应除零。
        cam.orthographicSize = 0;
        eq("orthographicSize=0 不除零", cam.pixelsPerUnit(), 1.0);
    }
    // #endregion

    // #region E. RenderBridge 同步
    private static function checkRenderBridgeSync():Void {
        var root = new GameObject("Root");
        var child = new GameObject("Child");
        child.transform.SetParent(root.transform, false);
        root.transform.localScale = new Vector3(2, 2, 1);
        child.transform.localScale = new Vector3(3, 4, 1);

        var sr:SpriteRenderer = child.AddComponent(SpriteRenderer);
        sr.renderSprite = new FlxSprite();
        var target = sr.renderSprite;

        // 登记点：AddComponent 必须已把渲染器登记进 RenderBridge。
        ok("AddComponent 登记了 SpriteRenderer", RenderBridge.rendererCount > 0);

        RenderBridge.sync();
        approx("lossyScale 级联到 renderSprite.scale.x（2*3）", target.scale.x, 6);
        approx("lossyScale 级联到 renderSprite.scale.y（2*4）", target.scale.y, 8);
        ok("激活时 renderSprite.visible 为真", target.visible);

        // SetActive(false) ⇒ 不绘制（对应 Unity 的 activeInHierarchy）。
        child.SetActive(false);
        RenderBridge.sync();
        ok("SetActive(false) ⇒ renderSprite 不可见", !target.visible);
        child.SetActive(true);
        RenderBridge.sync();
        ok("SetActive(true) ⇒ renderSprite 恢复可见", target.visible);

        // 祖先未激活同样不绘制。
        root.SetActive(false);
        RenderBridge.sync();
        ok("祖先 SetActive(false) ⇒ 子渲染器不可见", !target.visible);
        root.SetActive(true);

        // SpriteRenderer.enabled = false ⇒ 不绘制。
        sr.enabled = false;
        RenderBridge.sync();
        ok("SpriteRenderer.enabled=false ⇒ 不可见", !target.visible);
        sr.enabled = true;
        RenderBridge.sync();

        // 排序层名字 ↔ ID 双向收敛。
        sr.sortingLayerID = SortingLayer.NameToID("Almanac");
        RenderBridge.sync();
        eq("sortingLayerID=Almanac ⇒ 名字同步为 Almanac", sr.sortingLayerName, "Almanac");
        sr.sortingLayerName = "Talk";
        sr.sortingLayerID = 0;
        RenderBridge.sync();
        eq("sortingLayerName=Talk ⇒ ID 同步为 Talk 的哈希", sr.sortingLayerID, 1660876549);

        // alpha / flip 兜底同步。
        sr.alpha = 0.25;
        sr.flipX = true;
        RenderBridge.sync();
        approx("alpha 同步到 renderSprite", target.alpha, 0.25);
        ok("flipX 同步到 renderSprite", target.flipX);
    }
    // #endregion

    // #region E2. 旋转
    /**
     * `unity.Quaternion.Euler` / `eulerAngles` 的 ZXY 换算 + `RenderBridge` → `FlxSprite.angle`。
     *
     * PORT-NOTE: 这两条原先都是**空实现**（恒返回 identity / 零向量），于是
     * `transform.eulerAngles` 的读与写、`Transform.Rotate`、`RotationLocker`、
     * `NightmareGlassModel` 的碎片旋转、`MapUI` 的拖拽箭头全部静默失效。
     */
    private static function checkRotation():Void {
        // 单轴：绕 Z 转 90°。
        var qz = unity.Quaternion.Euler(0, 0, 90);
        approx("Euler(0,0,90) → w = cos45", qz.w, Math.sqrt(0.5));
        approx("Euler(0,0,90) → z = sin45", qz.z, Math.sqrt(0.5));
        approx("Euler(0,0,90) → x", qz.x, 0);
        approx("Euler(0,0,90) → y", qz.y, 0);

        // 往返：Euler → eulerAngles 必须还原原角度（ZXY，分量 ∈ [0,360)）。
        for (deg in [[0.0, 0.0, 0.0], [0.0, 0.0, 90.0], [0.0, 0.0, -90.0], [30.0, 0.0, 0.0],
                [0.0, 45.0, 0.0], [10.0, 20.0, 30.0], [0.0, 0.0, 180.0], [0.0, 0.0, 45.0]]) {
            var q = unity.Quaternion.Euler(deg[0], deg[1], deg[2]);
            var back = q.eulerAngles;
            // PORT-NOTE: Unity 的 eulerAngles 归一化到 [0,360)，故用 360 取模比较。
            approx('往返 x（${deg[0]},${deg[1]},${deg[2]}）', mod360(back.x), mod360(deg[0]), 0.01);
            approx('往返 y（${deg[0]},${deg[1]},${deg[2]}）', mod360(back.y), mod360(deg[1]), 0.01);
            approx('往返 z（${deg[0]},${deg[1]},${deg[2]}）', mod360(back.z), mod360(deg[2]), 0.01);
        }

        // eulerAngles 的取值区间必须是 [0, 360)。
        var neg = unity.Quaternion.Euler(0, 0, -90).eulerAngles;
        approx("负角度归一化到 [0,360)：z(-90) → 270", neg.z, 270, 0.01);
        ok("eulerAngles 分量非负", neg.x >= 0 && neg.y >= 0 && neg.z >= 0);

        // 单位四元数 → 零角度。
        var id = unity.Quaternion.identity.eulerAngles;
        approx("identity → x", id.x, 0, 0.01);
        approx("identity → y", id.y, 0, 0.01);
        approx("identity → z", id.z, 0, 0.01);

        // Transform.eulerAngles 的 getter/setter 走同一套换算。
        var go = new GameObject("Rot");
        go.transform.eulerAngles = new Vector3(0, 0, 45);
        approx("Transform.eulerAngles 写入后读回 z", go.transform.eulerAngles.z, 45, 0.01);
        // Rotate 累加。
        go.transform.eulerAngles = new Vector3(0, 0, 10);
        go.transform.Rotate(0, 0, 20);
        approx("Transform.Rotate 累加（10+20）", go.transform.eulerAngles.z, 30, 0.01);

        // ---- RenderBridge → FlxSprite.angle ----
        var sr:SpriteRenderer = go.AddComponent(SpriteRenderer);
        sr.renderSprite = new FlxSprite();
        var target = sr.renderSprite;

        go.transform.eulerAngles = new Vector3(0, 0, 45);
        RenderBridge.sync();
        // PORT-NOTE: Unity 逆时针 / Flixel 顺时针 ⇒ 取负号。
        approx("Transform 45°(逆时针) → FlxSprite.angle = -45", target.angle, -45, 0.01);

        go.transform.eulerAngles = new Vector3(0, 0, 0);
        RenderBridge.sync();
        approx("归零 → angle = 0", target.angle, 0, 0.01);

        // 只取 Z（Flixel 的 angle 是 2D 的；Unity 的 X/Y 在 2D 场景里不产生屏幕旋转）。
        go.transform.eulerAngles = new Vector3(30, 20, 60);
        RenderBridge.sync();
        approx("只取 eulerAngles.z（X/Y 不影响 2D angle）", target.angle, -60, 0.01);
    }

    private static function mod360(v:Float):Float {
        var r = v % 360;
        return r < 0 ? r + 360 : r;
    }
    // #endregion

    // #region F. 销毁
    private static function checkDestroyRemovesSubtree():Void {
        var root = new GameObject("Dying");
        var a = new GameObject("A");
        var b = new GameObject("B");
        a.transform.SetParent(root.transform, false);
        b.transform.SetParent(a.transform, false);
        var sr:SpriteRenderer = b.AddComponent(SpriteRenderer);
        sr.renderSprite = new FlxSprite();

        eq("销毁前 root.childCount", root.transform.childCount, 1);
        eq("销毁前 a.childCount", a.transform.childCount, 1);

        UnityObject.destroy(root);

        ok("destroy 后 root 标记为 destroyed", root.destroyed);
        ok("destroy 后子节点 a 也 destroyed", a.destroyed);
        ok("destroy 后孙节点 b 也 destroyed", b.destroyed);
        ok("destroy 后组件 destroyed", sr.destroyed);
        ok("destroy 后 Exists() 为 false", !UnityObject.exists(root));

        // 从父级摘除（显示列表按 children 遍历）。
        var parent = new GameObject("Parent");
        var victim = new GameObject("Victim");
        victim.transform.SetParent(parent.transform, false);
        eq("摘除前父级 childCount", parent.transform.childCount, 1);
        UnityObject.destroy(victim);
        eq("destroy 后父级 childCount 归零", parent.transform.childCount, 0);
    }
    // #endregion

    // #region 断言工具
    private static function ok(label:String, condition:Bool):Void {
        checks++;
        if (condition)
            echo('  ok   $label');
        else {
            failures.push(label);
            echo('  FAIL $label');
        }
    }

    private static function eq(label:String, actual:Dynamic, expected:Dynamic):Void {
        var same = Std.string(actual) == Std.string(expected);
        checks++;
        if (same)
            echo('  ok   $label = $actual');
        else {
            failures.push('$label：期望 $expected，实得 $actual');
            echo('  FAIL $label：期望 $expected，实得 $actual');
        }
    }

    private static function approx(label:String, actual:Float, expected:Float, ?epsilon:Float = 0.001):Void {
        var same = Math.abs(actual - expected) <= epsilon;
        checks++;
        if (same)
            echo('  ok   $label = $actual');
        else {
            failures.push('$label：期望 ≈$expected，实得 $actual');
            echo('  FAIL $label：期望 ≈$expected，实得 $actual');
        }
    }

    private static function echo(s:String):Void {
        #if sys
        Sys.println(s);
        #else
        trace(s);
        #end
    }

    private static function note(s:String):Void {
        echo('  note $s');
    }
    // #endregion
}
