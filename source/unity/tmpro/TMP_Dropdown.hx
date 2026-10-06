package unity.tmpro;

import unity.RectTransform;
import unity.tmpro.TextMeshProUGUI.TextAlignmentOptions;

// Minimal TMPro.TMP_Dropdown shim.
class TMP_Dropdown extends unity.ui.Selectable {
    public var template:RectTransform;
    public var captionText:TextMeshProUGUI;
    public var captionImage:unity.ui.Image;
    public var itemText:TextMeshProUGUI;
    public var itemImage:unity.ui.Image;
    public var options(get, set):Array<TMP_OptionData>;
    function get_options():Array<TMP_OptionData> return m_Options.options;
    function set_options(v:Array<TMP_OptionData>):Array<TMP_OptionData> {
        SetupOptions(v, value);
        return v;
    }
    public var value(get, set):Int;
    function get_value():Int return m_Value;
    function set_value(v:Int):Int {
        Set(v, true);
        return v;
    }
    public var onValueChanged:TMP_DropdownEvent = new TMP_DropdownEvent();
    public var alphaFadeSpeed:Float = 0.15;
    public var itemTextAlignment:TextAlignmentOptions;

    private var m_Value:Int = 0;
    private var m_Options:TMP_OptionDataList = new TMP_OptionDataList();

    public function new() {
        super();
    }

    public function SetValueWithoutNotify(input:Int):Void {
        Set(input, false);
    }
    private function Set(value:Int, sendCallback:Bool):Void {
        if (value == m_Value) return;
        m_Value = value;
        RefreshShownValue();
        if (sendCallback) onValueChanged.Invoke(m_Value);
    }
    public function RefreshShownValue():Void {}
    public function AddOptions(options:Array<TMP_OptionData>):Void {
        m_Options.options = m_Options.options.concat(options);
        RefreshShownValue();
    }
    public function ClearOptions():Void {
        m_Options.options = [];
        RefreshShownValue();
    }
    private function SetupOptions(options:Array<TMP_OptionData>, defaultOption:Int):Void {
        m_Options.options = options.copy();
        Set(defaultOption, true);
    }
    public function Show():Void {}
    public function Hide():Void {}
    public function OnPointerClick(eventData:unity.eventsystems.PointerEventData):Void {}
}

// Minimal TMPro.TMP_Dropdown.OptionData shim.
class TMP_OptionData {
    public var text:String;
    public var image:unity.Sprite;
    public function new(?text:String = null, ?image:unity.Sprite = null) {
        this.text = text;
        this.image = image;
    }
}

// Minimal TMPro.TMP_Dropdown.OptionDataList shim.
class TMP_OptionDataList {
    public var options:Array<TMP_OptionData> = [];
    public function new() {}
}

// Minimal TMPro.TMP_Dropdown.DropdownEvent shim.
class TMP_DropdownEvent extends unity.events.UnityEvent1<Int> {
    public function new() {
        super();
    }
}
