package unity;

// Minimal UnityEngine.WaitForSeconds shim (coroutine yield instruction).
// PORT-NOTE: C# 协程 yield 对象 → 由 CoroutineRunner 逐帧调用 isDone 判断是否继续等待。
class WaitForSeconds {
	public var seconds:Float;
	public var elapsed:Float = 0;

	public function new(seconds:Float) {
		this.seconds = seconds;
	}

	public function reset():Void {
		elapsed = 0;
	}

	public function isDone(deltaTime:Float):Bool {
		elapsed += deltaTime;
		return elapsed >= seconds;
	}

	public function ToString():String return 'WaitForSeconds($seconds)';
}
