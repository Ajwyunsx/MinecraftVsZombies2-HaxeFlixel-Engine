package unity;

// Minimal UnityEngine.SpriteDrawMode shim.
enum abstract SpriteDrawMode(Int) {
    var Simple = 0;
    var Sliced = 1;
    var Tiled = 2;
}
