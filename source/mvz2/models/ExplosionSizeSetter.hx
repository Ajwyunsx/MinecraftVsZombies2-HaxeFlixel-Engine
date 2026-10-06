// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/ExplosionSizeSetter.cs
package mvz2.models;

import unity.Mathf;
import unity.Vector3;

class ExplosionSizeSetter extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateLogic():Void {
        super.UpdateLogic();
        if (Model.GetProperty(PROP_EMITTED))
            return;
        Model.SetProperty(PROP_EMITTED, true);


        var size:Vector3 = Model.GetProperty("Size");
        size = Lawn2TransScale(size);
        var volume = size.x * size.z;
        var maxRadius = Mathf.Max(size.x, size.z);


        var explosionPs = explosionParticles.Particles;
        var smokePs = smokeParticles.Particles;

        var explosionShape = explosionPs.shape;
        var smokeMain = smokePs.main;

        explosionShape.scale = size;
        explosionParticles.Emit(explosionParticleCount * volume + additionExplosionParticles);

        smokeMain.startSpeedMultiplier = maxRadius * smokeSpeedMultiplier;
        smokeParticles.Emit(smokeParticleCount * volume + additionSmokeParticles);
    }
    private var explosionParticles:ParticlePlayer = null;
    private var smokeParticles:ParticlePlayer = null;
    private var explosionParticleCount:Float = 5;
    private var smokeParticleCount:Float = 5;
    private var additionExplosionParticles:Float = 10;
    private var additionSmokeParticles:Float = 10;
    private var smokeSpeedMultiplier:Float = 0.5;
    public static inline var PROP_EMITTED:String = "Emitted";
}
