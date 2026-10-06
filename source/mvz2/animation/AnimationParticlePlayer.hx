package mvz2.animation;

import unity.Debug;
import unity.MonoBehaviour;
import unity.ParticleSystem;

// Ported from: Assets/Scripts/MVZ2/Animation/AnimationParticlePlayer.cs
class AnimationParticlePlayer extends MonoBehaviour {
    public function Play(name:String):Void {
        var particle = Lambda.find(particles, p -> p.name == name);
        if (particle == null) {
            Debug.LogWarning('AnimatorParticlePlayer on ${gameObject.name} cannot find particle with name "${name}" to play!');
            return;
        }
        particle.particle.Play();
    }

    @:serializeField
    private var particles:Array<ParticlePair> = null;
}

@:structInit
class ParticlePair {
    public var name:String = null;
    public var particle:ParticleSystem = null;
}
