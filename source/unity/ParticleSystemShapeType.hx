package unity;

// Minimal UnityEngine.ParticleSystemShapeType shim.
enum abstract ParticleSystemShapeType(Int) {
    var Sphere = 0;
    var Hemisphere = 1;
    var Cone = 4;
    var Box = 5;
    var Mesh = 6;
    var Circle = 10;
    var Rectangle = 12;
}
