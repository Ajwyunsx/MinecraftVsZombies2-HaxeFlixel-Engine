package unity;

import flixel.FlxG;

// Minimal UnityEngine.Camera shim.
//
// PORT-NOTE: 本类在移植层承担两件事：
//   1. **逻辑 shim**（正交尺寸 / viewport / 视口换算），与 C# 的调用点 1:1；
//   2. **渲染职责**：把相机的 `backgroundColor` 真正写到 `FlxG.cameras.bgColor`
//      （`MapController.Hide → SetCameraBackgroundColor` 是原工程里切页面时改底色的唯一路径，
//      不接的话画面底色永远是 FlxState 的初始值），并做屏幕↔世界的 Y 轴换算。
//
// 相机**不**自建 FlxCamera：一个 Unity 场景里有十几个 Camera 对象（Main.json 实测 17 个），
// 各自建一个 FlxCamera 会叠加出多层绘制。移植层沿用 Flixel 的单一默认相机，
// 把 Unity 相机的正交参数映射成它的 scroll / bgColor（见 applyToFlxCamera）。
class Camera extends Behaviour {
    public static var main(get, never):Camera;
    static function get_main():Camera {
        // PORT-NOTE: 原 shim 会凭空 `new Camera()`。Unity 的 `Camera.main` 返回
        // tag == "MainCamera" 且激活的相机；移植层场景里 `MainGameScene` 给 uiCamera 设了该 tag。
        // 这里优先返回已登记的场景相机，找不到才退回惰性自建（保持既有调用点不空引用）。
        var found = findMainCamera();
        if (found != null)
            return found;
        if (_main == null) {
            _main = new Camera();
            _main.tag = "MainCamera";
        }
        return _main;
    }
    private static var _main:Camera;

    /** 移植层新增：已登记（构造过）的全部相机，供场景查找。 */
    public static var allCameras(get, never):Array<Camera>;
    static function get_allCameras():Array<Camera> {
        var result:Array<Camera> = [];
        for (camera in RenderBridge.camerasSnapshot()) {
            if (camera != null && !camera.destroyed)
                result.push(camera);
        }
        if (result.length == 0 && _main != null)
            result.push(_main);
        return result;
    }

    /** 在已登记相机里找 tag == "MainCamera" 且激活的那个（Unity 的 Camera.main 语义）。 */
    private static function findMainCamera():Camera {
        for (camera in RenderBridge.camerasSnapshot()) {
            if (camera == null || camera.destroyed || !camera.enabled)
                continue;
            var go = camera.gameObject;
            if (go == null || !go.activeInHierarchy)
                continue;
            if (go.CompareTag("MainCamera"))
                return camera;
        }
        return null;
    }

    public var orthographic:Bool = true;
    public var orthographicSize:Float = 5;
    public var fieldOfView:Float = 60;
    public var nearClipPlane:Float = 0.3;
    public var farClipPlane:Float = 1000;
    public var aspect(get, set):Float;
    public var rect:Rect = new Rect(0, 0, 1, 1);
    public var pixelWidth(get, never):Int;
    public var pixelHeight(get, never):Int;
    public var depth:Float = 0;
    public var clearFlags:Int = 1;
    public var cullingMask:Int = ~0;
    public var targetTexture:Dynamic;

    /**
     * C#: `public Color backgroundColor { get; set; }`
     *
     * PORT-NOTE: 这是本工作包的关键接线点。C# 里 `MapController.SetCameraBackgroundColor`
     * （`MVZ2/Map/MapController.cs:300`）直接写它，Unity 用它清屏。
     * 移植层原先只是存字段，从不影响画面，于是「切到地图页要变底色」完全失效。
     * 现在写入时同步 `FlxG.cameras.bgColor`（Flixel 的全局清屏色），
     * 让 `MapController.Hide` 的 `SetCameraBackgroundColor(Color.black)` 真正生效。
     */
    public var backgroundColor(get, set):Color;
    private var _backgroundColor:Color = new Color(0, 0, 0, 0);
    function get_backgroundColor():Color return _backgroundColor;
    function set_backgroundColor(value:Color):Color {
        _backgroundColor = value;
        applyBackgroundColor();
        return value;
    }

    /** 把当前底色写进 Flixel 的清屏色。 */
    public function applyBackgroundColor():Void {
        var color = _backgroundColor;
        if (color == null)
            return;
        // PORT-NOTE: Unity 的 backgroundColor 是「不透明底色」；alpha 分量在 Flixel 里对应
        // `useBgAlphaBlending`（默认关，清屏时按不透明处理）。为保持与 Unity 观感一致，
        // 只在 alpha > 0 时才写（完全透明的相机在 Unity 里意味着「不清屏」）。
        if (color.a <= 0)
            return;
        // PORT-NOTE: Flixel 未初始化（纯逻辑冒烟测试）时静默跳过 —— 见 RenderBridge.flixelReady。
        if (!RenderBridge.flixelReady())
            return;
        FlxG.cameras.bgColor = flixel.util.FlxColor.fromRGBFloat(color.r, color.g, color.b, 1);
    }

