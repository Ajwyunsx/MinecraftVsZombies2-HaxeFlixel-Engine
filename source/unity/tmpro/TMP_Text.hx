package unity.tmpro;

import unity.ui.Graphic.MaskableGraphic;
import unity.tmpro.TextMeshProUGUI.FontStyles;
import unity.tmpro.TextMeshProUGUI.TextAlignmentOptions;
import unity.tmpro.TextMeshProUGUI.TextOverflowModes;
import unity.tmpro.TMP_TextInfo.TMP_LinkInfo;
import unity.Mathf.FloatRef;

// Minimal TMPro.TMP_Text base shim.
class TMP_Text extends MaskableGraphic {
    public var text:String = "";
    public var font:TMP_FontAsset;
    public var fontSize:Float = 36;
    public var fontStyle:FontStyles = FontStyles.Normal;
    public var alignment:TextAlignmentOptions = TextAlignmentOptions.TopLeft;
    // PORT-NOTE: `color` 继承自 unity.ui.Graphic，Haxe 不允许子类重定义变量。
    public var alpha:Float = 1;
    public var enableWordWrapping:Bool = true;
    public var richText:Bool = true;
    public var overflowMode:TextOverflowModes = TextOverflowModes.Overflow;
    public var margin:unity.Vector4 = new unity.Vector4();
    public var textInfo:TMP_TextInfo = new TMP_TextInfo();
    public var preferredWidth(get, never):Float;
    function get_preferredWidth():Float return text != null ? text.length * fontSize * 0.5 : 0;
    public var preferredHeight(get, never):Float;
    function get_preferredHeight():Float return fontSize;
    public var isTextOverflowing(get, never):Bool;
    function get_isTextOverflowing():Bool return false;
    public var maxVisibleCharacters:Int = 99999;
    public var firstVisibleCharacter:Int = 0;

    public function new() {
        super();
    }

    public function SetText(value:String):Void text = value;
    public function ForceMeshUpdate(?ignoreActiveState:Bool = false, ?forceTextReparsing:Bool = false):Void {}
    public function GetPreferredValues(?width:Float = 0, ?height:Float = 0):unity.Vector2 return new unity.Vector2(preferredWidth, preferredHeight);
    // C#: public Vector2 GetPreferredValues(string text, float width, float height)
    // PORT-NOTE: Haxe 无重载，按 PORTING.md 改名约定加 Text 后缀；移植层无法真正测量文本，
    // 与无参版本一样返回 TMP_Text 的 preferredWidth/preferredHeight。
    public function GetPreferredValuesText(?text:String = null, ?width:Float = 0, ?height:Float = 0):unity.Vector2 return new unity.Vector2(preferredWidth, preferredHeight);
    public function GetRenderedValues():unity.Vector2 return new unity.Vector2(preferredWidth, preferredHeight);
    public function ComputeMarginSize():Void {}
    public function UpdateMeshPadding():Void {}
    public function CalculateLayoutInputHorizontal():Void {}
    public function CalculateLayoutInputVertical():Void {}
}

// Minimal TMPro.TMP_TextUtilities shim.
class TMP_TextUtilities {
    public static function GetCursorIndexFromPosition(text:TMP_Text, position:unity.Vector3, camera:unity.Camera, ?isSelecting:Bool = false):Int {
        // TODO-PORT: 需要 TMP 的布局信息，移植层使用 openfl 文本度量。
        return 0;
    }
    public static function FindIntersectingLink(text:TMP_Text, position:unity.Vector3, camera:unity.Camera):Int return -1;
    public static function GetIntersectingLink(text:TMP_Text, position:unity.Vector3, camera:unity.Camera):TMP_LinkInfo return null;
    public static function ToString(text:TMP_Text):String return "";
    public static function IsIntersectingRectTransform(rectTransform:unity.RectTransform, position:unity.Vector3, camera:unity.Camera):Bool return false;
}

// Minimal TMPro.TMP_Math shim.
class TMP_Math {
    public static inline var FLOAT_MAX:Float = 32767.0;
    public static inline var FLOAT_MIN:Float = -32767.0;
    public static inline var MAX_16BIT:Int = 65535;
    public static inline var MIN_16BIT:Int = 0;

    public static function Approximately(a:Float, b:Float):Bool return Math.abs(b - a) < 0.001;
    public static function Mod(a:Float, b:Float):Float return a % b;
    public static function Modf(a:Float, mod:Float, ?out:FloatRef = null):Float return a % mod;
}

// Minimal TMPro.TMP_InputValidator shim.
class TMP_InputValidator extends unity.ScriptableObject {
    public function new() {
        super();
    }
    public function Validate(text:String, pos:Int, ch:String):String return ch;
}

// Minimal TMPro.TMP_SelectionCaret shim.
class TMP_SelectionCaret extends MaskableGraphic {
    public function new() {
        super();
    }
}

// Minimal TMPro.TMP_ScrollbarEventHandler shim.
class TMP_ScrollbarEventHandler extends unity.MonoBehaviour {
    public var isSelected:Bool = false;
    public function new() {
        super();
    }
    public function OnPointerClick(eventData:unity.eventsystems.PointerEventData):Void {}
    public function OnSelect(eventData:unity.eventsystems.BaseEventData):Void {}
    public function OnDeselect(eventData:unity.eventsystems.BaseEventData):Void {}
}
