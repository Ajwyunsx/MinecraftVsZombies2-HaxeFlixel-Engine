// Ported from: Assets/Scripts/View/Dialogs/Options/OptionWidgets.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.LabeledDropdown;
import mvz2.ui.LabeledToggle;
import mvz2.ui.TextButton;
import mvz2.ui.TextSlider;
import mvz2logic.options.OptionWidgetType;
import pvzengine.NamespaceID;
import unity.UnityObject;
import unity.tmpro.TMP_Dropdown;
import unity.ui.Button;
import unity.ui.Dropdown;
import unity.MonoBehaviour;
import unity.ui.Slider;
import unity.ui.Text;
import unity.ui.Toggle;
import unity.tmpro.TMP_Dropdown.TMP_OptionData;
import flixel.util.FlxSignal;

class OptionWidgets extends unity.MonoBehaviour implements IOptionsDialogElement
{
	public function GetOptionID():Null<NamespaceID>
	{
		return optionID;
	}
	public function SetSliderText(text:String):Void
	{
		slider.Text.text = text;
	}
	public function SetButtonText(text:String):Void
	{
		button.Text.text = text;
	}
	public function SetDropdownValue(value:Int):Void
	{
		dropdown.Dropdown.SetValueWithoutNotify(value);
	}
	public function SetDropdownOptions(options:Array<String>):Void
	{
		dropdown.Dropdown.ClearOptions();
		// PORT-NOTE: C# 的 TMP_Dropdown.AddOptions(List<string>) 重载在 Haxe shim 中只有 OptionData 版本，这里显式构造。
		dropdown.Dropdown.AddOptions([for (s in options) new TMP_OptionData(s)]);
	}
	public function UpdateWidgets(viewData:OptionWidgetsViewData):Void
	{
		optionID = viewData.namespaceID;
		switch (viewData.type)
		{
			case OptionWidgetType.Toggle:
				UpdateToggle(viewData);
			case OptionWidgetType.Slider:
				UpdateSlider(viewData);
			case OptionWidgetType.Dropdown:
				UpdateDropdown(viewData);
			case OptionWidgetType.Button:
				UpdateButton(viewData);
		}
	}
	private function UpdateToggle(viewData:OptionWidgetsViewData):Void
	{
		toggle.gameObject.SetActive(true);
		slider.gameObject.SetActive(false);
		dropdown.gameObject.SetActive(false);
		button.gameObject.SetActive(false);

		toggle.Text.text = viewData.label;

		if (Std.isOfType(viewData.value, Bool))
		{
			var boolValue:Bool = cast viewData.value;
			toggle.Toggle.SetIsOnWithoutNotify(boolValue);
		}
	}
	private function UpdateSlider(viewData:OptionWidgetsViewData):Void
	{
		toggle.gameObject.SetActive(false);
		slider.gameObject.SetActive(true);
		dropdown.gameObject.SetActive(false);
		button.gameObject.SetActive(false);

		slider.Text.text = viewData.label;

		slider.Slider.wholeNumbers = viewData.sliderWholeNumbers;
		slider.Slider.minValue = viewData.sliderMinValue;
		slider.Slider.maxValue = viewData.sliderMaxValue;

		if (Std.isOfType(viewData.value, Float))
		{
			var floatValue:Float = cast viewData.value;
			slider.Slider.SetValueWithoutNotify(floatValue);
		}
	}
	private function UpdateDropdown(viewData:OptionWidgetsViewData):Void
	{
		toggle.gameObject.SetActive(false);
		slider.gameObject.SetActive(false);
		dropdown.gameObject.SetActive(true);
		button.gameObject.SetActive(false);

		dropdown.Text.text = viewData.label;
		dropdown.Dropdown.ClearOptions();
		// PORT-NOTE: C# 的 TMP_Dropdown.AddOptions(List<string>) 重载在 Haxe shim 中只有 OptionData 版本，这里显式构造。
		dropdown.Dropdown.AddOptions([for (s in viewData.dropdownOptions) new TMP_OptionData(s)]);

		if (Std.isOfType(viewData.value, Int))
		{
			var index:Int = cast viewData.value;
			dropdown.Dropdown.SetValueWithoutNotify(index);
		}
	}
	private function UpdateButton(viewData:OptionWidgetsViewData):Void
	{
		toggle.gameObject.SetActive(false);
		slider.gameObject.SetActive(false);
		dropdown.gameObject.SetActive(false);
		button.gameObject.SetActive(true);

		button.Text.text = viewData.label;
	}
	private function Awake():Void
	{
		toggle.Toggle.onValueChanged.AddListener(v -> OnToggleValueChanged.dispatch(this, v));
		slider.Slider.onValueChanged.AddListener(v -> OnSliderValueChanged.dispatch(this, v));
		if (UnityObject.exists(slider.EndHandler))
			slider.EndHandler.OnEnd.add(data -> OnSliderEnd.dispatch(this, slider.Slider.value));
		dropdown.Dropdown.onValueChanged.AddListener(v -> OnDropdownValueChanged.dispatch(this, v));
		button.Button.onClick.AddListener(() -> OnButtonClicked.dispatch(this));
	}
	public var OnToggleValueChanged:FlxTypedSignal<OptionWidgets->Bool->Void> = new FlxTypedSignal();
	public var OnSliderValueChanged:FlxTypedSignal<OptionWidgets->Float->Void> = new FlxTypedSignal();
	public var OnSliderEnd:FlxTypedSignal<OptionWidgets->Float->Void> = new FlxTypedSignal();
	public var OnDropdownValueChanged:FlxTypedSignal<OptionWidgets->Int->Void> = new FlxTypedSignal();
	public var OnButtonClicked:FlxTypedSignal<OptionWidgets->Void> = new FlxTypedSignal();
	public var Toggle(get, never):LabeledToggle;
	function get_Toggle():LabeledToggle return toggle;
	public var Slider(get, never):TextSlider;
	function get_Slider():TextSlider return slider;
	public var Dropdown(get, never):LabeledDropdown;
	function get_Dropdown():LabeledDropdown return dropdown;
	public var TextButton(get, never):TextButton;
	function get_TextButton():TextButton return button;
	private var optionID:Null<NamespaceID>;

