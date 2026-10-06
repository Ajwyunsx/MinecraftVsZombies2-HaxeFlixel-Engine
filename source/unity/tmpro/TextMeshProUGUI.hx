package unity.tmpro;

import unity.Color;
import unity.FontStyle;
import unity.RectTransform;
import unity.TextAnchor;
import unity.ui.Graphic;
import unity.ui.Graphic.MaskableGraphic;
import unity.ui.Selectable.CanvasUpdate;

// Minimal TMPro.TextMeshProUGUI shim（继承自 MaskableGraphic，与 Unity 一致）。
//
// PORT-NOTE: 会改变外观的字段全部改成属性并触发 markVisualDirty()
//（见 unity/ui/Graphic.hx 的钩子说明），由 mvz2.ui.UiRenderer 重建 FlxText。
// `text` 的 setter 还必须处理 `SetText(...)`（原工程大量使用），因此统一走 set_text。
class TextMeshProUGUI extends MaskableGraphic {
    public var text(get, set):String;
    private var _text:String = "";
    function get_text():String return _text;
    function set_text(v:String):String {
        _text = v != null ? v : "";
        Graphic.markVisualDirty();
        return v;
    }
    public var isRightToLeftText:Bool = false;
    public var font(get, set):TMP_FontAsset;
    private var _font:TMP_FontAsset;
    function get_font():TMP_FontAsset return _font;
    function set_font(v:TMP_FontAsset):TMP_FontAsset {
        _font = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var fontSharedMaterial:unity.Material;
    public var fontSharedMaterials:Array<unity.Material> = [];
    public var fontMaterials:Array<unity.Material> = [];
    public var fontStyle(get, set):FontStyles;
    private var _fontStyle:FontStyles = FontStyles.Normal;
    function get_fontStyle():FontStyles return _fontStyle;
    function set_fontStyle(v:FontStyles):FontStyles {
        _fontStyle = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var fontSize(get, set):Float;
    private var _fontSize:Float = 36;
    function get_fontSize():Float return _fontSize;
    function set_fontSize(v:Float):Float {
        _fontSize = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var fontSizeMin:Float = 36;
    public var fontSizeMax:Float = 36;
    public var enableAutoSizing:Bool = false;
    public var characterSpacing:Float = 0;
    public var wordSpacing:Float = 0;
    public var lineSpacing(get, set):Float;
    private var _lineSpacing:Float = 0;
    function get_lineSpacing():Float return _lineSpacing;
    function set_lineSpacing(v:Float):Float {
        _lineSpacing = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var paragraphSpacing:Float = 0;
    public var alignment(get, set):TextAlignmentOptions;
    private var _alignment:TextAlignmentOptions = TextAlignmentOptions.TopLeft;
    function get_alignment():TextAlignmentOptions return _alignment;
    function set_alignment(v:TextAlignmentOptions):TextAlignmentOptions {
        _alignment = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var alpha(get, set):Float;
    private var _alpha:Float = 1;
    function get_alpha():Float return _alpha;
    function set_alpha(v:Float):Float {
        _alpha = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var enableWordWrapping(get, set):Bool;
    private var _enableWordWrapping:Bool = true;
    function get_enableWordWrapping():Bool return _enableWordWrapping;
    function set_enableWordWrapping(v:Bool):Bool {
        _enableWordWrapping = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var overflowMode(get, set):TextOverflowModes;
    private var _overflowMode:TextOverflowModes = TextOverflowModes.Overflow;
    function get_overflowMode():TextOverflowModes return _overflowMode;
    function set_overflowMode(v:TextOverflowModes):TextOverflowModes {
        _overflowMode = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var margin:unity.Vector4 = new unity.Vector4();
    public var richText(get, set):Bool;
    private var _richText:Bool = true;
    function get_richText():Bool return _richText;
    function set_richText(v:Bool):Bool {
        _richText = v;
        Graphic.markVisualDirty();
        return v;
    }
    public var parseCtrlCharacters:Bool = true;
    public var maxVisibleCharacters:Int = 99999;
    public var maxVisibleWords:Int = 99999;
    public var maxVisibleLines:Int = 99999;
    public var firstVisibleCharacter:Int = 0;
    public var textInfo:TMP_TextInfo = new TMP_TextInfo();
    // PORT-NOTE: `rectTransform` 继承自 unity.ui.Graphic，Haxe 不允许子类重定义属性。
    public var preferredWidth(get, never):Float;
    function get_preferredWidth():Float return _text != null ? _text.length * _fontSize * 0.5 : 0;
    public var preferredHeight(get, never):Float;
    function get_preferredHeight():Float return _fontSize;
    public var renderedWidth:Float = 0;
    public var renderedHeight:Float = 0;
    public var isTextOverflowing(get, never):Bool;
    function get_isTextOverflowing():Bool return false;
    public var flexibleWidth(get, never):Float;
    function get_flexibleWidth():Float return -1;
    public var minWidth(get, never):Float;
    function get_minWidth():Float return 0;
    public var minHeight(get, never):Float;
    function get_minHeight():Float return 0;
    public var flexibleHeight(get, never):Float;
    function get_flexibleHeight():Float return -1;
    public var layoutPriority(get, never):Int;
    function get_layoutPriority():Int return 0;
    public var textWrappingMode:Int = 0;
    public var horizontalAlignment:Int = 0;
    public var verticalAlignment:Int = 0;

    public function new() {
        super();
    }

    // PORT-NOTE: C# 的 SetText(string) / SetText(string, float) / SetText(string, float, float) /
    // SetText(string, params float[]) 四个重载在 Haxe 中合并为单一可选参数签名；
    // TMPro 的 {0}/{1} 数值格式化尚未在 shim 中实现，调用点只用单参形式。
    public function SetText(text:String, ?arg0:Dynamic, ?arg1:Dynamic, ?args:Array<Dynamic>):Void this.text = text;
    public function SetCharArray(charArray:Array<String>):Void this.text = charArray.join("");
    public function ForceMeshUpdate(?ignoreActiveState:Bool = false, ?forceTextReparsing:Bool = false):Void {}
    public function UpdateMeshPadding():Void {}
    public function GetPreferredValues(?width:Float = 0, ?height:Float = 0):unity.Vector2 return new unity.Vector2(preferredWidth, preferredHeight);
    public function GetRenderedValues():unity.Vector2 return new unity.Vector2(renderedWidth, renderedHeight);
    public function ComputeMarginSize():Void {}
    public function CalculateLayoutInputHorizontal():Void {}
    public function CalculateLayoutInputVertical():Void {}
    override public function Rebuild(update:CanvasUpdate):Void {}
    public function ConvertToFullMesh():Void {}
}

// Minimal TMPro.TextAlignmentOptions shim.
enum abstract TextAlignmentOptions(Int) {
    var TopLeft = 257;
    var Top = 258;
    var TopRight = 260;
    var TopJustified = 264;
    var TopFlush = 272;
    var TopGeoAligned = 288;
    var Left = 513;
    var Center = 514;
    var Right = 516;
    var Justified = 520;
    var Flush = 528;
    var CenterGeoAligned = 544;
    var BottomLeft = 1025;
    var Bottom = 1026;
    var BottomRight = 1028;
    var BottomJustified = 1032;
    var BottomFlush = 1040;
    var BottomGeoAligned = 1056;
    var BaselineLeft = 2049;
    var Baseline = 2050;
    var BaselineRight = 2052;
    var BaselineJustified = 2056;
    var BaselineFlush = 2064;
    var BaselineGeoAligned = 2080;
    var MidlineLeft = 4097;
    var Midline = 4098;
    var MidlineRight = 4100;
    var MidlineJustified = 4104;
    var MidlineFlush = 4112;
    var MidlineGeoAligned = 4128;
    var CaplineLeft = 8193;
    var Capline = 8194;
    var CaplineRight = 8196;
    var CaplineJustified = 8200;
    var CaplineFlush = 8208;
    var CaplineGeoAligned = 8224;
    var Converted = 65535;
}

// Minimal TMPro.FontStyles shim.
enum abstract FontStyles(Int) {
    var Normal = 0;
    var Bold = 1;
    var Italic = 2;
    var Underline = 4;
    var LowerCase = 8;
    var UpperCase = 16;
    var SmallCaps = 32;
    var Strikethrough = 64;
    var Superscript = 128;
    var Subscript = 256;
    var Highlight = 512;
}

// Minimal TMPro.TextOverflowModes shim.
enum abstract TextOverflowModes(Int) {
    var Overflow = 0;
    var Ellipsis = 1;
    var Masking = 2;
    var Truncate = 3;
    var ScrollRect = 4;
    var Page = 5;
    var Linked = 6;
}

// Minimal TMPro.TextWrappingModes shim.
enum abstract TextWrappingModes(Int) {
    var NoWrap = 0;
    var Normal = 1;
    var PreserveWhitespace = 2;
    var PreserveWhitespaceNoWrap = 3;
}

// Minimal TMPro.HorizontalAlignmentOptions shim.
enum abstract HorizontalAlignmentOptions(Int) {
    var Left = 1;
    var Center = 2;
    var Right = 4;
    var Justified = 8;
    var Flush = 16;
    var Geometry = 32;
}

// Minimal TMPro.VerticalAlignmentOptions shim.
enum abstract VerticalAlignmentOptions(Int) {
    var Top = 256;
    var Middle = 512;
    var Bottom = 1024;
    var Baseline = 2048;
    var Geometry = 4096;
    var Capline = 8192;
}
