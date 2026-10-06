// Ported from: Assets/Scripts/View/Level/PickaxeSlot.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ITooltipAnchor;
import mvz2.ui.ITooltipTarget;
import mvz2.ui.TooltipAnchor;
import unity.Animator;
import unity.Color;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.tmpro.TextMeshProUGUI;
import unity.eventsystems.IEventSystemHandler.IPointerDownHandler;
import unity.eventsystems.IEventSystemHandler.IPointerEnterHandler;
import unity.eventsystems.IEventSystemHandler.IPointerExitHandler;
import flixel.addons.ui.Anchor;
import flixel.util.FlxSignal;

class PickaxeSlot extends LevelUIUnit implements IPointerDownHandler implements IPointerExitHandler implements IPointerEnterHandler implements ITooltipTarget
{
	public function SetSelected(selected:Bool):Void
	{
		animator.SetBool("Selected", selected);
	}
	public function SetDisabled(selected:Bool):Void
	{
		animator.SetBool("Disabled", selected);
	}
	public function SetHotkeyText(hotkey:String):Void
	{
		if (hotkeyText != null)
			hotkeyText.text = hotkey;
	}
	public function SetNumberText(info:PickaxeNumberText):Void
	{
		numberText.gameObject.SetActive(info.show);
		numberText.text = info.text;
		numberText.color = info.color;
	}
	public function OnPointerDown(eventData:PointerEventData):Void
	{
		OnPointerDownSignal.dispatch(eventData);
	}
	public function OnPointerEnter(eventData:PointerEventData):Void
	{
		OnPointerEnterSignal.dispatch(eventData);
	}
	public function OnPointerExit(eventData:PointerEventData):Void
	{
		OnPointerExitSignal.dispatch(eventData);
	}

	// PORT-NOTE: C# 的事件与接口方法同名，Haxe 中字段与方法不能同名，事件字段加 Signal 后缀。
	public var OnPointerEnterSignal:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	public var OnPointerExitSignal:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	public var OnPointerDownSignal:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	public var Anchor(get, never):Null<ITooltipAnchor>;
	function get_Anchor():Null<ITooltipAnchor> return tooltipAnchor;
	@:serializeField
	private var animator:Animator;
	@:serializeField
	private var tooltipAnchor:TooltipAnchor;
	@:serializeField
	private var numberText:TextMeshProUGUI;
	@:serializeField
	private var hotkeyText:TextMeshProUGUI;
}

// C# 中为 MVZ2.UI.Level 的 PickaxeNumberText 结构体。
class PickaxeNumberText
{
	public var show:Bool;
	public var text:String;
	public var color:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 abstract-over-class 的 null 解引用

	public function new(show:Bool, text:String, color:Color)
	{
		this.show = show;
		this.text = text;
		this.color = color;
	}
}
