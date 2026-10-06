package unity;

// Minimal UnityEngine.ParticleSystemGradientMode shim.
enum abstract ParticleSystemGradientMode(Int) {
    var Color = 0;
    var Gradient = 1;
    var TwoColors = 2;
    var TwoGradients = 3;
    var RandomColor = 4;
}