	@:serializeField
	private var toggle:LabeledToggle;
	@:serializeField
	private var slider:TextSlider;
	@:serializeField
	private var dropdown:LabeledDropdown;
	@:serializeField
	private var button:TextButton;
}

// C# 中为 MVZ2.UI 的 OptionWidgetsViewData 结构体。
class OptionWidgetsViewData
{
	public var type:OptionWidgetType;
	public var label:String;
	public var value:Dynamic;
	public var sliderWholeNumbers:Bool;
	public var sliderMinValue:Float;
	public var sliderMaxValue:Float;
	public var tooltipText:String;
	public var tooltipContext:String;
	public var namespaceID:NamespaceID;
	public var dropdownOptions:Array<String>;

	// PORT-NOTE: C# 结构体初始化器 `new OptionWidgetsViewData { field = value }` 在 Haxe 中写作 `new OptionWidgetsViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new OptionWidgetsViewData()`。
	public function new(?data:{?type:OptionWidgetType, ?label:String, ?value:Dynamic, ?sliderWholeNumbers:Bool, ?sliderMinValue:Float, ?sliderMaxValue:Float, ?tooltipText:String, ?tooltipContext:String, ?namespaceID:NamespaceID, ?dropdownOptions:Array<String>})
	{
		if (data == null)
			return;
		if (data.type != null) type = data.type;
		if (data.label != null) label = data.label;
		if (data.value != null) value = data.value;
		if (data.sliderWholeNumbers != null) sliderWholeNumbers = data.sliderWholeNumbers;
		if (data.sliderMinValue != null) sliderMinValue = data.sliderMinValue;
		if (data.sliderMaxValue != null) sliderMaxValue = data.sliderMaxValue;
		if (data.tooltipText != null) tooltipText = data.tooltipText;
		if (data.tooltipContext != null) tooltipContext = data.tooltipContext;
		if (data.namespaceID != null) namespaceID = data.namespaceID;
		if (data.dropdownOptions != null) dropdownOptions = data.dropdownOptions;
	}
}
