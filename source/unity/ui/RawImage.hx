package unity.ui;

import unity.Texture;
import unity.Vector2;
import unity.Rect;
import unity.ui.Graphic.MaskableGraphic;

// Minimal UnityEngine.UI.RawImage shim.
class RawImage extends MaskableGraphic {
    // PORT-NOTE: 写入时触发 markVisualDirty()（见 unity/ui/Graphic.hx 的钩子说明）。
    public var texture(get, set):Texture;
    private var _texture:Texture;
    function get_texture():Texture return _texture;
    function set_texture(v:Texture):Texture {
        _texture = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var uvRect(get, set):Rect;
    private var _uvRect:Rect = new Rect(0, 0, 1, 1);
    function get_uvRect():Rect return _uvRect;
    function set_uvRect(v:Rect):Rect {
        _uvRect = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var mainTexture(get, never):Texture;
    function get_mainTexture():Texture return _texture;

    public function new() {
        super();
    }
    override public function SetNativeSize():Void {
        Graphic.markVisualDirty();
        super.SetNativeSize();
    }
}
