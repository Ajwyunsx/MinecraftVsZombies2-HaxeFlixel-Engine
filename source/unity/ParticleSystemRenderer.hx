package unity;

// Minimal UnityEngine.ParticleSystemRenderer shim.
class ParticleSystemRenderer extends Renderer {
    public var renderMode:ParticleSystemRenderMode = ParticleSystemRenderMode.Billboard;
    public var lengthScale:Float = 2;
    public var velocityScale:Float = 0;
    public var cameraVelocityScale:Float = 0;
    public function new() {
        super();
    }
}
