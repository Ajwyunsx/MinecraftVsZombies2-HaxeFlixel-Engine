// Ported from: Assets/Scripts/MVZ2/Models/Components/Pickup/StarshardRotationSetter.cs
package mvz2.models;

import unity.Transform;
import unity.Vector3;

class StarshardRotationSetter extends ModelComponent {
    public function new() {
        super();
    }

    override public function OnPropertySet(name:String, value:Dynamic):Void {
        super.OnPropertySet(name, value);
        // PORT-NOTE: C# `value is not Vector3`；Haxe 里 unity.Vector3 是 abstract(Vector3Data)，
        // 不能作为运行期值判定，改用其底层类 Vector3Data。
        if (!Std.isOfType(value, Vector3Data))
            return;
        var vector3:Vector3 = cast value;
        switch (name) {
            case "Ring1Rotation":
                ringRoot1.localEulerAngles = vector3;
            case "Ring2Rotation":
                ringRoot2.localEulerAngles = vector3;
            default:
        }
    }
    private var ringRoot1:Transform = null;
    private var ringRoot2:Transform = null;
}
