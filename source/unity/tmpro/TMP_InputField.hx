package unity.tmpro;

import unity.RectTransform;
import unity.events.UnityEvent1;

// Minimal TMPro.TMP_InputField shim（仅保留游戏代码用到的公开 API）。
class TMP_InputField extends unity.ui.Selectable {
    public var text(get, set):String;
    function get_text():String return m_Text;
    function set_text(v:String):String {
        m_Text = v;
        if (onValueChanged != null) onValueChanged.Invoke(m_Text);
        return v;
    }
    public var textComponent:TextMeshProUGUI;
    public var textViewport:RectTransform;
    public var placeholder:unity.ui.Graphic;
    public var caretColor:unity.Color = new unity.Color();
    public var customCaretColor:Bool = false;
    public var selectionColor:unity.Color = new unity.Color();
    public var caretBlinkRate:Float = 0.85;
    public var caretWidth:Int = 1;
    public var characterLimit:Int = 0;
    public var contentType:ContentType = ContentType.Standard;
    public var lineType:LineType = LineType.SingleLine;
    public var inputType:InputType = InputType.Standard;
    public var characterValidation:CharacterValidationType = CharacterValidationType.None;
    public var readOnly:Bool = false;
    public var richText:Bool = true;
    public var onValueChanged:OnChangeEvent = new OnChangeEvent();
    public var onEndEdit:SubmitEvent = new SubmitEvent();
    public var onSubmit:SubmitEvent = new SubmitEvent();
    public var onSelect:SelectionEvent = new SelectionEvent();
    public var onDeselect:SelectionEvent = new SelectionEvent();
    public var isFocused(get, never):Bool;
    function get_isFocused():Bool return focused;
    public var focused:Bool = false;
    public var caretPosition(get, set):Int;
    function get_caretPosition():Int return caret;
    function set_caretPosition(v:Int):Int {
        caret = v;
        return v;
    }
    private var caret:Int = 0;
    public var selectionAnchorPosition:Int = 0;
    public var selectionFocusPosition:Int = 0;
    public var m_Text:String = "";

    public function new() {
        super();
    }

    public function SetTextWithoutNotify(input:String):Void m_Text = input;
    public function ActivateInputField():Void focused = true;
    public function DeactivateInputField(?clearSelection:Bool = false):Void focused = false;
    public function MoveTextEnd(?shift:Bool = false):Void {}
    public function MoveTextStart(?shift:Bool = false):Void {}
    public function MoveToEndOfLine(shift:Bool, ctrl:Bool):Void {}
    public function MoveToStartOfLine(shift:Bool, ctrl:Bool):Void {}
    public function ForceLabelUpdate():Void {}
    public function ProcessEvent(e:Dynamic):Void {}
    public function OnUpdateSelected(eventData:unity.eventsystems.BaseEventData):Void {}
    public function OnPointerClick(eventData:unity.eventsystems.PointerEventData):Void {}
    public function OnSubmit(eventData:unity.eventsystems.BaseEventData):Void {}
    public function OnControlClick():Void {}
    public function ReleaseSelection():Void {}
    public function SetGlobalPointSize(pointSize:Float):Void {}
    public function SetGlobalFontAsset(fontAsset:TMP_FontAsset):Void {}
    public function Append(text:String):Void {}
}

// Minimal TMPro.TMP_InputField.ContentType shim.
enum abstract ContentType(Int) {
    var Standard = 0;
    var Autocorrected = 1;
    var IntegerNumber = 2;
    var DecimalNumber = 3;
    var Alphanumeric = 4;
    var Name = 5;
    var EmailAddress = 6;
    var Password = 7;
    var Pin = 8;
    var Custom = 9;
}

// Minimal TMPro.TMP_InputField.InputType shim.
enum abstract InputType(Int) {
    var Standard = 0;
    var AutoCorrect = 1;
    var Password = 2;
}

// Minimal TMPro.TMP_InputField.CharacterValidation shim.
enum abstract CharacterValidationType(Int) {
    var None = 0;
    var Digit = 1;
    var Integer = 2;
    var Decimal = 3;
    var Alphanumeric = 4;
    var Name = 5;
    var Regex = 6;
    var EmailAddress = 7;
    var CustomValidator = 8;
}

// Minimal TMPro.TMP_InputField.LineType shim.
enum abstract LineType(Int) {
    var SingleLine = 0;
    var MultiLineSubmit = 1;
    var MultiLineNewline = 2;
}

// Minimal TMPro.TMP_InputField.SubmitEvent shim.
class SubmitEvent extends UnityEvent1<String> {
    public function new() {
        super();
    }
}

// Minimal TMPro.TMP_InputField.OnChangeEvent shim.
class OnChangeEvent extends UnityEvent1<String> {
    public function new() {
        super();
    }
}

// Minimal TMPro.TMP_InputField.SelectionEvent shim.
class SelectionEvent extends UnityEvent1<String> {
    public function new() {
        super();
    }
}

// Minimal TMPro.TMP_InputField.OnValidateInput shim.
typedef OnValidateInput = String->Int->String->String;
