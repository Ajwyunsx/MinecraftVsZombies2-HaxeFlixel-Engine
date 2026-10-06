package unity.ui;

import unity.RectTransform;
import unity.Sprite;
import unity.events.UnityEvent1;

// Minimal UnityEngine.UI.Dropdown shim.
class Dropdown extends Selectable {
    public var template:RectTransform;
    public var captionText:unity.ui.Text;
    public var captionImage:Image;
    public var itemText:unity.ui.Text;
    public var itemImage:Image;
    public var options(get, set):Array<OptionData>;
    function get_options():Array<OptionData> return m_Options.options;
    function set_options(v:Array<OptionData>):Array<OptionData> {
        SetupOptions(v, value);
        return v;
    }
    public var value(get, set):Int;
    function get_value():Int return m_Value;
    function set_value(v:Int):Int {
        Set(v, true);
        return v;
    }
    public var onValueChanged:DropdownEvent = new DropdownEvent();
    public var alphaFadeSpeed:Float = 0.15;
    public var itemTextAlignment:unity.TextAnchor;
    public var template_Transform:RectTransform;

    private var m_Value:Int = 0;
    private var m_Options:OptionDataList = new OptionDataList();

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
    public function AddOptions(options:Array<OptionData>):Void {
        m_Options.options = m_Options.options.concat(options);
        RefreshShownValue();
    }
    public function ClearOptions():Void {
        m_Options.options = [];
        RefreshShownValue();
    }
    private function SetupOptions(options:Array<OptionData>, defaultOption:Int):Void {
        m_Options.options = options.copy();
        Set(defaultOption, true);
    }
    public function Show():Void {}
    public function Hide():Void {}
    public function OnPointerClick(eventData:unity.eventsystems.PointerEventData):Void {}
    public function OnSubmit(eventData:unity.eventsystems.BaseEventData):Void {}
}

// Minimal UnityEngine.UI.Dropdown.OptionData shim.
class OptionData {
    public var text:String;
    public var image:Sprite;
    public function new(?text:String = null, ?image:Sprite = null) {
        this.text = text;
        this.image = image;
    }
}

// Minimal UnityEngine.UI.Dropdown.OptionDataList shim.
class OptionDataList {
    public var options:Array<OptionData> = [];
    public function new() {}
}

// Minimal UnityEngine.UI.Dropdown.DropdownEvent shim.
class DropdownEvent extends UnityEvent1<Int> {
    public function new() {
        super();
    }
}
