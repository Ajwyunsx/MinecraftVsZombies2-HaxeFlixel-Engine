package unity.eventsystems;

import unity.GameObject;

// Minimal UnityEngine.EventSystems.AxisEventData shim.
class AxisEventData extends BaseEventData {
    public var moveVector:unity.Vector2 = new unity.Vector2();
    public var moveDir:MoveDirection = MoveDirection.None;

    public function new(?eventSystem:EventSystem) {
        super(eventSystem);
    }
}

// Minimal UnityEngine.EventSystems.MoveDirection shim.
enum abstract MoveDirection(Int) {
    var Left = 0;
    var Up = 1;
    var Right = 2;
    var Down = 3;
    var None = 4;
}
