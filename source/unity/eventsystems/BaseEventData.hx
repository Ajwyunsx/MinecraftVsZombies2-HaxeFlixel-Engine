package unity.eventsystems;

import unity.GameObject;

// Minimal UnityEngine.EventSystems.BaseEventData shim.
class BaseEventData {
    public var currentInputModule:BaseInputModule;
    public var selectedObject:GameObject;
    public var used:Bool = false;

    public function new(?eventSystem:EventSystem) {}

    public function Use():Void used = true;
    public function Reset():Void used = false;
    public function IsPointer():Bool return false;
}

// Minimal UnityEngine.EventSystems.BaseInputModule shim.
class BaseInputModule {
    public function new() {}
    public function Process():Void {}
    public function IsPointerOverGameObject(pointerId:Int):Bool return false;
}
