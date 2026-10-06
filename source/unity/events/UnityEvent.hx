package unity.events;

// Minimal UnityEngine.Events.UnityEvent shim.
// C# 的 `onClick.AddListener(f)` → `onClick.AddListener(f)`（保持调用形式一致）。
class UnityEvent extends UnityEventBase {
    public var listeners:Array<Void->Void> = [];

    public function new() {
        super();
    }

    public function AddListener(call:Void->Void):Void {
        if (call != null) listeners.push(call);
    }
    public function RemoveListener(call:Void->Void):Void {
        listeners.remove(call);
    }
    override public function RemoveAllListeners():Void {
        listeners = [];
    }
    public function Invoke():Void {
        for (l in listeners.copy()) l();
    }
    public function GetListenerCount():Int return listeners.length;
}
