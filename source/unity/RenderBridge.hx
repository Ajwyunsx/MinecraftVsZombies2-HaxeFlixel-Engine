package unity;

import flixel.FlxG;
import flixel.FlxSprite;

// PORT-NOTE: 移植层新增（无 C# 对应源码）。**本类是「Unity 对象图 → Flixel 显示列表」的最后一段接线。**
//
// 背景：并行工作包已经把两半接好 ——
//   * `mvz2.sprites.SpriteFrameFactory` 把 `unity.Sprite` 转成 `FlxFrame` 并写进
//     `SpriteRenderer.renderSprite`（一个 FlxSprite）；
//   * `mvz2.ui.UiRenderer` 把 uGUI 树 + 世界空间 SpriteRenderer 挂进 Flixel 显示列表。
// 但 `renderSprite` 自身的 **transform 驱动** 没人做：
//   * `SpriteRenderer` 的 `enabled` / GameObject 的 `SetActive` 不会反映到 `renderSprite.visible`；
//   * `Transform.localScale` 不会反映到 `renderSprite.scale`（Unity 里 SpriteRenderer 的
//     世界缩放**就是** transform.lossyScale，`SpriteSizeFitter` 正是靠写 localScale 生效的）。
// 本类补上这段：登记全部 SpriteRenderer，每帧把 transform / 激活状态同步到 renderSprite。
//
// 为什么用 `FlxG.signals.preUpdate` 而不是让每个调用点手动调用：Unity 里这是引擎行为
// （渲染前统一做 transform 同步），逐个调用点手写会漏、也会和并行 agent 抢文件。
//
// 依赖方向：本类只在 `unity` 包内活动，**不反向依赖 mvz2**（`SpriteRenderer.renderSprite`
// 由 mvz2 侧写入，本类只读）。安装是惰性的，由 `Camera.new()` 与 `GameObject.AddComponent`
// 触发，因此不需要改任何 mvz2 侧文件。
class RenderBridge {
    /** 已登记的 SpriteRenderer（弱引用语义：靠 `destroyed` 标记淘汰）。 */
    private static var renderers:Array<SpriteRenderer> = [];
    /** 已登记的相机（见 Camera.hx）。 */
    private static var cameras:Array<Camera> = [];
    /** 是否已挂上 `FlxG.signals.preUpdate`。 */
    private static var installed:Bool = false;
    /** 同步失败计数（诊断用；失败不中断游戏）。 */
    public static var syncErrors:Int = 0;
    /** 上次同步的渲染器数量（诊断用）。 */
    public static var lastSynced:Int = 0;

    private function new() {}

    // #region 登记
    /** 登记一个渲染器。幂等。 */
    public static function registerRenderer(renderer:SpriteRenderer):Void {
        if (renderer == null || renderers.indexOf(renderer) >= 0)
            return;
        renderers.push(renderer);
        ensureInstalled();
    }

    /** 登记一个相机。幂等。 */
    public static function registerCamera(camera:Camera):Void {
        if (camera == null || cameras.indexOf(camera) >= 0)
            return;
        cameras.push(camera);
        ensureInstalled();
    }

    /** 注销（销毁路径调用）。 */
    public static function unregister(component:Component):Void {
        if (component == null)
            return;
        if (Std.isOfType(component, SpriteRenderer))
            renderers.remove(cast component);
        if (Std.isOfType(component, Camera))
            cameras.remove(cast component);
    }

    /**
     * 已登记的相机快照（`unity.Camera.main` / `allCameras` 用）。
     *
     * PORT-NOTE: 返回的是**新建数组**，调用方可以安全遍历；`cameras` 本身不暴露，
     * 避免外部直接改内部表。
     */
    public static function camerasSnapshot():Array<Camera> {
        return cameras.copy();
    }

    /** 已登记的渲染器数量（诊断用）。 */
    public static var rendererCount(get, never):Int;
    static function get_rendererCount():Int return renderers.length;

    /**
     * 惰性安装每帧同步。
     *
     * PORT-NOTE: 不能在**静态字段初始化**里挂信号 —— hxcpp 会在 `main()` 之前跑完全部静态初始化
     * （见 PORTING.md「hxcpp 启动期静态初始化约束」），此时 `FlxG.signals` 可能还没建好。
     * 因此由构造点（`Camera.new` / `AddComponent`）在运行期触发。
     */
    public static function ensureInstalled():Void {
        if (installed)
            return;
        try {
            if (flixel.FlxG.signals == null)
                return;
            FlxG.signals.preUpdate.add(sync);
            installed = true;
        } catch (e:Dynamic) {
            // PORT-NOTE: Flixel 尚未初始化（例如纯逻辑冒烟测试直接 new Camera()）时静默跳过；
            // 下次构造点会重试。
        }
    }

    /** 重置（测试用）。 */
    public static function reset():Void {
        renderers = [];
        cameras = [];
        syncErrors = 0;
        lastSynced = 0;
    }
    // #endregion

    // #region 逻辑分辨率

