// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/LineModel.cs
package mvz2.models;

import unity.Quaternion;
import unity.Transform;
import unity.Vector3;

class LineModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function OnPropertySet(name:String, value:Dynamic):Void {
        super.OnPropertySet(name, value);
        if (name == "ShowLine" && Std.isOfType(value, Bool)) {
            var boolValue:Bool = cast value;
            sourceTransform.gameObject.SetActive(boolValue);
            if (boolValue) {
                UpdateLine();
            }
        }
    }
    override public function Init():Void {
        super.Init();
        UpdateLine();
    }
    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        UpdateLine();
    }
    private function UpdateLine():Void {
        if (!sourceTransform.gameObject.activeInHierarchy)
            return;
        var source = sourceTransform.position;
        var dest:Vector3 = Lawn2TransPosition(Model.GetProperty("Dest"));
        var distance = dest - source;
        if (ignoreZ) {
            distance.z = 0;
        }
        sourceTransform.localRotation = Quaternion.FromToRotation(Vector3.right, distance);
        sourceTransform.localScale = new Vector3(distance.magnitude, 1, 1);
    }
    private var sourceTransform:Transform = null;
    private var ignoreZ:Bool = false;
}
