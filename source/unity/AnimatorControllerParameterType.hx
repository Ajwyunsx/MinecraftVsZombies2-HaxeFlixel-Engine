package unity;

// Minimal UnityEngine.AnimatorControllerParameterType shim.
enum abstract AnimatorControllerParameterType(Int) {
    var Float = 1;
    var Int = 3;
    var Bool = 4;
    var Trigger = 9;
}
