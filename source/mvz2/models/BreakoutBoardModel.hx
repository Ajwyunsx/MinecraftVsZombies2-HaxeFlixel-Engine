// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/BreakoutBoardModel.cs
package mvz2.models;

import tmpro.TextMeshPro;
import unity.Mathf;

class BreakoutBoardModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);

        var countdown:Int = Model.GetProperty("Countdown");
        var text = "";
        if (countdown > 0) {
            var seconds = Mathf.CeilToInt(countdown / 30);
            text = Std.string(seconds);
        }
        countdownText.text = text;
    }
    private var countdownText:TextMeshPro = null;
}
