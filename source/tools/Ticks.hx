// Ported from: Tools.Ticks (external Tools assembly dependency of MVZ2)
// PORT-NOTE: the original Tools assembly defines Ticks.SmoothDamp as overloads for float and Vector3;
// Haxe has no overloading, so the vector variant is exposed as SmoothDampVector.
package tools;

import unity.Mathf;
import unity.Vector3;

class Ticks
{
    public static inline var TICKS_PER_SECOND:Float = 50;

    public static function FromSeconds(seconds:Float):Int
    {
        return Std.int(seconds * TICKS_PER_SECOND);
    }

    public static function ToSeconds(ticks:Int):Float
    {
        return ticks / TICKS_PER_SECOND;
    }

    public static function SmoothDamp(current:Float, target:Float, smoothTime:Float):Float
    {
        if (smoothTime <= 0)
            return target;
        var t = Mathf.Clamp01(1 / (smoothTime * TICKS_PER_SECOND));
        return current + (target - current) * t;
    }

    public static function SmoothDampVector(current:Vector3, target:Vector3, smoothTime:Float):Vector3
    {
        if (smoothTime <= 0)
            return target;
        var t = Mathf.Clamp01(1 / (smoothTime * TICKS_PER_SECOND));
        return current + (target - current) * t;
    }
}