    /**
     * 把本相机的正交参数映射到 Flixel 的默认相机。
     *
     * PORT-NOTE: 只映射"每世界单位多少屏幕像素"与底色 —— 前者由 `orthographicSize` 决定，
     * Flixel 的等价量是 `FlxCamera.zoom`（zoom = 屏幕像素 / 世界单位 ÷ 逻辑像素）。
     * 工程内 `orthographicSize = 3`、逻辑分辨率 720 ⇒ 每世界单位 120 逻辑像素，
     * 因此 zoom 恒为 1（`FlxCamera` 的 1 单位 = 1 逻辑像素）；`orthographicSize` 的差异
     * 通过 `pixelsPerUnit()` 在坐标换算里体现，不改 FlxCamera 本身，避免与
     * `mvz2.ui.UiRenderer` 的屏幕像素假设冲突。
     */
    public function applyToFlxCamera():Void {
        applyBackgroundColor();
    }

    /** 每世界单位对应的屏幕像素数（正交相机：屏幕高度 / 视野高度）。 */
    public function pixelsPerUnit():Float {
        if (!orthographic || orthographicSize <= 0)
            // PORT-NOTE: 透视相机在移植层没有投影矩阵，退化为「1 世界单位 = 1 像素」。
            return 1;
        var height = RenderBridge.logicalHeight() * (rect != null ? rect.height : 1);
        if (height <= 0)
            height = RenderBridge.logicalHeight();
        return height / (orthographicSize * 2);
    }

    function get_aspect():Float {
        var w = RenderBridge.logicalWidth();
        var h = RenderBridge.logicalHeight();
        return rect.width * w / (rect.height * h);
    }
    function set_aspect(v:Float):Float return v;
    function get_pixelWidth():Int return Std.int(RenderBridge.logicalWidth() * rect.width);
    function get_pixelHeight():Int return Std.int(RenderBridge.logicalHeight() * rect.height);

    public function new() {
        super();
        // PORT-NOTE: 登记进渲染桥，让 `Camera.main` / `allCameras` 能看到场景里的真实相机
        //（原 shim 的 Camera.main 是凭空自建的空相机，拿不到 prefab 里的 orthographicSize）。
        RenderBridge.registerCamera(this);
    }

    // PORT-NOTE: Unity 的 Camera.Render() 手动触发一次渲染；移植层由 Flixel/lime 渲染层接管，
    // 这里保留空实现以支持 unity.rendering.RenderPipeline.SubmitRenderRequest 的调用点。
    public function Render():Void {}

    // #region 屏幕 / 世界换算
    //
    // PORT-NOTE: **坐标系是这里最容易搞反的地方**，原 shim 就是错的（它把屏幕 y 直接当世界 y）。
    //
    //   Unity 屏幕坐标：原点在**左下角**，y 轴**向上**，单位像素。
    //   Flixel 屏幕坐标：原点在**左上角**，y 轴**向下**，单位像素。
    //
    // 但是 `unity.Input.mousePosition` 的 shim 返回的是 `FlxG.mouse.screenX/screenY`
    // （**Flixel 风格，y 向下**），而 Unity 的 `Input.mousePosition` 是 y 向上。
    // 调用链是 `Input.mousePosition → InputHelper.GetPointerPosition → MapController.ScreenToWorldPoint`，
    // 因此要让**整条链**自洽，`ScreenToWorldPoint` 必须按「输入 y 向下」实现
    // （x 不受影响，两种约定相同）。等价地：本方法接受的 y 已经是 Flixel 的屏幕 y。
    // 这与 `mvz2.ui.UiRenderer` 的 `y = FlxG.height * 0.5 - (pos.y - origin.y) * scale`
    // 是同一个方向约定。TODO-PORT: 若要严格对齐 Unity（让 `Input.mousePosition` 也 y 向上），
    // 需要输入工作包改 `source/unity/Input.hx`，会波及其它消费者，故本包不动。

    public function ScreenToWorldPoint(position:Vector3):Vector3 {
        var ppu = pixelsPerUnit();
        var origin = worldOrigin();
        // y 向下：屏幕 y 越小越靠上 ⇒ 世界 y 越大。
        return new Vector3(
            origin.x + (position.x - pixelWidth * 0.5) / ppu,
            origin.y + (pixelHeight * 0.5 - position.y) / ppu,
            position.z);
    }
    // PORT-NOTE: 补全 Camera.ViewportToWorldPoint（viewport 是 0..1 归一化，Unity 的 y 向上）。
    public function ViewportToWorldPoint(position:Vector3):Vector3 {
        var ppu = pixelsPerUnit();
        var origin = worldOrigin();
        return new Vector3(
            origin.x + (position.x - 0.5) * pixelWidth / ppu,
            origin.y + (position.y - 0.5) * pixelHeight / ppu,
            position.z);
    }
    public function WorldToScreenPoint(position:Vector3):Vector3 {
        var ppu = pixelsPerUnit();
        var origin = worldOrigin();
        return new Vector3(
            pixelWidth * 0.5 + (position.x - origin.x) * ppu,
            pixelHeight * 0.5 - (position.y - origin.y) * ppu,
            position.z);
    }

    /** 相机的世界位置（`transform.position`；无 transform 时取原点）。 */
    public function worldOrigin():Vector3 {
        return transform != null && transform.position != null ? transform.position : new Vector3(0, 0, 0);
    }
    // #endregion
}
