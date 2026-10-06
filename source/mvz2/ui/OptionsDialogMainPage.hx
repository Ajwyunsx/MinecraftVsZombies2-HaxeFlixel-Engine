// Ported from: Assets/Scripts/View/Dialogs/Options/OptionsDialogMainPage.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.LabeledToggle;
import mvz2.ui.TextButton;
import mvz2.ui.TextSlider;
import mvz2.ui.TooltipHandler;
import unity.GameObject;
import unity.Transform;
import unity.UnityObject;
import unity.ui.Button;
import unity.MonoBehaviour;
import unity.ui.Slider;
import unity.ui.Text;
import unity.ui.Toggle;
import flixel.util.FlxSignal;

class OptionsDialogMainPage extends unity.MonoBehaviour
{
	// #region 滑动条
	public function SetSliderValue(type:SliderType, value:Float):Void
	{
		if (sliderDict.exists(type))
		{
			var slider = sliderDict.get(type);
			slider.Slider.SetValueWithoutNotify(value);
		}
	}
	public function SetSliderRange(type:SliderType, min:Float, max:Float, integer:Bool):Void
	{
		if (sliderDict.exists(type))
		{
			var slider = sliderDict.get(type);
			slider.Slider.minValue = min;
			slider.Slider.maxValue = max;
			slider.Slider.wholeNumbers = integer;
		}
	}
	public function SetSliderText(type:SliderType, text:String):Void
	{
		if (sliderDict.exists(type))
		{
			var slider = sliderDict.get(type);
			slider.Text.text = text;
		}
	}
	public function SetSliderActive(type:SliderType, value:Bool):Void
	{
		if (sliderDict.exists(type))
		{
			var slider = sliderDict.get(type);
			slider.gameObject.SetActive(value);
			UpdateWidgetAreas();
		}
	}
	// #endregion

	// #region 按钮
	public function SetButtonText(type:TextButtonType, text:String):Void
	{
		if (textButtonDict.exists(type))
		{
			var button = textButtonDict.get(type);
			button.Text.text = text;
		}
	}
	public function SetButtonActive(type:ButtonType, value:Bool):Void
	{
		if (buttonDict.exists(type))
		{
			var button = buttonDict.get(type);
			button.gameObject.SetActive(value);
			UpdateWidgetAreas();
		}
	}
	// #endregion

	// #region 切换
	public function SetToggleActive(type:ToggleType, value:Bool):Void
	{
		if (toggleDict.exists(type))
		{
			var toggle = toggleDict.get(type);
			toggle.gameObject.SetActive(value);
			UpdateWidgetAreas();
		}
	}
	public function SetToggleText(type:ToggleType, text:String):Void
	{
		if (toggleDict.exists(type))
		{
			var toggle = toggleDict.get(type);
			toggle.Text.text = text;
		}
	}
	public function SetToggleOn(type:ToggleType, value:Bool):Void
	{
		if (toggleDict.exists(type))
		{
			var toggle = toggleDict.get(type);
			toggle.Toggle.SetIsOnWithoutNotify(value);
		}
	}
	// #endregion

	// #region 生命周期
	private function Awake():Void
	{
		sliderDict.set(SliderType.Music, musicSlider);
		sliderDict.set(SliderType.Sound, soundSlider);
		sliderDict.set(SliderType.FastForward, fastForwardSlider);

		// 1-1
		toggleDict.set(ToggleType.SwapTrigger, swapTriggerToggle);

		// 1-2
		toggleDict.set(ToggleType.PauseOnFocusLost, pauseOnFocusLostToggle);

		// 2-1
		textButtonDict.set(TextButtonType.MoreOptions, moreOptionsButton);
		buttonDict.set(ButtonType.MoreOptions, moreOptionsButton.Button);

		// 2-2
		textButtonDict.set(TextButtonType.Difficulty, diffcultyButton);
		textButtonDict.set(TextButtonType.Restart, restartButton);
		buttonDict.set(ButtonType.Difficulty, diffcultyButton.Button);
		buttonDict.set(ButtonType.Restart, restartButton.Button);

		// 3-1
		textButtonDict.set(TextButtonType.LeaveLevel, leaveLevelButton);
		buttonDict.set(ButtonType.LeaveLevel, leaveLevelButton.Button);

		// 3-2
		textButtonDict.set(TextButtonType.Back, backButton);
		buttonDict.set(ButtonType.Back, backButton.Button);

		for (type in sliderDict.keys())
		{
			var capturedType = type;
			var slider = sliderDict.get(type);
			slider.Slider.onValueChanged.AddListener(value -> OnSliderValueChanged.dispatch(capturedType, value));
			if (UnityObject.exists(slider.EndHandler))
				slider.EndHandler.OnEnd.add(value -> OnSliderEnd.dispatch(capturedType, slider.Slider.value));
		}
		for (type in buttonDict.keys())
		{
			var capturedType = type;
			buttonDict.get(type).onClick.AddListener(() -> OnButtonClick.dispatch(capturedType));
		}
		for (type in toggleDict.keys())
		{
			var capturedType = type;
			toggleDict.get(type).Toggle.onValueChanged.AddListener((v) -> OnToggleValueChanged.dispatch(capturedType, v));
		}
		var tooltipHandlers = gameObject.GetComponentsInChildren(TooltipHandler, true);
		for (handler in tooltipHandlers)
		{
			handler.OnPointerEnterSignal.add(OnTooltipHandlerPointerEnterCallback);
			handler.OnPointerExitSignal.add(OnTooltipHandlerPointerExitCallback);
		}
	}
	// #endregion

