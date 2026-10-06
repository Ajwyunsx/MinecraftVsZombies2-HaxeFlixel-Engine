// Ported from: Assets/Scripts/MVZ2/Models/Components/Icons/DivineShieldModel.cs
package mvz2.models;

import unity.Transform;
import unity.Vector3;

class DivineShieldModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        var size:Vector3 = Model.GetProperty("Size");
        size.x += 32;
        size.y += 32;
        size = Lawn2TransScale(size);
        size = size * (1 / 1.28);
        shieldRoot.localScale = size;
    }
    private var shieldRoot:Transform = null;
}
