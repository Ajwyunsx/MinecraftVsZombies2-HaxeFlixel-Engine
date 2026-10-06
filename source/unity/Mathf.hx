package unity;

// Minimal UnityEngine.Mathf shim.
class Mathf {
    public static inline var PI:Float = 3.14159265358979;
    public static var Infinity:Float = Math.POSITIVE_INFINITY;
    public static var NegativeInfinity:Float = Math.NEGATIVE_INFINITY;
    public static inline var Deg2Rad:Float = PI * 2 / 360;
    public static inline var Rad2Deg:Float = 360 / (PI * 2);
    public static inline var Epsilon:Float = 1.401298e-45;

    public static function Abs(f:Float):Float return Math.abs(f);
    public static function Sign(f:Float):Float return f < 0 ? -1 : 1;
    public static function Floor(f:Float):Float return Math.floor(f);
    public static function Ceil(f:Float):Float return Math.ceil(f);
    public static function Round(f:Float):Float return Math.round(f);
    public static function FloorToInt(f:Float):Int return Math.floor(f);
    public static function CeilToInt(f:Float):Int return Math.ceil(f);
    public static function RoundToInt(f:Float):Int return Math.round(f);
    public static function Sqrt(f:Float):Float return Math.sqrt(f);
    public static function Pow(f:Float, p:Float):Float return Math.pow(f, p);
    public static function Exp(power:Float):Float return Math.exp(power);
    public static function Log(f:Float, ?p:Float):Float return p == null ? Math.log(f) : Math.log(f) / Math.log(p);
    public static function Log10(f:Float):Float return Math.log(f) / Math.log(10);
    public static function Sin(f:Float):Float return Math.sin(f);
    public static function Cos(f:Float):Float return Math.cos(f);
    public static function Tan(f:Float):Float return Math.tan(f);
    public static function Asin(f:Float):Float return Math.asin(f);
    public static function Acos(f:Float):Float return Math.acos(f);
    public static function Atan(f:Float):Float return Math.atan(f);
    public static function Atan2(y:Float, x:Float):Float return Math.atan2(y, x);

    public static function Clamp(value:Float, a:Float, b:Float):Float {
        if (value < a) return a;
        if (value > b) return b;
        return value;
    }
    public static function ClampInt(value:Int, a:Int, b:Int):Int {
        if (value < a) return a;
        if (value > b) return b;
        return value;
    }
    public static function Clamp01(value:Float):Float {
        if (value < 0) return 0;
        if (value > 1) return 1;
        return value;
    }
    public static function Lerp(a:Float, b:Float, t:Float):Float return a + (b - a) * Clamp01(t);
    public static function LerpUnclamped(a:Float, b:Float, t:Float):Float return a + (b - a) * t;
    public static function InverseLerp(a:Float, b:Float, value:Float):Float {
        if (a != b) return Clamp01((value - a) / (b - a));
        return 0;
    }
    public static function MoveTowards(current:Float, target:Float, maxDelta:Float):Float {
        if (Math.abs(target - current) <= maxDelta) return target;
        return current + Sign(target - current) * maxDelta;
    }
    public static function Max(a:Float, b:Float):Float return Math.max(a, b);
    public static function Min(a:Float, b:Float):Float return Math.min(a, b);
    public static function MaxInt(a:Int, b:Int):Int return Std.int(Math.max(a, b));
    public static function MinInt(a:Int, b:Int):Int return Std.int(Math.min(a, b));
    public static function Repeat(t:Float, length:Float):Float {
        return Clamp(t - Math.floor(t / length) * length, 0, length);
    }
    public static function PingPong(t:Float, length:Float):Float {
        t = Repeat(t, length * 2);
        return length - Math.abs(t - length);
    }
    public static function DeltaAngle(current:Float, target:Float):Float {
        var delta = Repeat(target - current, 360);
        if (delta > 180) delta -= 360;
        return delta;
    }
    public static function SmoothDamp(current:Float, target:Float, currentVelocity:FloatRef, smoothTime:Float, maxSpeed:Float, deltaTime:Float):Float {
        // TODO-PORT: full SmoothDamp implementation
        smoothTime = Math.max(0.0001, smoothTime);
        var omega = 2 / smoothTime;
        var x = omega * deltaTime;
        var exp = 1 / (1 + x + 0.48 * x * x + 0.235 * x * x * x);
        var change = current - target;
        var originalTo = target;
        var maxChange = maxSpeed * smoothTime;
        change = Clamp(change, -maxChange, maxChange);
        target = current - change;
        var temp = (currentVelocity.value + omega * change) * deltaTime;
        currentVelocity.value = (currentVelocity.value - omega * temp) * exp;
        var output = target + (change + temp) * exp;
        if ((originalTo - current > 0.0) == (output > originalTo)) {
            output = originalTo;
            currentVelocity.value = (output - originalTo) / deltaTime;
        }
        return output;
    }
    public static function Approximately(a:Float, b:Float):Bool {
        return Math.abs(b - a) < Math.max(1E-06 * Math.max(Math.abs(a), Math.abs(b)), Epsilon * 8);
    }
}

// Helper ref type for out/ref parameters.
typedef FloatRef = {value:Float};
