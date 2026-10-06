package unity.events;

// Minimal UnityEngine.Events.UnityEvent<T0, T1> shim.
class UnityEvent2<T0, T1> extends UnityEventBase {
    public var listeners:Array<T0->T1->Void> = [];

    public function new() {
        super();
    }

    public function AddListener(call:T0->T1->Void):Void {
        if (call != null) listeners.push(call);
    }
    public function RemoveListener(call:T0->T1->Void):Void {
        listeners.remove(call);
    }
    override public function RemoveAllListeners():Void {
        listeners = [];
    }
    public function Invoke(arg0:T0, arg1:T1):Void {
        for (l in listeners.copy()) l(arg0, arg1);
    }
    public function GetListenerCount():Int return listeners.length;
}
