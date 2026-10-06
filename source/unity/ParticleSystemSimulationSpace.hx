package unity;

// Minimal UnityEngine.ParticleSystemSimulationSpace shim.
enum abstract ParticleSystemSimulationSpace(Int) {
    var Local = 0;
    var World = 1;
    var Custom = 2;
}
