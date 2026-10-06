// Ported from: (HaxePort 新增) 启动步骤追踪
// PORT-NOTE: 移植阶段的启动链路在失败时完全没有可见输出——lime 的 Windows GUI 程序不写 stdout
// （trace 无控制台可接收），而原工程的 MVZ2Logger 要到 InitState 里才被 Awake 起来，
// 之前（含 MVZ2Logger 自身失败）的崩溃就无从定位。这里把启动步骤写入日志文件，
// 作用等价于 MVZ2Logger 记录的启动日志，只是提前到进程启动的第一行。
// TODO-PORT: 启动链路稳定、UI 能够显示错误后，本类可以移除。
package mvz2.states;

import sys.io.File;
import sys.io.FileOutput;

class BootTrace {
	static var output:Null<FileOutput>;
	static var unavailable:Bool = false;
	static var path:Null<String>;

	/** 开始（或继续）一次启动追踪。 */
	public static function start():Void {
		if (output != null || unavailable)
			return;
		for (candidate in candidatePaths()) {
			try {
				output = File.write(candidate, false);
				path = candidate;
				break;
			} catch (e:Dynamic) {}
		}
		if (output == null) {
			unavailable = true;
			return;
		}
		write('--- MVZ2 boot trace ${Date.now().toString()} (file=$path) ---');
	}

	public static function step(name:String):Void {
		write('[step] $name');
	}

	public static function error(name:String):Void {
		write('[error] $name');
	}

	public static function finish(name:String):Void {
		write('[done] $name');
		// PORT-NOTE: 刻意**不**关闭文件句柄——启动完成之后 Update 循环里的失败（挂在
		// MainGameScene.update 的 try/catch 里）同样要能落盘，否则「启动成功」之后的所有问题
		// 都无从观察（lime 的 Windows GUI 程序没有 stdout）。每次 write 都会 flush，句柄常开无妨。
		if (output != null) {
			try {
				output.flush();
			} catch (e:Dynamic) {}
		}
	}

	public static function close():Void {
		if (output != null) {
			try {
				output.flush();
				output.close();
			} catch (e:Dynamic) {}
			output = null;
		}
	}

	static function write(line:String):Void {
		trace('[MVZ2] $line');
		if (unavailable)
			return;
		if (output == null)
			start();
		if (output == null)
			return;
		try {
			output.writeString(line);
			output.writeString("\n");
			output.flush();
		} catch (e:Dynamic) {
			output = null;
			unavailable = true;
		}
	}

	/**
	 * PORT-NOTE: 依次尝试多个可写位置，保证"启动失败时至少有一份记录"。
	 * 这里**只使用 sys API**（工作目录 / 系统临时目录），刻意不碰 lime/toLime 的
	 * Application.persistentDataPath——它在启动最早期的可分性尚未验证，若它自身崩溃，
	 * 反而会让追踪文件永远写不出来。
	 */
	static function candidatePaths():Array<String> {
		var paths:Array<String> = [];
		#if sys
		paths.push(Sys.getCwd() + "/boot-trace.log");
		var temp = Sys.getEnv("TEMP");
		if (temp != null)
			paths.push(temp + "/mvz2-boot-trace.log");
		#end
		return paths;
	}
}
