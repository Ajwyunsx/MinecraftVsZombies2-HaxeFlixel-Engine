package unity.ui;

import unity.Sprite;
import unity.ui.Graphic.MaskableGraphic;

// Minimal UnityEngine.UI.Image shim.
class Image extends MaskableGraphic {
    // PORT-NOTE: sprite / 填充参数改成属性，写入时触发 markVisualDirty()，
    // 让 mvz2.ui.UiRenderer 重建对应的 FlxSprite（Unity 由 SetVerticesDirty 走同一路径）。
    public var sprite(get, set):Sprite;
    private var _sprite:Sprite;
    function get_sprite():Sprite return _sprite;
    function set_sprite(v:Sprite):Sprite {
        _sprite = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var overrideSprite(get, set):Sprite;
    private var _overrideSprite:Sprite;
    function get_overrideSprite():Sprite return _overrideSprite;
    function set_overrideSprite(v:Sprite):Sprite {
        _overrideSprite = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var activeSprite(get, never):Sprite;
    function get_activeSprite():Sprite return _overrideSprite != null ? _overrideSprite : _sprite;
    public var type(get, set):ImageType;
    private var _type:ImageType = ImageType.Simple;
    function get_type():ImageType return _type;
    function set_type(v:ImageType):ImageType {
        _type = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var preserveAspect(get, set):Bool;
    private var _preserveAspect:Bool = false;
    function get_preserveAspect():Bool return _preserveAspect;
    function set_preserveAspect(v:Bool):Bool {
        _preserveAspect = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var fillCenter:Bool = true;
    public var fillMethod(get, set):FillMethod;
    private var _fillMethod:FillMethod = FillMethod.Radial360;
    function get_fillMethod():FillMethod return _fillMethod;
    function set_fillMethod(v:FillMethod):FillMethod {
        _fillMethod = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var fillAmount(get, set):Float;
    private var _fillAmount:Float = 1;
    function get_fillAmount():Float return _fillAmount;
    function set_fillAmount(v:Float):Float {
        _fillAmount = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var fillClockwise(get, set):Bool;
    private var _fillClockwise:Bool = true;
    function get_fillClockwise():Bool return _fillClockwise;
    function set_fillClockwise(v:Bool):Bool {
        _fillClockwise = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var fillOrigin(get, set):Int;
    private var _fillOrigin:Int = 0;
    function get_fillOrigin():Int return _fillOrigin;
    function set_fillOrigin(v:Int):Int {
        _fillOrigin = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var useSpriteMesh:Bool = false;
    public var pixelsPerUnitMultiplier:Float = 1;
    public var alphaHitTestMinimumThreshold:Float = 0;
    public var hasBorder(get, never):Bool;
    function get_hasBorder():Bool return _sprite != null && (_sprite.border.x > 0 || _sprite.border.y > 0 || _sprite.border.z > 0 || _sprite.border.w > 0);
    public var pixelsPerUnit(get, never):Float;
    function get_pixelsPerUnit():Float return _sprite != null ? _sprite.pixelsPerUnit : 100;

    public function new() {
        super();
    }

    // PORT-NOTE: C# 的 Image.mainTexture（无 sprite 时返回 s_WhiteTexture）。移植层由
    // UiRenderer 用纯色 FlxSprite 表示"无 sprite 的 Image"，这里返回 null 即可。
    // PORT-NOTE: Sprite.texture 的类型是 unity.Texture2D，而 Texture2D 继承自 UnityObject
    // 而不是 Texture（shim 的继承链与 Unity 不同），故这里放宽为 Dynamic。
    public var mainTexture(get, never):Dynamic;
    function get_mainTexture():Dynamic return _sprite != null ? _sprite.texture : null;

    public function CalculateLayoutInputHorizontal():Void {}
    public function CalculateLayoutInputVertical():Void {}
    public var minWidth(get, never):Float;
    function get_minWidth():Float return 0;
    public var preferredWidth(get, never):Float;
    function get_preferredWidth():Float return _sprite != null ? _sprite.rect.width : 0;
    public var flexibleWidth(get, never):Float;
    function get_flexibleWidth():Float return -1;
    public var minHeight(get, never):Float;
    function get_minHeight():Float return 0;
    public var preferredHeight(get, never):Float;
    function get_preferredHeight():Float return _sprite != null ? _sprite.rect.height : 0;
    public var flexibleHeight(get, never):Float;
    function get_flexibleHeight():Float return -1;
    public var layoutPriority(get, never):Int;
    function get_layoutPriority():Int return 0;
}

// Minimal UnityEngine.UI.Image.Type shim.
enum abstract ImageType(Int) {
    var Simple = 0;
    var Sliced = 1;
    var Tiled = 2;
    var Filled = 3;
}

// Minimal UnityEngine.UI.Image.FillMethod shim.
enum abstract FillMethod(Int) {
    var Horizontal = 0;
    var Vertical = 1;
    var Radial90 = 2;
    var Radial180 = 3;
    var Radial360 = 4;
}
