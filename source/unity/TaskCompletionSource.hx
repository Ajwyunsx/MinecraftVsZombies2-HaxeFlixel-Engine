package unity;

// Minimal System.Threading.Tasks.TaskCompletionSource shim.
// PORT-NOTE: C#'s `tcs.Task` is exposed as `tcs.task` (a property named `Task` would
// shadow the type name inside this module).
class TaskCompletionSource {
    public var task(default, null):Task;

    public function new() {
        task = new Task();
    }

    public function SetResult(value:Dynamic):Void {
        task.result = value;
        task.completed = true;
    }
    // PORT-NOTE: C# TaskCompletionSource.TrySetResult returns whether the task was completed by
    // this call; the shim mirrors that.
    public function TrySetResult(value:Dynamic):Bool {
        if (task.completed) return false;
        SetResult(value);
        return true;
    }
    public function TrySetException(exception:Dynamic):Bool {
        if (task.completed) return false;
        SetException(exception);
        return true;
    }
    public function TrySetCanceled():Bool {
        if (task.completed) return false;
        SetCanceled();
        return true;
    }
    public function SetException(exception:Dynamic):Void {
        task.exception = exception;
        task.completed = true;
    }
    public function SetCanceled():Void {
        task.completed = true;
    }
    public var Task(get, never):Task;
    inline function get_Task():Task return task;
}
