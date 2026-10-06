package unity;

import unity.Coroutine.CoroutineRunner;

// Minimal UnityEngine.MonoBehaviour shim. Lifecycle methods (Awake/Start/Update/...)
// are invoked by the owning scene/state wrapper.
class MonoBehaviour extends Component {
    public var enabled:Bool = true;

    // Coroutine support.
    public var coroutineRunner:CoroutineRunner;

    public function new() {
        super();
        coroutineRunner = new CoroutineRunner();
    }

    public function StartCoroutine(routine:Coroutine):Coroutine {
        return coroutineRunner.start(routine);
    }
    public function StopCoroutine(routine:Coroutine):Void {
        coroutineRunner.stop(routine);
    }
    public function StopAllCoroutines():Void {
        coroutineRunner.stopAll();
    }

    // PORT-NOTE: Unity Debug 的静态方法名为 Log（首字母大写），C# 源码中的 Debug.Log 同名。
    public function print(message:Dynamic):Void {
        unity.Debug.Log(message);
    }
}
