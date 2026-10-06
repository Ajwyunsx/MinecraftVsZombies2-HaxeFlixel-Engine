package unity.ui;

import unity.RectTransform;
import unity.events.UnityEvent1;
import unity.eventsystems.PointerEventData;

// Minimal UnityEngine.UI.Scrollbar shim.
class Scrollbar extends Selectable {
    public var handleRect:RectTransform;
    public var direction:ScrollbarDirection = ScrollbarDirection.LeftToRight;
    public var value(get, set):Float;
    function get_value():Float return m_Value;
    function set_value(v:Float):Float {
        Set(v);
        return m_Value;
    }
    public var size:Float = 0.2;
    public var numberOfSteps:Int = 0;
    public var onValueChanged:ScrollEvent = new ScrollEvent();

    private var m_Value:Float = 0;

    public function new() {
        super();
    }

    public function SetValueWithoutNotify(input:Float):Void {
        Set(input, false);
    }
    private function Set(input:Float, ?sendCallback:Bool = true):Void {
        var newValue = ClampValue(input);
        if (m_Value == newValue) return;
        m_Value = newValue;
        UpdateVisuals();
        if (sendCallback) onValueChanged.Invoke(m_Value);
    }
    public function ClampValue(input:Float):Float return unity.Mathf.Clamp01(input);
    public function UpdateVisuals():Void {}
    override public function OnPointerDown(eventData:PointerEventData):Void {
        super.OnPointerDown(eventData);
    }
    public function OnDrag(eventData:PointerEventData):Void {}
    override public function OnMove(eventData:unity.eventsystems.AxisEventData):Void {}
    public function OnInitializePotentialDrag(eventData:PointerEventData):Void {}
}

// Minimal UnityEngine.UI.Scrollbar.Direction shim.
enum abstract ScrollbarDirection(Int) {
    var LeftToRight = 0;
    var RightToLeft = 1;
    var BottomToTop = 2;
    var TopToBottom = 3;
}

// Minimal UnityEngine.UI.Scrollbar.ScrollEvent shim.
class ScrollEvent extends UnityEvent1<Float> {
    public function new() {
        super();
    }
}
