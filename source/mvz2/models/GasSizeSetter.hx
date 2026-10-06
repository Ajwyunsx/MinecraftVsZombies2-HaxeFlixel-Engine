// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/GasSizeSetter.cs
package mvz2.models;

import unity.ParticleSystem;
import unity.ParticleSystemStopBehavior;  // UNKNOWNIMPORT
import unity.Vector3;

class GasSizeSetter extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateLogic():Void {
        super.UpdateLogic();
        var size:Vector3 = Model.GetProperty("Size");
        size = Lawn2TransScale(size);
        var yHeight = size.y + size.z * 0.5;
        var volume = size.x * yHeight;

        var gasPosition = new Vector3(0, size.y * 0.5, 1);
        var gasScale = new Vector3(size.x, yHeight, 1);

        var stopped:Bool = Model.GetProperty(PROP_STOPPED);
        if (gas != null) {
            var gasPS = gas.Particles;
            var gasEmission = gasPS.emission;
            var gasShape = gasPS.shape;
            gas.OverrideRateOverTime(volume * ratePerVolume);
            gasShape.position = gasPosition;
            gasShape.scale = gasScale;
            if (stopped) {
                if (gasPS.isEmitting)
                    gasPS.Stop(true, ParticleSystemStopBehavior.StopEmitting);
            } else {
                if (!gasPS.isEmitting)
                    gasPS.Play(true);
            }
        }

        if (gasLight != null) {
            var gasLightPS = gasLight.Particles;
            var gasLightEmission = gasLightPS.emission;
            var gasLightShape = gasLightPS.shape;
            gasLight.OverrideRateOverTime(volume * ratePerVolume);

            gasLightShape.position = gasPosition;
            gasLightShape.scale = gasScale;

            if (stopped) {
                if (gasLightPS.isEmitting)
                    gasLightPS.Stop(true, ParticleSystemStopBehavior.StopEmitting);
            } else {
                if (!gasLightPS.isEmitting)
                    gasLightPS.Play(true);
            }

        }

        if (smoke != null) {
            var smokePS = smoke.Particles;
            var smokeShape = smokePS.shape;
            smokeShape.scale = new Vector3(size.x, 1, 0.1);
            if (stopped) {
                if (smokePS.isEmitting)
                    smokePS.Stop(true, ParticleSystemStopBehavior.StopEmitting);
            } else {
                if (!smokePS.isEmitting)
                    smokePS.Play(true);
            }
        }
    }
    private var gasLight:ParticlePlayer = null;
    private var gas:ParticlePlayer = null;
    private var smoke:ParticlePlayer = null;
    private var ratePerVolume:Float = 20;
    public static inline var PROP_STOPPED:String = "Stopped";
}
