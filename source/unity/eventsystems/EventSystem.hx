package unity.eventsystems;

import unity.GameObject;
import unity.eventsystems.PointerEventData.RaycastResult;

// Minimal UnityEngine.EventSystems.EventSystem shim.
class EventSystem extends unity.MonoBehaviour {
    public static var current(get, set):EventSystem;
    private static var _current:EventSystem = null;
    static function get_current():EventSystem return _current;
    static function set_current(value:EventSystem):EventSystem {
        _current = value;
        return value;
    }

    public var sendNavigationEvents:Bool = true;
    public var pixelDragThreshold:Int = 10;
    public var currentSelectedGameObject:GameObject;
    public var firstSelectedGameObject:GameObject;
    public var alreadySelecting(get, never):Bool;
    function get_alreadySelecting():Bool return false;
    public var isFocused(get, never):Bool;
    function get_isFocused():Bool return true;

    public function new() {
        super();
    }

    public function SetSelectedGameObject(selected:GameObject, ?pointer:BaseEventData):Void {
        currentSelectedGameObject = selected;
    }
    public function RaycastAll(pointerData:PointerEventData, raycastResults:Array<RaycastResult>):Void {}
    public function IsPointerOverGameObject(?pointerId:Int = -1):Bool return false;
    public function UpdateModules():Void {}
    public function IsPointerOverGameObjectImpl(pointerId:Int):Bool return false;
}
