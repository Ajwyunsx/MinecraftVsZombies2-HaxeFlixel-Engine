package unity.ui;

import unity.CanvasRenderer;
import unity.Color;
import unity.Material;
import unity.RectTransform;
import unity.Texture;
import unity.Vector2;
import unity.Vector4;
import unity.ui.Selectable.CanvasUpdate;

// Minimal UnityEngine.UI.Graphic shim.
//
// PORT-NOTE: uGUI 的可见性在移植层由 `mvz2.ui.UiRenderer` 承担（把 uGUI 树转成 Flixel 显示
// 列表）。unity 包不能反向依赖 mvz2（会成环），因此这里沿用 `unity.SpriteRenderer.spriteApplier`
// 已确立的**钩子**模式：
//   * `Graphic.visualDirty` —— 由 UiRenderer 安装；任何会改变外观的属性被写入时调用它，
//     UiRenderer 据此把该组件标脏并在下一帧重建对应的 FlxSprite。
//   * `Graphic.revision`   —— 单调递增的版本号，UiRenderer 用它做廉价的变化检测（也覆盖
//     RectTransform 这种普通字段被直接写入、无法挂钩子的情形：UiRenderer 每帧做一次
//     结构同步，只有内容变化时才重建帧/文本）。
class Graphic extends UIBehaviour {
    /** 外观变化钩子（由 mvz2.ui.UiRenderer 安装）。shim 只声明，不实现。 */
    public static var visualDirty:Void->Void = null;
    /** 外观版本号；每次 bump() 递增。 */
    public static var revision:Int = 0;

    /** 标记"这个 Graphic 的外观变了"。 */
    public static function markVisualDirty():Void {
        revision++;
        if (visualDirty != null)
            visualDirty();
    }

    public var color(get, set):Color;
    private var _color:Color = new Color(1, 1, 1, 1);
    function get_color():Color return _color;
    function set_color(v:Color):Color {
        _color = v;
        markVisualDirty();
        return v;
    }
    public var raycastTarget(get, set):Bool;
    private var _raycastTarget:Bool = true;
    function get_raycastTarget():Bool return _raycastTarget;
    function set_raycastTarget(v:Bool):Bool {
        _raycastTarget = v;
        return v;
    }
    public var raycastPadding:Vector4 = new Vector4();
    public var material:Material;
    public var materialForRendering(get, never):Material;
    function get_materialForRendering():Material return material;
    public var canvasRenderer:CanvasRenderer;
    public var canvas(get, never):unity.Canvas;
    function get_canvas():unity.Canvas return unity.Canvas.FindCanvasOf(this);
    public var rectTransform(get, never):RectTransform;
    function get_rectTransform():RectTransform return cast transform;
    public var defaultMaterial:Material;
    public var depth:Int = 0;
    public var useLegacyMeshGeneration:Bool = true;
    public var onCullStateChanged:Dynamic;

    /** PORT-NOTE: 移植层扩展。CanvasRenderer 的实际内容（uGUI 用它提交网格）。 */
    public var canvasRendererEnabled(get, set):Bool;
    private var _canvasRendererEnabled:Bool = true;
    function get_canvasRendererEnabled():Bool return _canvasRendererEnabled;
    function set_canvasRendererEnabled(v:Bool):Bool {
        _canvasRendererEnabled = v;
        markVisualDirty();
        return v;
    }

    public function new() {
        super();
        canvasRenderer = new CanvasRenderer();
    }

    // PORT-NOTE: 这四个 SetXxxDirty 在 Unity 里只是把组件排进重建队列；移植层把它们统一
    // 收敛到 markVisualDirty()，UiRenderer 下一帧重建对应的 FlxSprite。
    public function SetAllDirty():Void markVisualDirty();
    public function SetLayoutDirty():Void markVisualDirty();
    public function SetVerticesDirty():Void markVisualDirty();
    public function SetMaterialDirty():Void markVisualDirty();
    public function SetNativeSize():Void markVisualDirty();
    public function CrossFadeColor(targetColor:Color, duration:Float, ignoreTimeScale:Bool, useAlpha:Bool):Void {
        // PORT-NOTE: Unity 的 CrossFadeColor 是**相对**当前颜色的渐变；移植层无渐变队列，
        // 按"立即落到目标颜色"处理（duration 被忽略），保证调用后画面与 Unity 收敛值一致。
        color = targetColor;
    }
    public function CrossFadeAlpha(alpha:Float, duration:Float, ignoreTimeScale:Bool):Void {
        color = new Color(_color.r, _color.g, _color.b, alpha);
    }
    public function Raycast(sp:Vector2, eventCamera:unity.Camera):Bool return false;
    public function PixelAdjustPoint(point:Vector2):Vector2 return point;
    public function GetPixelAdjustedRect():unity.Rect {
        var rt:RectTransform = cast transform;
        return rt != null ? rt.rect : new unity.Rect();
    }
    public function Rebuild(update:CanvasUpdate):Void {}
    public function LayoutComplete():Void {}
    public function GraphicUpdateComplete():Void {}
    public function IsDestroyed():Bool return destroyed;

    // PORT-NOTE: `destroyed` 继承自 unity.UnityObject，Haxe 不允许子类重定义变量。
    public var canvasRendererExists:Bool = true;
}

// Minimal UnityEngine.UI.MaskableGraphic shim.
class MaskableGraphic extends Graphic {
    public var maskable:Bool = true;
    public var isMaskingGraphic:Bool = false;

    public function new() {
        super();
    }
    public function ParentMaskStateChanged():Void {}
    public function RecalculateMasking():Void {}
}
