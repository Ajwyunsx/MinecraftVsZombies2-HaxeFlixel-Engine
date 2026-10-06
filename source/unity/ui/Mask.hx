package unity.ui;

import unity.RectTransform;
import unity.Sprite;
import unity.Vector2;
import unity.Vector4;

// Minimal UnityEngine.UI.Mask shim.
class Mask extends UIBehaviour {
    public var showMaskGraphic(get, set):Bool;
    function get_showMaskGraphic():Bool return m_ShowMaskGraphic;
    function set_showMaskGraphic(v:Bool):Bool {
        m_ShowMaskGraphic = v;
        return v;
    }
    public var graphic(get, never):Graphic;
    function get_graphic():Graphic return GetComponent(Graphic);
    private var m_ShowMaskGraphic:Bool = true;
    public var rectTransform(get, never):RectTransform;
    function get_rectTransform():RectTransform return cast transform;

    public function new() {
        super();
    }
    public function MaskEnabled():Bool return true;
    public function IsRaycastLocationValid(sp:Vector2, eventCamera:unity.Camera):Bool return true;
    public function GetModifiedMaterial(baseMaterial:unity.Material):unity.Material return baseMaterial;
}

// Minimal UnityEngine.UI.RectMask2D shim.
class RectMask2D extends UIBehaviour {
    public var padding:Vector4 = new Vector4();
    public var softness:Vector2 = new Vector2();
    public var rectTransform(get, never):RectTransform;
    function get_rectTransform():RectTransform return cast transform;
    public var canvasRect(get, never):RectTransform;
    function get_canvasRect():RectTransform return cast transform;

    public function new() {
        super();
    }
    public function PerformClipping():Void {}
    public function AddClippable(clippable:Dynamic):Void {}
    public function RemoveClippable(clippable:Dynamic):Void {}
    public function IsRaycastLocationValid(sp:Vector2, eventCamera:unity.Camera):Bool return true;
}
