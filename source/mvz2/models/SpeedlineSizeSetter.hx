// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/SpeedlineSizeSetter.cs
package mvz2.models;

import tools.ObjectExtensions;
import unity.Vector3;

class SpeedlineSizeSetter extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateLogic():Void {
        super.UpdateLogic();

        var size:Vector3 = Model.GetProperty("Size");
        size = Lawn2TransScale(size);
        var toLeft = size.x < 0;
        size = Vector3.Abs(size); // PORT-NOTE: Unity 的 Vector3.Abs 为静态方法
        var volume = size.y * size.z;
        var particleSystem = player.Particles;

        var particleEmission = particleSystem.emission;
        var particleShape = particleSystem.shape;
        particleEmission.rateOverTimeMultiplier = particleCountPerVolume * volume + additionalParticleCount;
        particleShape.position = Vector3.up * (size.y * 0.5);
        particleShape.rotation = new Vector3(0, toLeft ? -90 : 90);
        particleShape.scale = new Vector3(1, size.z + size.y, size.x);
    }
    private var player:ParticlePlayer = null;
    private var particleCountPerVolume:Float = 16;
    private var additionalParticleCount:Float = 0;
}
