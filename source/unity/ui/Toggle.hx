package unity.ui;

import unity.events.UnityEvent1;
import unity.eventsystems.PointerEventData;

// Minimal UnityEngine.UI.Toggle shim.
class Toggle extends Selectable {
    public var onValueChanged:ToggleEvent = new ToggleEvent();
    public var graphic:Graphic;
    public var toggleTransition:ToggleTransition = ToggleTransition.Fade;
    public var isOn(get, set):Bool;
    function get_isOn():Bool return m_IsOn;
    function set_isOn(v:Bool):Bool {
        Set(v);
        return v;
    }
    public var group:Dynamic;

    private var m_IsOn:Bool = true;

    public function new() {
        super();
    }

    public function SetIsOnWithoutNotify(value:Bool):Void {
        Set(value, false);
    }
    private function Set(value:Bool, ?sendCallback:Bool = true):Void {
        if (m_IsOn == value) return;
        m_IsOn = value;
        PlayEffect(toggleTransition == ToggleTransition.None);
        if (sendCallback) onValueChanged.Invoke(m_IsOn);
    }
    private function PlayEffect(instant:Bool):Void {}
    public function OnPointerClick(eventData:PointerEventData):Void {
        if (!IsInteractable()) return;
        Set(!m_IsOn);
    }
    override public function OnPointerDown(eventData:PointerEventData):Void {
        super.OnPointerDown(eventData);
    }
}

// Minimal UnityEngine.UI.Toggle.ToggleTransition shim.
enum abstract ToggleTransition(Int) {
    var None = 0;
    var Fade = 1;
}

// Minimal UnityEngine.UI.Toggle.ToggleEvent shim.
class ToggleEvent extends UnityEvent1<Bool> {
    public function new() {
        super();
    }
}
