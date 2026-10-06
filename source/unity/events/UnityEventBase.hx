package unity.events;

// Minimal UnityEngine.Events.UnityEventBase shim.
class UnityEventBase {
    public function new() {}
    public function RemoveAllListeners():Void {}
    public function GetPersistentEventCount():Int return 0;
}

// Minimal UnityEngine.Events.UnityAction delegate placeholder.
typedef UnityAction = Void->Void;
typedef UnityAction1<T> = T->Void;
typedef UnityAction2<T0, T1> = T0->T1->Void;
