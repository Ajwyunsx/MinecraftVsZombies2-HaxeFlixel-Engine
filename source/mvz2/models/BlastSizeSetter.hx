// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/BlastSizeSetter.cs
package mvz2.models;

import unity.Mathf;
import unity.Vector3;

class BlastSizeSetter extends ModelComponent {
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


        var smokePs = player.Particles;

        var smokeMain = smokePs.main;
        smokeMain.startSpeedMultiplier = maxRadius * speedPerRadius;
        player.Emit(particleCountPerVolume * volume + additionalParticleCount);
    }
    private var player:ParticlePlayer = null;
    private var particleCountPerVolume:Float = 5;
    private var additionalParticleCount:Float = 10;
    private var speedPerRadius:Float = 0.5;
    public static inline var PROP_EMITTED:String = "BlastEmitted";
}