    /**
     * 逻辑分辨率（Unity 的 `Screen.width/height` 等价量）。
     *
     * PORT-NOTE: 正常运行时就是 `FlxG.width/height`（由 `FlxG.init` 设成 `Main.gameWidth/Height`
     * = 1280x720）。但**纯逻辑场景**（冒烟测试、`-nef` 工具）里 Flixel 可能还没初始化，
     * 此时 `FlxG.width` 是 0，会让坐标换算除零。因此这里加一层安全兜底：
     * 取不到有效值时退回 `Main.gameWidth/Height` 的等价常量。
     * 这也是相机换算能在**没有窗口**的环境里被断言的前提（见
     * `verify/renderbridge/RenderBridgeSmokeMain.hx`）。
     */
    public static function logicalWidth():Int {
        var w = flixel.FlxG.width;
        return w > 0 ? w : DEFAULT_LOGICAL_WIDTH;
    }
    public static function logicalHeight():Int {
        var h = flixel.FlxG.height;
        return h > 0 ? h : DEFAULT_LOGICAL_HEIGHT;
    }
    /** 与 `Main.gameWidth/gameHeight` 一致（`source/Main.hx:15~16`）。 */
    public static inline var DEFAULT_LOGICAL_WIDTH:Int = 1280;
    public static inline var DEFAULT_LOGICAL_HEIGHT:Int = 720;

    /** Flixel 是否已初始化到可以安全读写 `FlxG.cameras` 的程度。 */
    public static function flixelReady():Bool {
        return flixel.FlxG.cameras != null && flixel.FlxG.width > 0;
    }
    // #endregion

    // #region 每帧同步
    /**
     * 把每个 `SpriteRenderer` 的 transform / 激活状态同步到它的 `renderSprite`。
     *
     * PORT-NOTE: 只做「谁也没做」的部分：
     *   * `visible` —— GameObject 的 activeInHierarchy 与 SpriteRenderer.enabled 相乘（Unity 语义）；
     *   * `scale`   —— `transform.lossyScale`（父级 localScale 级联）；
     *   * `alpha`   —— SpriteRenderer.alpha（其 setter 已写 renderSprite，这里兜底同步外部直写）；
     *   * `flipX/flipY` —— 同上，setter 已写，这里兜底。
     * 位置**不在这里算**：世界空间 SpriteRenderer 的位置由 `mvz2.ui.UiRenderer` 按正交相机
     * 换算到屏幕像素（它同时负责排序层排序），这里重复写会互相覆盖。
     */
    public static function sync():Void {
        var alive:Array<SpriteRenderer> = [];
        var count = 0;
        for (renderer in renderers) {
            if (renderer == null || renderer.destroyed) {
                continue;
            }
            alive.push(renderer);
            var target = renderer.renderSprite;
            if (target == null)
                continue;
            try {
                syncOne(renderer, target);
                count++;
            } catch (e:Dynamic) {
                syncErrors++;
            }
        }
        renderers = alive;
        lastSynced = count;
    }

    private static function syncOne(renderer:SpriteRenderer, target:FlxSprite):Void {
        var go = renderer.gameObject;
        var tr = renderer.transform;
        // PORT-NOTE: 排序层双字段收敛 —— `ScenePrefabFieldApplier` 只能按 prefab 数据写
        // `sortingLayerID`（Unity 序列化的就是它），而 C# 代码路径写的是 `sortingLayerName`。
        // Unity 里两者是同一份数据的两种视图，这里补上双向同步，让
        // `mvz2.ui.UiRenderer.stableSortWorldSprites`（按 sortingLayerID 排序）拿到一致的值。
        // 名字侧非默认时以名字为准，否则以 ID 为准。
        if (renderer.sortingLayerName != null && renderer.sortingLayerName != "Default") {
            var idFromName = SortingLayer.NameToID(renderer.sortingLayerName);
            if (renderer.sortingLayerID != idFromName)
                renderer.sortingLayerID = idFromName;
        } else if (renderer.sortingLayerID != 0) {
            var nameFromID = SortingLayer.IDToName(renderer.sortingLayerID);
            if (nameFromID != null && nameFromID.length > 0)
                renderer.sortingLayerName = nameFromID;
        }
        // Unity：GameObject 未激活（或祖先未激活）时整个渲染器不绘制。
        var active = go != null && go.activeInHierarchy;
        target.visible = active && renderer.enabled;
        if (!active)
            return;
        if (tr != null) {
            var scale = tr.lossyScale;
            // PORT-NOTE: 直接写 scale（不走 setGraphicSize）：FlxSprite.scale 与
            // `SpriteFrameFactory` 写入的 frames/origin 是正交的两套，`UiRenderer` 也读它。
            target.scale.set(scale.x, scale.y);
            // PORT-NOTE: Unity 的旋转正方向是**逆时针**（y 轴向上），Flixel 的 `angle` 是
            // **顺时针**（y 轴向下）。两者互为相反数，这里取负号。
            // 数据来源：`Transform.eulerAngles.z`（其 getter 依赖 Quaternion 的 ZXY 换算，
            // 见 unity/Quaternion.hx —— 原先是恒 0 的空实现，已补）。
            target.angle = -tr.eulerAngles.z;
        }
        // PORT-NOTE: 兜底同步 —— `SpriteRenderer.alpha`/`flipX`/`flipY` 的 setter 已经会写
        // renderSprite，但 `ModelPrefabAssets` 等路径可能直接写 renderSprite；这里保证每帧收敛。
        target.flipX = renderer.flipX;
        target.flipY = renderer.flipY;
        target.alpha = renderer.alpha;
    }
    // #endregion
}
