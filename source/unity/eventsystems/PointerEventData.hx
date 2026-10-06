package unity.eventsystems;

import unity.Camera;
import unity.GameObject;
import unity.Vector2;
import unity.Vector3;

// Minimal UnityEngine.EventSystems.PointerEventData shim.
class PointerEventData extends BaseEventData {
    public var position:Vector2 = new Vector2();
    public var delta:Vector2 = new Vector2();
    public var pressPosition:Vector2 = new Vector2();
    public var clickTime:Float = 0;
    public var clickCount:Int = 0;
    public var scrollDelta:Vector2 = new Vector2();
    public var pointerId:Int = -1;
    public var pointerEnter:GameObject;
    public var lastPress:GameObject;
    public var rawPointerPress:GameObject;
    public var pointerDrag:GameObject;
    public var pointerPress:GameObject;
    public var pointerClick:GameObject;
    public var button:InputButton = InputButton.Left;
    public var dragging:Bool = false;
    public var useDragThreshold:Bool = true;
    public var enterEventCamera(get, never):Camera;
    function get_enterEventCamera():Camera return pressEventCamera;
    public var pressEventCamera:Camera;
    public var pointerCurrentRaycast:RaycastResult = new RaycastResult();
    public var pointerPressRaycast:RaycastResult = new RaycastResult();

    public function new(?eventSystem:EventSystem) {
        super(eventSystem);
    }

    public function IsPointerMoving():Bool return delta.x != 0 || delta.y != 0;
    public function IsScrolling():Bool return scrollDelta.x != 0 || scrollDelta.y != 0;
    public function IsPointerOverGameObject():Bool return false;
    override public function IsPointer():Bool return true;
    public function Press(worldPosition:Vector3, pressPosition:Vector2, camera:Camera):Void {}
    public function Release():Void {}
}

// Minimal UnityEngine.EventSystems.RaycastResult shim.
class RaycastResult {
    public var gameObject:GameObject;
    public var module:Dynamic;
    public var distance:Float = 0;
    public var index:Int = 0;
    // C#: public int displayIndex { get; set; }
    public var displayIndex:Int = 0;
    public var depth:Int = 0;
    public var sortingLayer:Int = 0;
    public var sortingOrder:Int = 0;
    public var worldPosition:Vector3 = new Vector3();
    public var worldNormal:Vector3 = new Vector3();
    public var screenPosition:Vector2 = new Vector2();
    public var isValid:Bool = false;

    public function new() {}
    public function Clear():Void isValid = false;
}

// Minimal UnityEngine.EventSystems.PointerEventData.InputButton shim.
enum abstract InputButton(Int) {
    var Left = 0;
    var Right = 1;
    var Middle = 2;
}
