// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/ParticleSizeSetter.cs
package mvz2.models;

import unity.Vector2;
import unity.Vector3;

class ParticleSizeSetter extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateLogic():Void {
        super.UpdateLogic();
        var size:Vector3 = Model.GetProperty("Size");
        size = Lawn2TransScale(size);

        var shape = particles.Particles.shape;
        shape.scale = size;
        shape.position = Vector2.up * size.y * 0.5;
    }
    private var particles:ParticlePlayer = null;
}
