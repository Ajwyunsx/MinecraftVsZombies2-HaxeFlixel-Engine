package unity;

// Minimal UnityEngine.Resolution shim.
class Resolution
{
	public var width:Int;
	public var height:Int;
	public var refreshRateRatio:RefreshRate;

	// PORT-NOTE: 兼容旧版 UnityEngine.Resolution.refreshRate（Haxe 无属性重载，改用方法）。
	public var refreshRate(get, never):Int;
	private function get_refreshRate():Int
	{
		return refreshRateRatio == null ? 0 : Std.int(refreshRateRatio.value);
	}

	public function new(width:Int = 0, height:Int = 0, ?refreshRateRatio:RefreshRate)
	{
		this.width = width;
		this.height = height;
		this.refreshRateRatio = refreshRateRatio;
	}

	public function toString():String
	{
		return '${width}x${height}';
	}
}
