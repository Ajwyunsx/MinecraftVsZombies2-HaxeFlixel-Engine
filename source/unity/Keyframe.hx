package unity;

// Minimal UnityEngine.Keyframe shim.
class Keyframe {
    public var time:Float = 0;
    public var value:Float = 0;
    public var inTangent:Float = 0;
    public var outTangent:Float = 0;
    public var inWeight:Float = 0;
    public var outWeight:Float = 0;
    public var weightedMode:Int = 0;

    public function new(?time:Float = 0, ?value:Float = 0) {
        this.time = time;
        this.value = value;
    }
}
