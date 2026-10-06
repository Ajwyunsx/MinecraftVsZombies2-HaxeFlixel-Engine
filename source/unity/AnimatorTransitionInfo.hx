package unity;

// Minimal UnityEngine.AnimatorTransitionInfo shim.
class AnimatorTransitionInfo {
    public var fullPathHash:Int = 0;
    public var nameHash:Int = 0;
    public var userNameHash:Int = 0;
    public var duration:Float = 0;
    public var durationUnit:DurationUnit = DurationUnit.Normalized;
    public var normalizedTime:Float = 0;
    public var anyState:Bool = false;
    public var isExit:Bool = false;

    public function new() {}

    public function IsName(name:String):Bool return name != null && nameHash == Animator.StringToHash(name);
    public function IsUserName(name:String):Bool return name != null && userNameHash == Animator.StringToHash(name);
}
