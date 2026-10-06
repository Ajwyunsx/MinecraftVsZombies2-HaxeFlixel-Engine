// Ported from: Assets/Scripts/MVZ2/Models/Components/Contraptions/MagichestModel.cs
package mvz2.models;

import unity.Transform;
import tools.PositionTransitor;  // UNKNOWNIMPORT
import unity.Vector3;

class MagichestModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);

        var flashScale:Vector3 = Model.GetProperty("FlashScale");
        flashScale = flashScale * (1 - scaleSpeed) + targetFlashScale * scaleSpeed;
        Model.SetProperty("FlashScale", flashScale);
        flashRootTransform.localScale = Lawn2TransScale(flashScale);

        var sourcePosition:Vector3 = Model.GetProperty("FlashSourcePosition");
        sourcePosition = Lawn2TransPosition(sourcePosition);
        flashTransitor.setStartPosition(sourcePosition);
    }
    private var flashRootTransform:Transform = null;
    private var flashTransitor:PositionTransitor = null;
    private var scaleSpeed:Float = 0.25;
    private var targetFlashScale:Vector3 = new Vector3(25, 25, 25);
}
