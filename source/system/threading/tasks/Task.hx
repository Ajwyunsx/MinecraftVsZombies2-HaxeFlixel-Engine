// Ported from: System.Threading.Tasks.Task (minimal shim for C# async Task used by logic interfaces)
package system.threading.tasks;

// PORT-NOTE: 工程内唯一的 Task shim。此前同时存在 unity.Task 与 system.threading.tasks.Task
// 两套同源实现（都是 C# 的 System.Threading.Tasks.Task），互不兼容，导致
// mvz2.scenes.MainSceneController 等文件无法通过类型检查。现统一到本类，
// source/unity/Task.hx 只保留 `typedef Task = system.threading.tasks.Task` 别名。
// 为兼容两批调用点，本类同时保留 C# 原名（IsCompleted / Result / CompletedTask）
// 与早期移植层的驼峰名（isCompleted / result / completedTask）。
class Task
{
	public static var CompletedTask(get, never):Task;
	private static var _completed:Task;
	private static function get_CompletedTask():Task
	{
		if (_completed == null)
			_completed = new Task();
		return _completed;
	}

	public var IsCompleted(default, null):Bool = false;

	public var isCompleted(get, never):Bool;
	inline function get_isCompleted():Bool return IsCompleted;

	// C#: Task.CompletedTask（属性）在旧移植层被写成方法形式 completedTask()。
	public static function completedTask():Task return CompletedTask;

	// C#: public static Task FromResult<T>(T result)
	public static function fromResult(value:Dynamic):Task
	{
		var t = new Task();
		t.Result = value;
		t.SetCompleted();
		return t;
	}
	// C#: public static Task Delay(int millisecondsDelay)
	public static function delay(milliseconds:Int):Task
	{
		// TODO-PORT: delayed task requires a scheduler.
		return new Task();
	}

	public function new() {}

	public function SetCompleted():Void
	{
		IsCompleted = true;
	}

	// PORT-NOTE: 旧 unity.Task 的 `completed` 字段形式（unity.TaskCompletionSource 使用）。
	public var completed(get, set):Bool;
	inline function get_completed():Bool return IsCompleted;
	function set_completed(v:Bool):Bool
	{
		IsCompleted = v;
		return v;
	}

	public var exception:Dynamic = null;

	// PORT-NOTE: C# 的 `await task` 在移植层写作 awaitResult()（阻塞等待并取回结果）。
	public var Result:Dynamic = null;

	// PORT-NOTE: 旧 unity.Task 使用小写 result。
	public var result(get, set):Dynamic;
	inline function get_result():Dynamic return Result;
	function set_result(v:Dynamic):Dynamic
	{
		Result = v;
		return v;
	}

	public function awaitResult():Dynamic
	{
		return Result;
	}
}
