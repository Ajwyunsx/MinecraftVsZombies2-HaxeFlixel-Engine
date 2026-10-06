package unity.ui;

import unity.Color;

// Minimal UnityEngine.UI.Shadow shim.
class Shadow extends UIBehaviour {
    public var effectColor:Color = new Color(0, 0, 0, 0.5);
    public var effectDistance:unity.Vector2 = new unity.Vector2(1, -1);
    public var useGraphicAlpha:Bool = true;

    public function new() {
        super();
    }
    public function ApplyShadow(verts:Array<Dynamic>, start:Int, end:Int, x:Float, y:Float):Void {}
}

// Minimal UnityEngine.UI.Outline shim.
class Outline extends Shadow {
    public function new() {
        super();
    }
}

// Minimal UnityEngine.UI.LayoutRebuilder shim.
class LayoutRebuilder {
    public static function ForceRebuildLayoutImmediate(layoutRoot:unity.RectTransform):Void {}
    public static function MarkLayoutForRebuild(rect:unity.RectTransform):Void {}
}
