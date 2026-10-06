// Ported from: (HaxePort 新增) 启动链路的错误收集器
// PORT-NOTE: 原工程由 Unity 引擎在启动出错时把异常抛给 GameEntrance.ShowErrorDialog（弹 UI 对话框）。
// 移植层在启动阶段还没有任何 UI（MainSceneUI 的子对象尚未从 prefab 转换），对话框自身也会失败，
// 因此这里额外记录"第一条被记录的错误/异常"，供 ErrorState 降级显示，保证启动失败时给出可读信息。
package mvz2.states;

import unity.Application;
import unity.Application.LogType;

typedef StartupErrorEntry = {
	message:String,
	stackTrace:String,
	logType:LogType
};

class StartupError {
	/** 第一条以 Error/Exception 级别记录的信息（即最先出问题的地方）。 */
	public static var first(default, null):Null<StartupErrorEntry>;
	/** 所有被记录的信息，便于报告与排查。 */
	public static var all(default, null):Array<StartupErrorEntry> = [];
	/** 是否已经把监听器挂到 unity.Application 上（保证只挂一次）。 */
	public static var installed(default, null):Bool = false;

	// PORT-NOTE: 对应 Unity 的 Application.logMessageReceived（Debug.LogException 等会分发到这里，
	// 见 unity/Debug.hx 的 dispatchLog）。
	public static function install():Void {
		if (installed)
			return;
		installed = true;
		Application.logMessageReceived.push(onLogMessage);
	}

	static function onLogMessage(message:String, stackTrace:String, logType:LogType):Void {
		if (message == null)
			message = "";
		var entry:StartupErrorEntry = {
			message: message,
			stackTrace: stackTrace != null ? stackTrace : "",
			logType: logType
		};
		all.push(entry);
		if (first == null && (logType == LogType.Exception || logType == LogType.Error)) {
			first = entry;
		}
		// PORT-NOTE: 同时**实时镜像**到 boot-trace。release 构建没有 HXCPP_CHECK_POINTER，空引用是
		// 直接访问违例（整个进程消失），只存在内存里的 StartupError 会随之丢失；实时落盘后，
		// "最后一条日志"就是崩溃前最后走到的位置，等价于 Unity 控制台里能看到的那份输出。
		if (logType == LogType.Exception || logType == LogType.Error) {
			BootTrace.error('[log] $message');
		} else {
			BootTrace.step('[log] $message');
		}
	}

	/** 直接记录一个捕获到的异常（顶层 try/catch 用）。 */
	public static function record(e:Dynamic):Void {
		var message = Std.string(e);
		var stack = "";
		try {
			stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
		} catch (ignored:Dynamic) {}
		all.push({message: message, stackTrace: stack, logType: LogType.Exception});
		if (first == null) {
			first = all[all.length - 1];
		}
		unity.Debug.LogException(e);
	}

	/** 汇总成一段可显示的多行文本。 */
	public static function describe(?fallback:String = "未知错误"):String {
		var sb = new StringBuf();
		if (first != null) {
			sb.add(first.message);
			var stack = trimStack(first.stackTrace);
			if (stack.length > 0) {
				sb.add("\n");
				sb.add(stack);
			}
		} else {
			sb.add(fallback);
		}
		return sb.toString();
	}

	static function trimStack(stack:String):String {
		if (stack == null || stack.length == 0)
			return "";
		// C# 侧 RunTime 的日志堆栈很长，只取前几行足够定位。
		var lines = stack.split("\n");
		var maxLines = 12;
		if (lines.length <= maxLines)
			return stack;
		return lines.slice(0, maxLines).join("\n");
	}
}
