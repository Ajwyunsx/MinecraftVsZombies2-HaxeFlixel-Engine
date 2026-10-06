// Ported from: System.TimeSpan (minimal shim)
package system;

class TimeSpan {
    public var TotalSeconds(get, never):Float;
    function get_TotalSeconds():Float return milliseconds / 1000;
    // C#: public double TotalMinutes { get; } / TotalHours { get; }
    public var TotalMinutes(get, never):Float;
    function get_TotalMinutes():Float return milliseconds / 60000;
    public var TotalHours(get, never):Float;
    function get_TotalHours():Float return milliseconds / 3600000;
    // C#: public int Minutes { get; } / Hours { get; } / Seconds { get; }（时间跨度内的分量，可负）
    public var Minutes(get, never):Int;
    function get_Minutes():Int return Std.int(get_TotalMinutes()) % 60;
    public var Hours(get, never):Int;
    function get_Hours():Int return Std.int(get_TotalHours()) % 24;
    public var Seconds(get, never):Int;
    function get_Seconds():Int return Std.int(Std.int(milliseconds) / 1000) % 60;
    // C#: public double TotalMilliseconds { get; }
    public var TotalMilliseconds(get, never):Float;
    function get_TotalMilliseconds():Float return milliseconds;
    public var Milliseconds(get, never):Int;
    function get_Milliseconds():Int return Std.int(milliseconds) % 1000;

    private var milliseconds:Float;

    public function new(milliseconds:Float) {
        this.milliseconds = milliseconds;
    }

    public static function FromSeconds(seconds:Float):TimeSpan {
        return new TimeSpan(seconds * 1000);
    }
    public static function FromMilliseconds(value:Float):TimeSpan {
        return new TimeSpan(value);
    }

    // PORT-NOTE: 仅支持 NightmareaperTimerModel 使用的 "mm:ss.ff" 格式。
    public function ToString(?format:String):String {
        var totalMs = Std.int(milliseconds);
        var minutes = Std.int(totalMs / 60000);
        var seconds = Std.int((totalMs % 60000) / 1000);
        var hundredths = Std.int((totalMs % 1000) / 10);
        if (format == null)
            return '${pad(minutes, 2)}:${pad(seconds, 2)}.${pad(hundredths, 2)}';
        return '${pad(minutes, 2)}:${pad(seconds, 2)}.${pad(hundredths, 2)}';
    }

    static function pad(value:Int, digits:Int):String {
        var s = Std.string(value);
        while (s.length < digits) s = "0" + s;
        return s;
    }
}
