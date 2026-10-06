// Ported from: Assets/Scripts/View/Level/TriggerSlot.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ITooltipAnchor;
import mvz2.ui.ITooltipTarget;
import mvz2.ui.TooltipAnchor;
import unity.Animator;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.tmpro.TextMeshProUGUI;
import unity.eventsystems.IEventSystemHandler.IPointerDownHandler;
import unity.eventsystems.IEventSystemHandler.IPointerEnterHandler;
import unity.eventsystems.IEventSystemHandler.IPointerExitHandler;
import flixel.addons.ui.Anchor;
import flixel.util.FlxSignal;

class TriggerSlot extends LevelUIUnit implements IPointerEnterHandler implements IPointerExitHandler implements IPointerDownHandler implements ITooltipTarget
{
	public function SetSelected(selected:Bool):Void
	{
		// PORT-NOTE: C# 为 `animator.isActiveAndEnabled`（Animator 继承 Behaviour）。unity shim 的 Animator
		// 直接继承 Component，未定义 Behaviour.isActiveAndEnabled，故按 unity.Behaviour.get_isActiveAndEnabled
		// 的语义展开（enabled && gameObject.activeInHierarchy）。同 EntityController/LevelController 的处理。
		// TODO-PORT: 待 unity 域让 Animator 继承 unity.Behaviour 后改回属性访问。
		if (animator.enabled && animator.gameObject != null && animator.gameObject.activeInHierarchy)
			animator.SetBool("Selected", selected);
	}
	public function SetHotkeyText(hotkey:String):Void
	{
		if (hotkeyText != null)
			hotkeyText.text = hotkey;
	}
	public function OnPointerEnter(eventData:PointerEventData):Void
	{
		OnPointerEnterSignal.dispatch(eventData);
	}
	public function OnPointerExit(eventData:PointerEventData):Void
	{
		OnPointerExitSignal.dispatch(eventData);
	}
	public function OnPointerDown(eventData:PointerEventData):Void
	{
		OnPointerDownSignal.dispatch(eventData);
	}
	// PORT-NOTE: C# 的事件与接口方法同名，Haxe 中字段与方法不能同名，事件字段加 Signal 后缀。
	public var OnPointerEnterSignal:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	public var OnPointerExitSignal:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	public var OnPointerDownSignal:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	@:serializeField
	private var animator:Animator;
	@:serializeField
	private var tooltipAnchor:TooltipAnchor;
	@:serializeField
	private var hotkeyText:TextMeshProUGUI;
	public var Anchor(get, never):Null<ITooltipAnchor>;
	function get_Anchor():Null<ITooltipAnchor> return tooltipAnchor;
}
