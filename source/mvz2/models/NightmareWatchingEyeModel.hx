// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/NightmareWatchingEyeModel.cs
package mvz2.models;

import unity.Transform;
import unity.Vector2;

class NightmareWatchingEyeModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);

        var direction:Vector2 = Model.GetProperty("EyeDirection");
        pupilTransform.localPosition = direction * moveDistance;
    }
    private var pupilTransform:Transform = null;
    private var moveDistance:Float = 1;
}
