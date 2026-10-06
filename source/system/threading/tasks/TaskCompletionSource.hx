// Ported from: System.Threading.Tasks.TaskCompletionSource (minimal shim)
package system.threading.tasks;

class TaskCompletionSource<T>
{
	public var Task(default, null):Task;

	public function new()
	{
		Task = new Task();
	}

	public function SetResult(result:T):Void
	{
		// PORT-NOTE: Task shim 是空壳，仅记录完成状态，不传播回调。
		Task.SetCompleted();
	}

	public function SetException(e:Dynamic):Void
	{
		Task.SetCompleted();
	}
}
