package unity;

import flixel.math.FlxRandom;

// Minimal UnityEngine.Random shim.
class Random {
    static var rng:FlxRandom = new FlxRandom();

    public static var value(get, never):Float;

    static inline function get_value():Float return rng.float();

    public static function Range(minInclusive:Float, maxInclusive:Float):Float {
        return rng.float(minInclusive, maxInclusive);
    }
    public static function RangeInt(minInclusive:Int, maxExclusive:Int):Int {
        return rng.int(minInclusive, maxExclusive - 1);
    }
    public static function InitState(seed:Int):Void {
        rng.resetInitialSeed();
    }
}
