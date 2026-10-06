package unity.ui;

import unity.RectTransform;
import unity.events.UnityEvent1;
import unity.eventsystems.PointerEventData;

// Minimal UnityEngine.UI.Slider shim.
class Slider extends Selectable {
    public var fillRect:RectTransform;
    public var handleRect:RectTransform;
    public var direction:SliderDirection = SliderDirection.LeftToRight;
    public var minValue:Float = 0;
    public var maxValue:Float = 1;
    public var wholeNumbers:Bool = false;
    public var value(get, set):Float;
    function get_value():Float return m_Value;
    function set_value(v:Float):Float {
        Set(v);
        return m_Value;
    }
    public var normalizedValue(get, set):Float;
    function get_normalizedValue():Float return Math.abs(maxValue - minValue) > 1e-05 ? (m_Value - minValue) / (maxValue - minValue) : 0;
    function set_normalizedValue(v:Float):Float {
        value = v * (maxValue - minValue) + minValue;
        return v;
    }
    public var onValueChanged:SliderEvent = new SliderEvent();

    private var m_Value:Float = 0;

    public function new() {
        super();
    }

    public function SetValueWithoutNotify(input:Float):Void {
        Set(input, false);
    }
    public function Set(input:Float, ?sendCallback:Bool = true):Void {
        var newValue = ClampValue(input);
        if (m_Value == newValue) return;
        m_Value = newValue;
        UpdateVisuals();
        if (sendCallback) onValueChanged.Invoke(m_Value);
    }
    public function ClampValue(input:Float):Float {
        var v = unity.Mathf.Clamp(input, minValue, maxValue);
        if (wholeNumbers) v = unity.Mathf.Round(v);
        return v;
    }
    public function UpdateVisuals():Void {}
    public function OnDrag(eventData:PointerEventData):Void {}
    override public function OnPointerDown(eventData:PointerEventData):Void {}
    override public function OnMove(eventData:unity.eventsystems.AxisEventData):Void {}
}

// Minimal UnityEngine.UI.Slider.Direction shim.
enum abstract SliderDirection(Int) {
    var LeftToRight = 0;
    var RightToLeft = 1;
    var BottomToTop = 2;
    var TopToBottom = 3;
}

// Minimal UnityEngine.UI.Slider.SliderEvent shim.
class SliderEvent extends UnityEvent1<Float> {
    public function new() {
        super();
    }
}
