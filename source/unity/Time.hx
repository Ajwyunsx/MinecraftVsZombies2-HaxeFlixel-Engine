package unity;

import flixel.FlxG;

// Minimal UnityEngine.Time shim, bridged to Flixel.
class Time {
    public static var deltaTime(get, never):Float;
    public static var time(get, never):Float;
    public static var realtimeSinceStartup(get, never):Float;
    // C# UnityEngine.Time.unscaledTime（不受 timeScale 影响的运行时间）。
    public static var unscaledTime(get, never):Float;
    public static var fixedDeltaTime:Float = 1 / 50;
    public static var timeScale:Float = 1;
    public static var frameCount(get, never):Int;

    static inline function get_deltaTime():Float return FlxG.elapsed * timeScale;
    static function get_time():Float return haxe.Timer.stamp();
    static function get_realtimeSinceStartup():Float return haxe.Timer.stamp();
    static function get_unscaledTime():Float return haxe.Timer.stamp();
    static inline function get_frameCount():Int return FlxG.elapsed > 0 ? Std.int(get_time() / FlxG.elapsed) : 0;
}
