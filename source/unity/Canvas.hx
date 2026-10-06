package unity;

// Minimal UnityEngine.Canvas shim.
class Canvas extends Component {
    public static var ForceUpdateCanvases_fn:Void->Void = null;
    public var renderMode:RenderMode = RenderMode.ScreenSpaceOverlay;
    public var worldCamera:Camera;
    public var planeDistance:Float = 100;
    public var sortingLayerID:Int = 0;
    public var sortingLayerName:String = "Default";
    public var sortingOrder:Int = 0;
    public var overrideSorting:Bool = false;
    public var targetDisplay:Int = 0;
    public var pixelPerfect:Bool = false;
    public var scaleFactor:Float = 1;
    public var referencePixelsPerUnit:Float = 100;
    public var isRootCanvas(get, never):Bool;
    function get_isRootCanvas():Bool return transform == null || transform.parent == null;
    public var rootCanvas(get, never):Canvas;
    function get_rootCanvas():Canvas return this;
    public var enabled:Bool = true;

    public function new() {
        super();
    }

    public static function ForceUpdateCanvases():Void {
        if (ForceUpdateCanvases_fn != null) ForceUpdateCanvases_fn();
    }
    public function GetCanvasGroup():CanvasGroup return null;

    // PORT-NOTE: 移植层扩展。`Graphic.canvas` 需要从组件向上找到所属 Canvas
    // （Unity 由引擎维护该引用；shim 里没有组件树索引，故按 Transform 层级向上查）。
    public static function FindCanvasOf(comp:unity.Component):Canvas {
        if (comp == null)
            return null;
        var tr:unity.Transform = comp.transform;
        while (tr != null) {
            var go:GameObject = tr.gameObject;
            if (go != null) {
                var canvas = go.GetComponent(Canvas);
                if (canvas != null)
                    return canvas;
            }
            tr = tr.parent;
        }
        return null;
    }
}

// Minimal UnityEngine.RenderMode shim.
enum abstract RenderMode(Int) {
    var ScreenSpaceOverlay = 0;
    var ScreenSpaceCamera = 1;
    var WorldSpace = 2;
}
