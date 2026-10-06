package unity;

// Minimal UnityEngine.FilterMode shim.
enum abstract FilterMode(Int) from Int to Int {
    var Point = 0;
    var Bilinear = 1;
    var Trilinear = 2;
}
