package unity.ui;

// Minimal UnityEngine.UI.CanvasScaler shim.
class CanvasScaler extends UIBehaviour {
    public var uiScaleMode:ScaleMode = ScaleMode.ConstantPixelSize;
    public var referencePixelsPerUnit:Float = 100;
    public var scaleFactor:Float = 1;
    public var referenceResolution:unity.Vector2 = new unity.Vector2(800, 600);
    public var screenMatchMode:ScreenMatchMode = ScreenMatchMode.MatchWidthOrHeight;
    public var matchWidthOrHeight:Float = 0;
    public var physicalUnit:Int = 0;
    public var fallbackScreenDPI:Float = 96;
    public var defaultSpriteDPI:Float = 96;
    public var dynamicPixelsPerUnit:Float = 1;

    public function new() {
        super();
    }
    public function Handle():Void {}
    public function OnEnableImpl():Void {}
}

// Minimal UnityEngine.UI.CanvasScaler.ScaleMode shim.
enum abstract ScaleMode(Int) {
    var ConstantPixelSize = 0;
    var ScaleWithScreenSize = 1;
    var ConstantPhysicalSize = 2;
}

// Minimal UnityEngine.UI.CanvasScaler.ScreenMatchMode shim.
enum abstract ScreenMatchMode(Int) {
    var MatchWidthOrHeight = 0;
    var Expand = 1;
    var Shrink = 2;
}

// Minimal UnityEngine.UI.GraphicRaycaster shim.
class GraphicRaycaster extends UIBehaviour {
    public var ignoreReversedGraphics:Bool = true;
    public var blockingObjects:BlockingObjects = BlockingObjects.None;
    public var blockingMask:unity.LayerMask = new unity.LayerMask();

    public function new() {
        super();
    }
    public function Raycast(eventData:unity.eventsystems.PointerEventData, resultAppendList:Array<unity.eventsystems.PointerEventData.RaycastResult>):Void {}
    public var eventCamera(get, never):unity.Camera;
    function get_eventCamera():unity.Camera return null;
}

// Minimal UnityEngine.UI.GraphicRaycaster.BlockingObjects shim.
enum abstract BlockingObjects(Int) {
    var None = 0;
    var TwoD = 1;
    var ThreeD = 2;
    var All = 3;
}
