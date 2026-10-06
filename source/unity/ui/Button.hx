package unity.ui;

import unity.events.UnityEvent;
import unity.eventsystems.AxisEventData;
import unity.eventsystems.BaseEventData;
import unity.eventsystems.PointerEventData;
import unity.Animator;

// Minimal UnityEngine.UI.Button shim.
class Button extends Selectable {
    public var onClick:ButtonClickedEvent = new ButtonClickedEvent();
    public var onPointerDownEvent:Array<PointerEventData->Void> = [];

    public function new() {
        super();
    }

    public function OnPointerClick(eventData:PointerEventData):Void {
        if (!IsInteractable()) return;
        onClick.Invoke();
    }
    public function OnSubmit(eventData:BaseEventData):Void {
        if (!IsInteractable()) return;
        onClick.Invoke();
    }
    override public function OnPointerDown(eventData:PointerEventData):Void {
        super.OnPointerDown(eventData);
    }
    override public function OnPointerUp(eventData:PointerEventData):Void {
        super.OnPointerUp(eventData);
    }
    public function OnPointerEnterPublic(eventData:PointerEventData):Void {}
}

// Minimal UnityEngine.UI.Button.ButtonClickedEvent shim.
class ButtonClickedEvent extends UnityEvent {
    public function new() {
        super();
    }
}
