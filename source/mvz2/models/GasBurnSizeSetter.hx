// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/GasBurnSizeSetter.cs
package mvz2.models;

import unity.Mathf;
import unity.Vector3;

class GasBurnSizeSetter extends ModelComponent {
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

        var timeout:Int = Model.GetProperty("Timeout");
        var percentage = Mathf.Clamp01((maxTime - timeout) / expandTime);

        var firePS = fires.Particles;
        var fireShape = firePS.shape;
        fires.OverrideRateOverTime(volume * ratePerVolume * percentage);
        fireShape.position = gasPosition;
        fireShape.scale = gasScale * percentage;
    }
    private var fires:ParticlePlayer = null;
    private var expandTime:Int = 15;
    private var maxTime:Int = 45;
    private var ratePerVolume:Float = 200;
    public static inline var PROP_STOPPED:String = "Stopped";
}
