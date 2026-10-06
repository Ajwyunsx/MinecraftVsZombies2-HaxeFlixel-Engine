// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/FloatingTextModel.cs
package mvz2.models;

import tmpro.TextMeshPro;
import unity.Color;

class FloatingTextModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function Init():Void {
        super.Init();
        UpdateText();
    }
    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        UpdateText();
    }
    private function UpdateText():Void {
        text.text = Model.GetProperty("Text");
        text.color = Model.GetProperty("Color");
    }
    private var text:TextMeshPro = null;
}
