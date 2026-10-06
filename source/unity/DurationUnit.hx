package unity;

// Minimal UnityEngine.DurationUnit shim (UnityEngine.AnimatorTransitionInfo's enum).
enum abstract DurationUnit(Int) {
    var Normalized = 0;
    var Fixed = 1;
}
