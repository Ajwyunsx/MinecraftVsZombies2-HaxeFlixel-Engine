// Ported from: Assets/Scripts/MVZ2/Models/Components/Boss/WitherModel.cs
package mvz2.models;

import unity.Vector2;

class WitherModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateLogic():Void {
        super.UpdateLogic();
        var offset:Vector2 = Model.GetProperty("Offset");
        offset = offset + armorOffsetSpeed;
        offset.x = offset.x % 1;
        offset.y = offset.y % 1;
        Model.SetProperty("Offset", offset);
    }
    private var armorOffsetSpeed:Vector2 = new Vector2(0.03, 0.01);
}
