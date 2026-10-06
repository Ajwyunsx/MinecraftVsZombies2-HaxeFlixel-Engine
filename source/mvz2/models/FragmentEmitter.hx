// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/FragmentEmitter.cs
package mvz2.models;

class FragmentEmitter extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateLogic():Void {
        super.UpdateLogic();
        var modified:Float = Model.GetProperty("EmitSpeed");
        modified *= emitSpeedMultiplier;
        particles.Emit(modified);
    }
    private var particles:ParticlePlayer = null;
    private var emitSpeedMultiplier:Float = 0.1;
}
