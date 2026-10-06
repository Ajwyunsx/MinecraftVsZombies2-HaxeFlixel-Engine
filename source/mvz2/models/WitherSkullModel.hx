// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/WitherSkullModel.cs
package mvz2.models;

import unity.Transform;
import unity.Vector2;
import unity.Vector3;

class WitherSkullModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        var source:Vector3 = Lawn2TransPosition(Model.GetProperty("Source"));
        var dest:Vector3 = Lawn2TransPosition(Model.GetProperty("Dest"));
        var distance = dest - source;
        distance.y -= distance.z;
        sourceTransform.localEulerAngles = Vector3.zero;

        var velocityHori = new Vector2(distance.x, distance.z);
        var horiAngle = Vector2.SignedAngle(velocityHori, Vector2.right);
        sourceTransform.RotateAxis(Vector3.up, horiAngle); // PORT-NOTE: Unity 的 Rotate(axis, angle) 重载在 shim 中改名 RotateAxis

        var vertAngle = Vector2.SignedAngle(new Vector2(velocityHori.magnitude, distance.y), Vector2.right);
        sourceTransform.RotateAxis(Vector3.back, vertAngle);
    }
    private var sourceTransform:Transform = null;
}
