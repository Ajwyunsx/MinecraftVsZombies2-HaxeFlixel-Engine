package unity.ui;

import unity.events.UnityEvent;
import unity.events.UnityEvent1;
import unity.eventsystems.BaseEventData;
import unity.eventsystems.PointerEventData;
import unity.TextAnchor;
import unity.Font;
import unity.RectTransform;

// Minimal UnityEngine.UI.InputField shim.
class InputField extends Selectable {
    public var text(get, set):String;
    function get_text():String return m_Text;
    function set_text(v:String):String {
        m_Text = v;
        if (sendCallback) onValueChanged.Invoke(m_Text);
        return v;
    }
    public var textComponent:unity.ui.Text;
    public var placeholder:Graphic;
    public var characterLimit:Int = 0;
    public var contentType:ContentType = ContentType.Standard;
    public var lineType:LineType = LineType.SingleLine;
    public var inputType:InputType = InputType.Standard;
    public var characterValidation:CharacterValidationType = CharacterValidationType.None;
    public var keyboardType:Int = 0;
    public var asteriskChar:String = "*";
    public var caretBlinkRate:Float = 0.85;
    public var caretWidth:Int = 1;
    public var caretColor:unity.Color = new unity.Color();
    public var customCaretColor:Bool = false;
    public var selectionColor:unity.Color = new unity.Color(168 / 255, 206 / 255, 1, 192 / 255);
    public var readOnly:Bool = false;
    public var shouldHideMobileInput:Bool = true;
    public var onValueChanged:OnChangeEvent = new OnChangeEvent();
    public var onEndEdit:SubmitEvent = new SubmitEvent();
    public var onValidateInput:OnValidateInput;
    public var m_Text:String = "";
    public var sendCallback:Bool = true;
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

    public function new() {
        super();
    }

    public function ActivateInputField():Void {
        focused = true;
    }
    public function DeactivateInputField():Void {
        focused = false;
    }
    public function MoveTextEnd(?shift:Bool = false):Void {}
    public function MoveTextStart(?shift:Bool = false):Void {}
    public function ProcessEvent(e:Dynamic):Void {}
    public function OnUpdateSelected(eventData:BaseEventData):Void {}
    public function OnPointerClick(eventData:PointerEventData):Void {}
    public function OnSubmit(eventData:BaseEventData):Void {}
    public function Append(text:String):Void {}
    public function SetTextWithoutNotify(input:String):Void {
        m_Text = input;
    }
}

// Minimal UnityEngine.UI.InputField.ContentType shim.
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

// Minimal UnityEngine.UI.InputField.InputType shim.
enum abstract InputType(Int) {
    var Standard = 0;
    var AutoCorrect = 1;
    var Password = 2;
}

// Minimal UnityEngine.UI.InputField.CharacterValidation shim.
enum abstract CharacterValidationType(Int) {
    var None = 0;
    var Digit = 1;
    var Integer = 2;
    var Decimal = 3;
    var Alphanumeric = 4;
    var Name = 5;
    var EmailAddress = 6;
}

// Minimal UnityEngine.UI.InputField.LineType shim.
enum abstract LineType(Int) {
    var SingleLine = 0;
    var MultiLineSubmit = 1;
    var MultiLineNewline = 2;
}

// Minimal UnityEngine.UI.InputField.SubmitEvent shim.
class SubmitEvent extends UnityEvent1<String> {
    public function new() {
        super();
    }
}

// Minimal UnityEngine.UI.InputField.OnChangeEvent shim.
class OnChangeEvent extends UnityEvent1<String> {
    public function new() {
        super();
    }
}

// Minimal UnityEngine.UI.InputField.OnValidateInput shim.
typedef OnValidateInput = String->Int->String->String;
