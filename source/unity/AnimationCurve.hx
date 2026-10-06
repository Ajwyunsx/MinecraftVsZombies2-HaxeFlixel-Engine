package unity;

// Minimal UnityEngine.AnimationCurve shim.
class AnimationCurve {
    public var keys:Array<Keyframe> = [];
    public var length(get, never):Int;
    function get_length():Int return keys.length;
    public var preWrapMode:WrapMode = WrapMode.Default;
    public var postWrapMode:WrapMode = WrapMode.Default;

    public function new(?keys:Array<Keyframe>) {
        if (keys != null) this.keys = keys;
    }

    public static var linear(get, never):AnimationCurve;
    static function get_linear():AnimationCurve return new AnimationCurve([new Keyframe(0, 0), new Keyframe(1, 1)]);
    public static var easeInOut(get, never):AnimationCurve;
    static function get_easeInOut():AnimationCurve return new AnimationCurve([new Keyframe(0, 0), new Keyframe(1, 1)]);
    public static var constant(get, never):AnimationCurve;
    static function get_constant():AnimationCurve return new AnimationCurve([new Keyframe(0, 0), new Keyframe(1, 0)]);

    public static function Constant(value:Float):AnimationCurve return new AnimationCurve([new Keyframe(0, value), new Keyframe(1, value)]);
    public static function Linear(a:Float, b:Float):AnimationCurve return new AnimationCurve([new Keyframe(0, a), new Keyframe(1, b)]);
    public static function EaseInOut(a:Float, b:Float):AnimationCurve return Linear(a, b);

    public function Evaluate(time:Float):Float {
        if (keys.length == 0) return 0;
        if (keys.length == 1) return keys[0].value;
        // PORT-NOTE: 线性插值近似 Unity 的样条求值。
        for (i in 0...keys.length - 1) {
            var k0 = keys[i];
            var k1 = keys[i + 1];
            if (time >= k0.time && time <= k1.time) {
                var span = k1.time - k0.time;
                if (span == 0) return k1.value;
                var t = (time - k0.time) / span;
                return k0.value + (k1.value - k0.value) * t;
            }
        }
        return time < keys[0].time ? keys[0].value : keys[keys.length - 1].value;
    }
    public function AddKey(time:Float, value:Float):Int {
        keys.push(new Keyframe(time, value));
        return keys.length - 1;
    }
    public function AddKeyFrame(key:Keyframe):Int {
        keys.push(key);
        return keys.length - 1;
    }
    public function RemoveKey(index:Int):Void keys.splice(index, 1);
    public function MoveKey(index:Int, key:Keyframe):Int {
        keys[index] = key;
        return index;
    }
    public function SmoothTangents(index:Int, weight:Float):Void {}
}

// Minimal UnityEngine.WrapMode shim.
enum abstract WrapMode(Int) {
    var Once = 1;
    var Loop = 2;
    var PingPong = 4;
    var Default = 0;
    var ClampForever = 8;
    var Clamp = 1;
}
