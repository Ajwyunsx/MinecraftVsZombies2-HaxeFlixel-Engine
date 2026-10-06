package unity;

// Minimal UnityEngine.SpriteMaskInteraction shim.
enum abstract SpriteMaskInteraction(Int) {
    var None = 0;
    var VisibleInsideMask = 1;
    var VisibleOutsideMask = 2;
}
