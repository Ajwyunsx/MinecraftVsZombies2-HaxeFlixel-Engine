package unity;

// Minimal UnityEngine.ParticleSystemStopBehavior shim.
enum abstract ParticleSystemStopBehavior(Int) {
    var StopEmittingAndClear = 0;
    var StopEmitting = 1;
}
