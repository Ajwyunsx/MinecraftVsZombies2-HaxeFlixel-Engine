package unity;

// Minimal UnityEngine.CursorLockMode shim.
enum abstract CursorLockMode(Int) {
    var None = 0;
    var Locked = 1;
    var Confined = 2;
}