	// #region 事件回调
	private function OnTooltipHandlerPointerEnterCallback(handler:TooltipHandler):Void
	{
		OnTooltipShow.dispatch(handler);
	}
	private function OnTooltipHandlerPointerExitCallback(handler:TooltipHandler):Void
	{
		OnTooltipHide.dispatch(handler);
	}
	// #endregion

	private function UpdateWidgetAreas():Void
	{
		for (line in widgetAreas)
		{
			var hasActiveChild = HasAnyChildrenElement(line);
			line.gameObject.SetActive(hasActiveChild);
		}
	}
	private function HasAnyChildrenElement(parent:Transform):Bool
	{
		for (i in 0...parent.childCount)
		{
			var child = parent.GetChild(i);
			if (child == null || !child.gameObject.activeSelf)
				continue;
			if (child.GetComponent(IOptionsDialogElement) != null)
			{
				return true;
			}
			if (HasAnyChildrenElement(child))
			{
				return true;
			}
		}
		return false;
	}

	public var OnSliderValueChanged:FlxTypedSignal<SliderType->Float->Void> = new FlxTypedSignal();
	public var OnSliderEnd:FlxTypedSignal<SliderType->Float->Void> = new FlxTypedSignal();
	public var OnButtonClick:FlxTypedSignal<ButtonType->Void> = new FlxTypedSignal();
	public var OnToggleValueChanged:FlxTypedSignal<ToggleType->Bool->Void> = new FlxTypedSignal();
	public var OnTooltipShow:FlxTypedSignal<TooltipHandler->Void> = new FlxTypedSignal();
	public var OnTooltipHide:FlxTypedSignal<TooltipHandler->Void> = new FlxTypedSignal();

	private var sliderDict:Map<SliderType, TextSlider> = new Map<SliderType, TextSlider>();
	private var textButtonDict:Map<TextButtonType, TextButton> = new Map<TextButtonType, TextButton>();
	private var buttonDict:Map<ButtonType, Button> = new Map<ButtonType, Button>();
	private var toggleDict:Map<ToggleType, LabeledToggle> = new Map<ToggleType, LabeledToggle>();

	@:serializeField
	private var widgetAreas:Array<Transform>;

	@:serializeField
	private var musicSlider:TextSlider;
	@:serializeField
	private var soundSlider:TextSlider;
	@:serializeField
	private var fastForwardSlider:TextSlider;

	@:serializeField
	private var swapTriggerToggle:LabeledToggle;
	@:serializeField
	private var pauseOnFocusLostToggle:LabeledToggle;

	@:serializeField
	private var diffcultyButton:TextButton;
	@:serializeField
	private var restartButton:TextButton;

	@:serializeField
	private var moreOptionsButton:TextButton;
	@:serializeField
	private var leaveLevelButton:TextButton;

	@:serializeField
	private var backButton:TextButton;
}

enum abstract SliderType(Int)
{
	var Music = 0;
	var Sound = 1;
	var FastForward = 2;
}

enum abstract TextButtonType(Int)
{
	var Difficulty = 0;
	var Restart = 1;

	var MoreOptions = 2;
	var LeaveLevel = 3;

	var Back = 4;
}

enum abstract ButtonType(Int)
{
	var Difficulty = 0;
	var Restart = 1;

	var MoreOptions = 2;
	var LeaveLevel = 3;

	var Back = 4;
}

enum abstract ToggleType(Int)
{
	var SwapTrigger = 0;
	var PauseOnFocusLost = 1;
}
