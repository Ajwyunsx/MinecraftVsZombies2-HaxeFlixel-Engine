package unity;

// Minimal UnityEngine.QueryTriggerInteraction shim.
enum abstract QueryTriggerInteraction(Int) {
    var UseGlobal = 0;
    var Ignore = 1;
    var Collide = 2;
}
