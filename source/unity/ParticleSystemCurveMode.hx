package unity;

// Minimal UnityEngine.ParticleSystemCurveMode shim.
enum abstract ParticleSystemCurveMode(Int) {
    var Constant = 0;
    var Curve = 1;
    var TwoCurves = 2;
    var TwoConstants = 3;
}
