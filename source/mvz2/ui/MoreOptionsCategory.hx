// Ported from: Assets/Scripts/View/Dialogs/Options/MoreOptionsCategory.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import mvz2.ui.OptionWidgets;
import mvz2.ui.TooltipHandler;
import pvzengine.NamespaceID;
import unity.GameObject;
import unity.UnityObject;
import unity.tmpro.TextMeshProUGUI;
import mvz2.ui.OptionWidgets.OptionWidgetsViewData;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class MoreOptionsCategory extends unity.MonoBehaviour implements IOptionsDialogElement
{
	public function UpdateOptions(viewData:MoreOptionsCategoryViewData):Void
	{
		label.text = viewData.label;
		list.updateList(viewData.widgets.length,
			function(i:Int, obj:GameObject)
			{
				var data = viewData.widgets[i];
				var widgets = obj.GetComponent(OptionWidgets);
				widgets.UpdateWidgets(data);

				var tooltipHander = obj.GetComponent(TooltipHandler);
				tooltipHander.text = data.tooltipText;
				tooltipHander.context = data.tooltipContext;
			},
			function(obj:GameObject)
			{
				var widgets = obj.GetComponent(OptionWidgets);
				widgets.OnToggleValueChanged.add(OnToggleValueChangedCallback);
				widgets.OnSliderValueChanged.add(OnSliderValueChangedCallback);
				widgets.OnSliderEnd.add(OnSliderEndCallback);
				widgets.OnDropdownValueChanged.add(OnDropdownValueChangedCallback);
				widgets.OnButtonClicked.add(OnButtonClickedCallback);

				var tooltipHander = obj.GetComponent(TooltipHandler);
				tooltipHander.OnPointerEnterSignal.add(OnTooltipShowCallback);
				tooltipHander.OnPointerExitSignal.add(OnTooltipHideCallback);
			},
			function(obj:GameObject)
			{
				var widgets = obj.GetComponent(OptionWidgets);
				widgets.OnToggleValueChanged.remove(OnToggleValueChangedCallback);
				widgets.OnSliderValueChanged.remove(OnSliderValueChangedCallback);
				widgets.OnSliderEnd.remove(OnSliderEndCallback);
				widgets.OnDropdownValueChanged.remove(OnDropdownValueChangedCallback);
				widgets.OnButtonClicked.remove(OnButtonClickedCallback);

				var tooltipHander = obj.GetComponent(TooltipHandler);
				tooltipHander.OnPointerEnterSignal.remove(OnTooltipShowCallback);
				tooltipHander.OnPointerExitSignal.remove(OnTooltipHideCallback);
			});
	}
	public function GetWidgetsByID(id:NamespaceID):Null<OptionWidgets>
	{
		for (widgets in list.getElementsAs(OptionWidgets))
		{
			if (UnityObject.exists(widgets) && widgets.GetOptionID() == id)
				return widgets;
		}
		return null;
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
		OnButtonClicked.dispatch(widgets);
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
	public var OnButtonClicked:FlxTypedSignal<OptionWidgets->Void> = new FlxTypedSignal();
	public var OnTooltipShow:FlxTypedSignal<TooltipHandler->Void> = new FlxTypedSignal();
	public var OnTooltipHide:FlxTypedSignal<TooltipHandler->Void> = new FlxTypedSignal();

	@:serializeField
	private var label:TextMeshProUGUI;
	@:serializeField
	private var list:ElementList;
}

// C# 中为 MVZ2.UI 的 MoreOptionsCategoryViewData 结构体。
class MoreOptionsCategoryViewData
{
	public var label:String;
	public var widgets:Array<OptionWidgetsViewData>;

	// PORT-NOTE: C# 结构体初始化器 `new MoreOptionsCategoryViewData { field = value }` 在 Haxe 中写作 `new MoreOptionsCategoryViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new MoreOptionsCategoryViewData()`。
	public function new(?data:{?label:String, ?widgets:Array<OptionWidgetsViewData>})
	{
		if (data == null)
			return;
		if (data.label != null) label = data.label;
		if (data.widgets != null) widgets = data.widgets;
	}
}
