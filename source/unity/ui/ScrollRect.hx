package unity.ui;

import unity.RectTransform;
import unity.Vector2;
import unity.Vector3;
import unity.eventsystems.PointerEventData;
import unity.eventsystems.BaseEventData;
import unity.ui.Selectable.CanvasUpdate;

// Minimal UnityEngine.UI.ScrollRect shim.
class ScrollRect extends UIBehaviour {
    public var content:RectTransform;
    public var viewport:RectTransform;
    public var horizontal:Bool = true;
    public var vertical:Bool = true;
    public var movementType:MovementType = MovementType.Elastic;
    public var elasticity:Float = 0.1;
    public var inertia:Bool = true;
    public var decelerationRate:Float = 0.135;
    public var scrollSensitivity:Float = 1;
    public var horizontalScrollbar:Scrollbar;
    public var verticalScrollbar:Scrollbar;
    public var horizontalScrollbarVisibility:ScrollbarVisibility = ScrollbarVisibility.Permanent;
    public var verticalScrollbarVisibility:ScrollbarVisibility = ScrollbarVisibility.Permanent;
    public var horizontalScrollbarSpacing:Float = 0;
    public var verticalScrollbarSpacing:Float = 0;
    public var onValueChanged:ScrollRectEvent = new ScrollRectEvent();
    public var velocity:Vector2 = new Vector2();
    public var normalizedPosition:Vector2 = new Vector2(0, 1);
    public var horizontalNormalizedPosition(get, set):Float;
    function get_horizontalNormalizedPosition():Float return 1;
    function set_horizontalNormalizedPosition(v:Float):Float return v;
    public var verticalNormalizedPosition(get, set):Float;
    function get_verticalNormalizedPosition():Float return 1;
    function set_verticalNormalizedPosition(v:Float):Float return v;

    public function new() {
        super();
    }

    public function Rebuild(executing:CanvasUpdate):Void {}
    public function LayoutComplete():Void {}
    public function GraphicUpdateComplete():Void {}
    public function IsDestroyed():Bool return false;
    public function StopMovement():Void {}
    public function OnScroll(eventData:PointerEventData):Void {}
    public function OnInitializePotentialDrag(eventData:PointerEventData):Void {}
    public function OnBeginDrag(eventData:PointerEventData):Void {}
    public function OnEndDrag(eventData:PointerEventData):Void {}
    public function OnDrag(eventData:PointerEventData):Void {}
}

// Minimal UnityEngine.UI.ScrollRect.MovementType shim.
enum abstract MovementType(Int) {
    var Unrestricted = 0;
    var Elastic = 1;
    var Clamped = 2;
}

// Minimal UnityEngine.UI.ScrollRect.ScrollbarVisibility shim.
enum abstract ScrollbarVisibility(Int) {
    var Permanent = 0;
    var AutoHide = 1;
    var AutoHideAndExpandViewport = 2;
}

// Minimal UnityEngine.UI.ScrollRect.ScrollRectEvent shim.
class ScrollRectEvent extends unity.events.UnityEvent1<Vector2> {
    public function new() {
        super();
    }
}
