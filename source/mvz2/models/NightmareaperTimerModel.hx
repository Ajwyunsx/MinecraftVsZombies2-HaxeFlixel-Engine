// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/NightmareaperTimerModel.cs
package mvz2.models;

import tmpro.TextMeshPro;
import unity.Color;

class NightmareaperTimerModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);

        var timeout:Int = Model.GetProperty("Timeout");
        var timeSpan = system.TimeSpan.FromSeconds(timeout / 30);
        var text = timeSpan.ToString("mm:ss.ff");
        countdownText.text = text;
        countdownText.color = Model.GetProperty("Color");
    }
    private var countdownText:TextMeshPro = null;
}
