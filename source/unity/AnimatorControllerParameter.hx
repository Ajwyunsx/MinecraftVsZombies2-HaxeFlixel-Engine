package unity;

// Minimal UnityEngine.AnimatorControllerParameter shim.
class AnimatorControllerParameter {
    public var name:String = "";
    public var type:AnimatorControllerParameterType = AnimatorControllerParameterType.Float;
    public var defaultFloat:Float = 0;
    public var defaultInt:Int = 0;
    public var defaultBool:Bool = false;
    public var nameHash:Int = 0;

    public function new() {}
}
