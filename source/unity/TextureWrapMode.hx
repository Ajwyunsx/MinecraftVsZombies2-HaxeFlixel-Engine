package unity;

// Minimal UnityEngine.TextureWrapMode shim.
enum abstract TextureWrapMode(Int) {
    var Repeat = 0;
    var Clamp = 1;
    var Mirror = 2;
    var MirrorOnce = 3;
}
