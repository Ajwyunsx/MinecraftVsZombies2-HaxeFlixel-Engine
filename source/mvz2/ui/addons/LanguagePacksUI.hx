// Ported from: Assets/Scripts/View/Addons/LanguagePacksUI.cs
package mvz2.ui.addons;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import unity.GameObject;
import unity.UnityObject;
import unity.ui.Button;
import unity.ui.ToggleGroup;
import mvz2.ui.addons.LanguagePackItem;
import unity.MonoBehaviour;
import mvz2.ui.addons.LanguagePackItem.LanguagePackViewData;
import flixel.util.FlxSignal;

class LanguagePacksUI extends unity.MonoBehaviour
{
	public function DeselectAll():Void
	{
		toggleGroup.SetAllTogglesOff();
	}
	public function SelectItemUI(enabled:Bool, index:Int):Void
	{
		var item:Null<LanguagePackItem>;
		if (enabled)
		{
			item = enabledLanguagePacks.getElementAs(index, LanguagePackItem);
		}
		else
		{
			item = disabledLanguagePacks.getElementAs(index, LanguagePackItem);
		}
		if (UnityObject.exists(item))
			item.SetToggled(true);
	}
	public function SetDisabledLanguagePacks(viewDatas:Array<LanguagePackViewData>):Void
	{
		disabledLanguagePacks.updateList(viewDatas.length,
			function(i:Int, obj:GameObject)
			{
				var packItem = obj.GetComponent(LanguagePackItem);
				packItem.UpdateItem(viewDatas[i]);
			},
			function(obj:GameObject)
			{
				var packItem = obj.GetComponent(LanguagePackItem);
				packItem.OnToggled.add(OnDisabledPackItemToggledCallback);
			},
			function(obj:GameObject)
			{
				var packItem = obj.GetComponent(LanguagePackItem);
				packItem.OnToggled.remove(OnDisabledPackItemToggledCallback);
			});
	}
	public function SetEnabledLanguagePacks(viewDatas:Array<LanguagePackViewData>):Void
	{
		enabledLanguagePacks.updateList(viewDatas.length,
			function(i:Int, obj:GameObject)
			{
				var packItem = obj.GetComponent(LanguagePackItem);
				packItem.UpdateItem(viewDatas[i]);
			},
			function(obj:GameObject)
			{
				var packItem = obj.GetComponent(LanguagePackItem);
				packItem.OnToggled.add(OnEnabledPackItemToggledCallback);
			},
			function(obj:GameObject)
			{
				var packItem = obj.GetComponent(LanguagePackItem);
				packItem.OnToggled.remove(OnEnabledPackItemToggledCallback);
			});
	}
	public function SetButtonInteractable(button:Buttons, value:Bool):Void
	{
		if (buttonDict.exists(button))
		{
			var btn = buttonDict.get(button);
			btn.interactable = value;
		}
	}
	private function Awake():Void
	{
		buttonDict.set(Buttons.Disable, disableButton);
		buttonDict.set(Buttons.Enable, enableButton);
		buttonDict.set(Buttons.MoveUp, moveUpButton);
		buttonDict.set(Buttons.MoveDown, moveDownButton);
		buttonDict.set(Buttons.Import, importButton);
		buttonDict.set(Buttons.Export, exportButton);
		buttonDict.set(Buttons.Delete, deleteButton);
		buttonDict.set(Buttons.Return, returnButton);

		for (key in buttonDict.keys())
		{
			var capturedKey = key;
			buttonDict.get(key).onClick.AddListener(() -> OnButtonClick.dispatch(capturedKey));
		}
	}
	private function OnDisabledPackItemToggledCallback(item:LanguagePackItem, value:Bool):Void
	{
		OnPackItemToggled.dispatch(false, disabledLanguagePacks.indexOfComponent(item), value);
	}
	private function OnEnabledPackItemToggledCallback(item:LanguagePackItem, value:Bool):Void
	{
		OnPackItemToggled.dispatch(true, enabledLanguagePacks.indexOfComponent(item), value);
	}
	public var OnPackItemToggled:FlxTypedSignal<Bool->Int->Bool->Void> = new FlxTypedSignal();
	public var OnButtonClick:FlxTypedSignal<Buttons->Void> = new FlxTypedSignal();
	@:serializeField
	private var toggleGroup:ToggleGroup;
	@:serializeField
	private var disabledLanguagePacks:ElementList;
	@:serializeField
	private var enabledLanguagePacks:ElementList;
	@:serializeField
	private var disableButton:Button;
	@:serializeField
	private var enableButton:Button;
	@:serializeField
	private var moveUpButton:Button;
	@:serializeField
	private var moveDownButton:Button;
	@:serializeField
	private var importButton:Button;
	@:serializeField
	private var exportButton:Button;
	@:serializeField
	private var deleteButton:Button;
	@:serializeField
	private var returnButton:Button;
	private var buttonDict:Map<Buttons, Button> = new Map<Buttons, Button>();
}

enum abstract Buttons(Int)
{
	var Disable = 0;
	var Enable = 1;
	var MoveUp = 2;
	var MoveDown = 3;
	var Import = 4;
	var Export = 5;
	var Delete = 6;
	var Return = 7;
}
