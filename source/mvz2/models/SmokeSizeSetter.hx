// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/SmokeSizeSetter.cs
package mvz2.models;

import unity.Vector2;
import unity.Vector3;

class SmokeSizeSetter extends ModelComponent {
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
        var volume = size.x * size.y * size.z;

        var ps = particles.Particles;
        var shape = ps.shape;
        var scale = size;
        scale.y *= 0.333333;
        shape.scale = scale;
        shape.position = Vector2.up * scale.y * 0.5;
        particles.Emit(100 * volume);
    }
    private var particles:ParticlePlayer = null;
    public static inline var PROP_EMITTED:String = "Emitted";
}
