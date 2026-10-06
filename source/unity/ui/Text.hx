package unity.ui;

import unity.Font;
import unity.TextAnchor;
import unity.HorizontalWrapMode;
import unity.VerticalWrapMode;
import unity.ui.Graphic.MaskableGraphic;

// Minimal UnityEngine.UI.Text shim.
class Text extends MaskableGraphic {
    // PORT-NOTE: 会改变外观的字段全部改成属性并触发 markVisualDirty()
    //（见 unity/ui/Graphic.hx 的钩子说明），由 mvz2.ui.UiRenderer 重建 FlxText。
    public var text(get, set):String;
    private var _text:String = "";
    function get_text():String return _text;
    function set_text(v:String):String {
        _text = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var font(get, set):Font;
    private var _font:Font;
    function get_font():Font return _font;
    function set_font(v:Font):Font {
        _font = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var fontSize(get, set):Int;
    private var _fontSize:Int = 14;
    function get_fontSize():Int return _fontSize;
    function set_fontSize(v:Int):Int {
        _fontSize = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var fontStyle(get, set):unity.FontStyle;
    private var _fontStyle:unity.FontStyle = unity.FontStyle.Normal;
    function get_fontStyle():unity.FontStyle return _fontStyle;
    function set_fontStyle(v:unity.FontStyle):unity.FontStyle {
        _fontStyle = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var alignment(get, set):TextAnchor;
    private var _alignment:TextAnchor = TextAnchor.UpperLeft;
    function get_alignment():TextAnchor return _alignment;
    function set_alignment(v:TextAnchor):TextAnchor {
        _alignment = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var alignByGeometry:Bool = false;
    public var supportRichText(get, set):Bool;
    private var _supportRichText:Bool = true;
    function get_supportRichText():Bool return _supportRichText;
    function set_supportRichText(v:Bool):Bool {
        _supportRichText = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var resizeTextForBestFit:Bool = false;
    public var resizeTextMinSize:Int = 10;
    public var resizeTextMaxSize:Int = 40;
    public var horizontalOverflow(get, set):HorizontalWrapMode;
    private var _horizontalOverflow:HorizontalWrapMode = HorizontalWrapMode.Wrap;
    function get_horizontalOverflow():HorizontalWrapMode return _horizontalOverflow;
    function set_horizontalOverflow(v:HorizontalWrapMode):HorizontalWrapMode {
        _horizontalOverflow = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var verticalOverflow(get, set):VerticalWrapMode;
    private var _verticalOverflow:VerticalWrapMode = VerticalWrapMode.Truncate;
    function get_verticalOverflow():VerticalWrapMode return _verticalOverflow;
    function set_verticalOverflow(v:VerticalWrapMode):VerticalWrapMode {
        _verticalOverflow = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var lineSpacing(get, set):Float;
    private var _lineSpacing:Float = 1;
    function get_lineSpacing():Float return _lineSpacing;
    function set_lineSpacing(v:Float):Float {
        _lineSpacing = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var cachedTextGenerator:Dynamic;
    public var cachedTextGeneratorForLayout:Dynamic;
    public var pixelsPerUnit(get, never):Float;
    function get_pixelsPerUnit():Float return 1;

    public function new() {
        super();
    }

    public function CalculateLayoutInputHorizontal():Void {}
    public function CalculateLayoutInputVertical():Void {}
    public var minWidth(get, never):Float;
    function get_minWidth():Float return 0;
    public var preferredWidth(get, never):Float;
    function get_preferredWidth():Float return _text != null ? _text.length * _fontSize * 0.5 : 0;
    public var flexibleWidth(get, never):Float;
    function get_flexibleWidth():Float return -1;
    public var minHeight(get, never):Float;
    function get_minHeight():Float return 0;
    public var preferredHeight(get, never):Float;
    function get_preferredHeight():Float return _fontSize;
    public var flexibleHeight(get, never):Float;
    function get_flexibleHeight():Float return -1;
    public var layoutPriority(get, never):Int;
    function get_layoutPriority():Int return 0;
}
