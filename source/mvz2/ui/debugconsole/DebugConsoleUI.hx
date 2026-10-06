// Ported from: Assets/Scripts/View/DebugConsole/DebugConsoleUI.cs
package mvz2.ui.debugconsole;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import mvz2.ui.UIHelper;
import unity.Canvas;
import unity.GameObject;
import unity.RectTransform;
import unity.UnityObject;
import unity.Vector2;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import unity.ui.ScrollRect;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class DebugConsoleUI extends unity.MonoBehaviour
{
	public function IsCommandFocused():Bool
	{
		return inputField.isFocused;
	}
	public function SetCommand(command:String):Void
	{
		inputField.text = command;
	}
	public function ForceUpdateCommand():Void
	{
		inputField.ForceLabelUpdate();
	}
	public function GetCommand():String return inputField.text;
	public function GetStringPosition():Int return inputField.stringPosition - inputField.compositionLength;
	public function SetStringPosition(position:Int):Void inputField.stringPosition = position;
	public function MoveToCommandEnd(shift:Bool):Void inputField.MoveTextEnd(shift);
	public function SetConsoleBottomMargin(marginRatio:Float):Void
	{
		var rectTransform:RectTransform = cast transform;
		if (UnityObject.exists(rectTransform) && UnityObject.exists(rootRectTransform))
		{
			// PORT-NOTE: C# 为 `rectTransform.rect.height`；unity shim 的 RectTransform 暂无 rect，
			// 用 UIHelper.GetLocalRect 按同一语义复算（见 UIHelper 的 TODO-PORT）。
			var yDelta = -marginRatio * UIHelper.GetLocalRect(rectTransform).height;
			rootRectTransform.sizeDelta = new Vector2(0, yDelta);
		}
	}
	public function Print(text:String):Void
	{
		outputText.text += text;
		Canvas.ForceUpdateCanvases();
		outputScroll.verticalNormalizedPosition = 0;
	}
	public function ClearConsole():Void
	{
		outputText.text = "";
		Canvas.ForceUpdateCanvases();
		outputScroll.verticalNormalizedPosition = 0;
	}
	public function ActivateInputField():Void
	{
		inputField.ActivateInputField();
		inputField.Select();
	}

	// #region 自动补全
	public function ShowAutoCompletePanel():Void
	{
		autoCompletePanel.SetActive(true);
	}
	public function HideAutoCompletePanel():Void
	{
		autoCompletePanel.SetActive(false);
	}
	public function SetAutoCompletePosition(index:Int):Void
	{
		var substring = inputField.text.substr(0, index);
		// TODO-PORT: unity.tmpro.TMP_Text shim 的 GetPreferredValues(?width:Float, ?height:Float) 没有
		// C# 的 GetPreferredValues(string) 重载，也无法真正测量文本，故退化为取当前文本的推荐尺寸。
		var size = inputField.textComponent.GetPreferredValues();
		var rectTransform:RectTransform = cast autoCompletePanel.transform;
		if (UnityObject.exists(rectTransform))
		{
			rectTransform.anchoredPosition = Vector2.right * (size.x + inputField.textComponent.rectTransform.anchoredPosition.x);
		}
	}
	public function SetAutoCompleteSelections(autoComplete:Array<String>, selected:Int, hasAbove:Bool, hasBelow:Bool):Void
	{
		autoCompleteSelection.updateList(autoComplete.length,
			function(i:Int, obj:GameObject)
			{
				var item = obj.GetComponent(DebugConsoleAutoCompleteItem);
				item.SetText(autoComplete[i]);
				item.SetIsOn(selected == i);
			},
			function(obj:GameObject)
			{
				var item = obj.GetComponent(DebugConsoleAutoCompleteItem);
				item.OnValueChanged.add(OnAutoCompleteItemValueChangedCallback);
			},
			function(obj:GameObject)
			{
				var item = obj.GetComponent(DebugConsoleAutoCompleteItem);
				item.OnValueChanged.remove(OnAutoCompleteItemValueChangedCallback);
			});
		autoCompleteArrowUp.interactable = hasAbove;
		autoCompleteArrowDown.interactable = hasBelow;
	}
	public function SetCurrentAutoComplete(index:Int):Void
	{
		if (autoCompleteSelection != null && index >= 0)
		{
			var item = autoCompleteSelection.getElementAs(index, DebugConsoleAutoCompleteItem);
			if (UnityObject.exists(item))
				item.SetIsOn(true);
		}
	}
	private function OnAutoCompleteItemValueChangedCallback(item:DebugConsoleAutoCompleteItem, value:Bool):Void
	{
		if (value)
			OnAutoCompleteItemClick.dispatch(autoCompleteSelection.indexOfComponent(item));
	}
	// #endregion

	private function Awake():Void
	{
		closeButton.onClick.AddListener(() -> OnCloseClick.dispatch());
		submitButton.onClick.AddListener(() -> OnSubmit.dispatch(inputField.text));
		upButton.onClick.AddListener(() -> OnArrowButtonClick.dispatch(true));
		downButton.onClick.AddListener(() -> OnArrowButtonClick.dispatch(false));
		inputField.onSubmit.AddListener((text) -> OnSubmit.dispatch(text));
		inputField.onSelect.AddListener((text) -> OnInputFieldFocus.dispatch(true));
		inputField.onDeselect.AddListener((text) -> OnInputFieldFocus.dispatch(false));
		inputField.onValueChanged.AddListener((text) -> OnInputFieldValueChanged.dispatch(text));

		autoCompleteArrowUp.onClick.AddListener(() -> OnAutoCompleteArrowButtonClick.dispatch(true));
		autoCompleteArrowDown.onClick.AddListener(() -> OnAutoCompleteArrowButtonClick.dispatch(false));
	}
	public var OnCloseClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnArrowButtonClick:FlxTypedSignal<Bool->Void> = new FlxTypedSignal();
	public var OnSubmit:FlxTypedSignal<String->Void> = new FlxTypedSignal();
	public var OnInputFieldValueChanged:FlxTypedSignal<String->Void> = new FlxTypedSignal();
	public var OnInputFieldFocus:FlxTypedSignal<Bool->Void> = new FlxTypedSignal();
	public var OnAutoCompleteItemClick:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnAutoCompleteArrowButtonClick:FlxTypedSignal<Bool->Void> = new FlxTypedSignal();

	@:serializeField
	private var rootRectTransform:RectTransform;
	@:serializeField
	private var closeButton:Button;
	@:serializeField
	private var submitButton:Button;
	@:serializeField
	private var upButton:Button;
	@:serializeField
	private var downButton:Button;
	@:serializeField
	private var inputField:DebugConsoleInputField;

	// [Header("Output")]
	@:serializeField
	private var outputText:TextMeshProUGUI;
	@:serializeField
	private var outputScroll:ScrollRect;

	// [Header("Auto Complete")]
	@:serializeField
	private var autoCompletePanel:GameObject;
	@:serializeField
	private var autoCompleteArrowUp:Button;
	@:serializeField
	private var autoCompleteArrowDown:Button;
	@:serializeField
	private var autoCompleteSelection:ElementList;
}
