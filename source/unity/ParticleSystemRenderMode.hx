package unity;

// Minimal UnityEngine.ParticleSystemRenderMode shim.
enum abstract ParticleSystemRenderMode(Int) {
    var Billboard = 0;
    var Stretch = 1;
    var HorizontalBillboard = 2;
    var VerticalBillboard = 3;
    var Mesh = 4;
    var None = 5;
}
