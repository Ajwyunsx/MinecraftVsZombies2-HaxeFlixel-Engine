package unity;

// Minimal UnityEngine.ParticleSystemCullingMode shim.
enum abstract ParticleSystemCullingMode(Int) {
    var Automatic = 0;
    var PauseAndCatchup = 1;
    var Pause = 2;
    var AlwaysSimulate = 3;
}
