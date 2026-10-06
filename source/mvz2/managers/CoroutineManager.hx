// Ported from: Assets/Scripts/MVZ2/Managers/CoroutineManager.cs
package mvz2.managers;

import system.threading.tasks.Task;
import system.threading.tasks.TaskCompletionSource;
import unity.Coroutine;
import unity.Coroutine.CoroutineContext;
import unity.MonoBehaviour;

class CoroutineManager extends MonoBehaviour
{
	/**
	 * 等待一个协程结束，并返回对应的 Task。
	 */
	public function ToTask(coroutine:Coroutine):Task
	{
		var tcs = new TaskCompletionSource<Dynamic>();
		// PORT-NOTE: Haxe 的局部函数需先声明后使用（C# 中直接传方法组）。
		function routine():Coroutine
		{
			return Coroutine.create(function(co:CoroutineContext)
			{
				// TODO-PORT: C# 的 `yield return coroutine;` 由 Unity 引擎驱动那个协程；
				//   移植层若它没有被显式 StartCoroutine，这里的轮询会永远等下去。
				//   更贴近原语义的写法是 `co.waitCoroutine(coroutine)`（会自动接手驱动未启动的子协程），
				//   但本方法的唯一调用点 `ResourceManager.LoadModels → ShotModelIcons` 是**模型图标截图**
				//   流水线：改成 waitCoroutine 会让这条原先从未真正执行的渲染路径在启动期跑起来，
				//   其行为（RenderTexture/相机截图在 shim 下的结果）无法在本工作包内验证。
				//   故此处保持原样，留待模型图标工作包一并处理。
				while (coroutine != null && !coroutine.finished)
				{
					co.waitFrames(1);
				}
				tcs.SetResult(null);
			});
		}
		StartCoroutine(routine());
		return tcs.Task;
	}
	/**
	 * 等待一个迭代器（协程体）结束，并返回对应的 Task。
	 */
	// PORT-NOTE: C# 中这是 `ToTask(IEnumerator)` 重载；Haxe 不支持重载，
	// 且既有调用点只传 Coroutine，故改名保留（当前无调用方）。
	public function ToTaskFromEnumerator(enumerator:Iterator<Dynamic>):Task
	{
		var tcs = new TaskCompletionSource<Dynamic>();
		function routine():Coroutine
		{
			return Coroutine.create(function(co:CoroutineContext)
			{
				// TODO-PORT: C# 的 `yield return enumerator` 在 Haxe 中无法表达，
				// 这里尝试用迭代器驱动的方式等待其结束。
				while (enumerator != null && enumerator.hasNext())
				{
					enumerator.next();
					co.waitFrames(1);
				}
				tcs.SetResult(null);
			});
		}
		StartCoroutine(routine());
		return tcs.Task;
	}
	public function ToCoroutine(task:Task):Coroutine
	{
		return StartCoroutine(ToCoroutineFunc(task));
	}
	public function ToCoroutineFunc(task:Task):Coroutine
	{
		return Coroutine.create(function(co:CoroutineContext)
		{
			while (!task.IsCompleted)
				co.waitFrames(1);
		});
	}
	public function DelaySeconds(seconds:Float):Task
	{
		var tcs = new TaskCompletionSource<Dynamic>();
		function routine():Coroutine
		{
			return Coroutine.create(function(co:CoroutineContext)
			{
				co.wait(seconds);
				tcs.SetResult(null);
			});
		}
		StartCoroutine(routine());
		return tcs.Task;
	}
}
