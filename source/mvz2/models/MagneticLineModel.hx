// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/MagneticLineModel.cs
package mvz2.models;

import unity.Quaternion;
import unity.Transform;
import unity.Vector3;

class MagneticLineModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        var source = sourceTransform.position;
        var dest:Vector3 = Lawn2TransPosition(Model.GetProperty("Dest"));
        var distance = dest - source;
        sourceTransform.localRotation = Quaternion.FromToRotation(Vector3.right, distance);
        sourceTransform.localScale = new Vector3(distance.magnitude, 1, 1);
    }
    private var sourceTransform:Transform = null;
}
