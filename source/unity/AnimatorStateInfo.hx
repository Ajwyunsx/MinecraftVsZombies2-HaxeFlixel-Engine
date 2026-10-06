package unity;

// Minimal UnityEngine.AnimatorStateInfo shim.
class AnimatorStateInfo {
    public var fullPathHash:Int = 0;
    public var shortNameHash:Int = 0;
    public var normalizedTime:Float = 0;
    public var length:Float = 0;
    public var speed:Float = 1;
    public var speedMultiplier:Float = 1;
    public var loop:Bool = false;

    public function new() {}

    public function IsName(name:String):Bool return name != null && shortNameHash == Animator.StringToHash(name);
    public function IsTag(tag:String):Bool return false;
}
