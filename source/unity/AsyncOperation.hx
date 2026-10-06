package unity;

import flixel.util.FlxSignal.FlxTypedSignal;

// Minimal UnityEngine.AsyncOperation shim (used for web requests and scene loads).
class AsyncOperation {
    public var isDone(default, null):Bool = false;
    public var progress:Float = 0;
    public var completed:FlxTypedSignal<AsyncOperation->Void> = new FlxTypedSignal();

    public function new() {}

    public function complete():Void {
        if (isDone) return;
        isDone = true;
        progress = 1;
        completed.dispatch(this);
    }
    public var allowSceneActivation:Bool = true;
    public var priority:Int = 0;
}
