// Ported from: Assets/Scripts/View/Dialogs/Options/OptionsDialogMoreOptionsPage.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import mvz2.ui.MoreOptionsCategory;
import mvz2.ui.TextButton;
import mvz2.ui.TooltipHandler;
import pvzengine.NamespaceID;
import unity.GameObject;
import unity.UnityObject;
import mvz2.ui.MoreOptionsCategory.MoreOptionsCategoryViewData;
import unity.ui.Button;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class OptionsDialogMoreOptionsPage extends unity.MonoBehaviour
{
	public function UpdateOptions(viewData:MoreOptionsViewData):Void
	{
		categories.updateList(viewData.categories.length,
			function(i:Int, obj:GameObject)
			{
				var category = obj.GetComponent(MoreOptionsCategory);
				category.UpdateOptions(viewData.categories[i]);
			},
			function(obj:GameObject)
			{
				var category = obj.GetComponent(MoreOptionsCategory);
				category.OnToggleValueChanged.add(OnToggleValueChangedCallback);
				category.OnSliderValueChanged.add(OnSliderValueChangedCallback);
				category.OnSliderEnd.add(OnSliderEndCallback);
				category.OnDropdownValueChanged.add(OnDropdownValueChangedCallback);
				category.OnButtonClicked.add(OnButtonClickedCallback);
				category.OnTooltipShow.add(OnTooltipShowCallback);
				category.OnTooltipHide.add(OnTooltipHideCallback);
			},
			function(obj:GameObject)
			{
				var category = obj.GetComponent(MoreOptionsCategory);
				category.OnToggleValueChanged.remove(OnToggleValueChangedCallback);
				category.OnSliderValueChanged.remove(OnSliderValueChangedCallback);
				category.OnSliderEnd.remove(OnSliderEndCallback);
				category.OnDropdownValueChanged.remove(OnDropdownValueChangedCallback);
				category.OnButtonClicked.remove(OnButtonClickedCallback);
				category.OnTooltipShow.remove(OnTooltipShowCallback);
				category.OnTooltipHide.remove(OnTooltipHideCallback);
			});
	}
	public function GetWidgetsByID(id:NamespaceID):Null<OptionWidgets>
	{
		for (category in categories.getElementsAs(MoreOptionsCategory))
		{
			var widgets = category.GetWidgetsByID(id);
			if (UnityObject.exists(widgets))
				return widgets;
		}
		return null;
	}
	private function Awake():Void
	{
		moreBackButton.Button.onClick.AddListener(() -> OnBackClick.dispatch());
	}
	private function OnToggleValueChangedCallback(widgets:OptionWidgets, value:Bool):Void
	{
		OnToggleValueChanged.dispatch(widgets, value);
	}
	private function OnSliderValueChangedCallback(widgets:OptionWidgets, value:Float):Void
	{
		OnSliderValueChanged.dispatch(widgets, value);
	}
	private function OnSliderEndCallback(widgets:OptionWidgets, value:Float):Void
	{
		OnSliderEnd.dispatch(widgets, value);
	}
	private function OnDropdownValueChangedCallback(widgets:OptionWidgets, value:Int):Void
	{
		OnDropdownValueChanged.dispatch(widgets, value);
	}
	private function OnButtonClickedCallback(widgets:OptionWidgets):Void
	{
		OnButtonClick.dispatch(widgets);
	}
	private function OnTooltipShowCallback(handler:TooltipHandler):Void
	{
		OnTooltipShow.dispatch(handler);
	}
	private function OnTooltipHideCallback(handler:TooltipHandler):Void
	{
		OnTooltipHide.dispatch(handler);
	}

	public var OnToggleValueChanged:FlxTypedSignal<OptionWidgets->Bool->Void> = new FlxTypedSignal();
	public var OnSliderValueChanged:FlxTypedSignal<OptionWidgets->Float->Void> = new FlxTypedSignal();
	public var OnSliderEnd:FlxTypedSignal<OptionWidgets->Float->Void> = new FlxTypedSignal();
	public var OnDropdownValueChanged:FlxTypedSignal<OptionWidgets->Int->Void> = new FlxTypedSignal();
	public var OnButtonClick:FlxTypedSignal<OptionWidgets->Void> = new FlxTypedSignal();
	public var OnTooltipShow:FlxTypedSignal<TooltipHandler->Void> = new FlxTypedSignal();
	public var OnTooltipHide:FlxTypedSignal<TooltipHandler->Void> = new FlxTypedSignal();

	public var OnBackClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	@:serializeField
	private var categories:ElementList;
	@:serializeField
	private var moreBackButton:TextButton;
}

// C# 中为 MVZ2.UI 的 MoreOptionsViewData 结构体。
class MoreOptionsViewData
{
	public var categories:Array<MoreOptionsCategoryViewData>;

	// PORT-NOTE: C# 结构体初始化器 `new MoreOptionsViewData { field = value }` 在 Haxe 中写作 `new MoreOptionsViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new MoreOptionsViewData()`。
	public function new(?data:{?categories:Array<MoreOptionsCategoryViewData>})
	{
		if (data == null)
			return;
		if (data.categories != null) categories = data.categories;
	}
}
