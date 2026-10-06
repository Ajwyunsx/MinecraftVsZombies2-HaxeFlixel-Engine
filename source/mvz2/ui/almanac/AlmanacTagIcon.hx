// Ported from: Assets/Scripts/View/Almanac/AlmanacTagIcon.cs
package mvz2.ui.almanac;

import mvz2.ui.almanac.AlmanacTagIconLayer;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ITooltipAnchor;
import mvz2.ui.ITooltipTarget;
import mvz2.ui.TooltipAnchor;
import unity.Vector3;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.MonoBehaviour;
import mvz2.ui.almanac.AlmanacTagIconLayer.AlmanacTagIconLayerViewData;
import unity.eventsystems.IEventSystemHandler.IPointerDownHandler;
import unity.eventsystems.IEventSystemHandler.IPointerEnterHandler;
import unity.eventsystems.IEventSystemHandler.IPointerExitHandler;
import flixel.addons.ui.Anchor;
import flixel.util.FlxSignal;

class AlmanacTagIcon extends unity.MonoBehaviour implements ITooltipTarget implements IPointerEnterHandler implements IPointerExitHandler implements IPointerDownHandler
{
	public function UpdateContainer(viewData:AlmanacTagIconViewData):Void
	{
		UpdateBackground(viewData.background);
		UpdateMain(viewData.main);
		UpdateMark(viewData.mark);
	}
	public function SetScale(scale:Vector3):Void
	{
		transform.localScale = scale;
	}
	public function UpdateBackground(viewData:AlmanacTagIconLayerViewData):Void
	{
		backgroundLayer.UpdateView(viewData);
	}
	public function UpdateMain(viewData:AlmanacTagIconLayerViewData):Void
	{
		mainLayer.UpdateView(viewData);
	}
	public function UpdateMark(viewData:AlmanacTagIconLayerViewData):Void
	{
		markLayer.UpdateView(viewData);
	}
	public function OnPointerEnter(eventData:PointerEventData):Void
	{
		OnPointerEnterSignal.dispatch(this);
	}
	public function OnPointerExit(eventData:PointerEventData):Void
	{
		OnPointerExitSignal.dispatch(this);
	}
	public function OnPointerDown(eventData:PointerEventData):Void
	{
		OnPointerDownSignal.dispatch(this);
	}
	public var Anchor(get, never):Null<ITooltipAnchor>;
	function get_Anchor():Null<ITooltipAnchor> return tooltipAnchor;
	// PORT-NOTE: C# 的事件与接口方法同名（OnPointerEnter/OnPointerExit/OnPointerDown），Haxe 中字段与方法不能同名，事件字段加 Signal 后缀。
	public var OnPointerEnterSignal:FlxTypedSignal<AlmanacTagIcon->Void> = new FlxTypedSignal();
	public var OnPointerExitSignal:FlxTypedSignal<AlmanacTagIcon->Void> = new FlxTypedSignal();
	public var OnPointerDownSignal:FlxTypedSignal<AlmanacTagIcon->Void> = new FlxTypedSignal();
	@:serializeField
	private var tooltipAnchor:TooltipAnchor;
	@:serializeField
	private var backgroundLayer:AlmanacTagIconLayer;
	@:serializeField
	private var mainLayer:AlmanacTagIconLayer;
	@:serializeField
	private var markLayer:AlmanacTagIconLayer;
}

// C# 中为 MVZ2.UI.Almanac 的 AlmanacTagIconViewData 结构体。
class AlmanacTagIconViewData
{
	public var background:AlmanacTagIconLayerViewData;
	public var main:AlmanacTagIconLayerViewData;
	public var mark:AlmanacTagIconLayerViewData;

	// PORT-NOTE: C# 结构体初始化器 `new AlmanacTagIconViewData { field = value }` 在 Haxe 中写作 `new AlmanacTagIconViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new AlmanacTagIconViewData()`。
	public function new(?data:{?background:AlmanacTagIconLayerViewData, ?main:AlmanacTagIconLayerViewData, ?mark:AlmanacTagIconLayerViewData})
	{
		if (data == null)
			return;
		if (data.background != null) background = data.background;
		if (data.main != null) main = data.main;
		if (data.mark != null) mark = data.mark;
	}
}
