// Ported from: Assets/Scripts/View/Level/StarshardPanel.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementListUI;
import unity.Animator;
import unity.RectTransform;
import unity.Sprite;
import unity.eventsystems.PointerEventData;
import unity.tmpro.TextMeshProUGUI;
import flixel.util.FlxSignal;

class StarshardPanel extends LevelUIUnit
{
	public function SetIconSprite(sprite:Null<Sprite>):Void
	{
		icon.SetSprite(sprite);
	}
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
	public function SetPoints(count:Int, maxCount:Int):Void
	{
		pointsList.updateList(maxCount,
			function(i:Int, rect:RectTransform)
			{
				var point = rect.GetComponent(StarshardPanelPoint);
				point.SetHighlight(i < count);
			});
	}
	function Awake():Void
	{
		// PORT-NOTE: StarshardPanelIcon 的事件字段带 Signal 后缀（与接口方法同名冲突），此处同步使用 OnPointerDownSignal。
		icon.OnPointerDownSignal.add((data) -> OnPointerDownSignal.dispatch(data));
	}
	// PORT-NOTE: 同 StarshardPanelIcon，事件字段加 Signal 后缀以便与接口方法区分（调用方 LevelUIPreset 亦用 OnPointerDownSignal）。
	public var OnPointerDownSignal:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	public var Icon(get, never):StarshardPanelIcon;
	function get_Icon():StarshardPanelIcon return icon;
	@:serializeField
	private var animator:Animator;
	@:serializeField
	private var icon:StarshardPanelIcon;
	@:serializeField
	private var pointsList:ElementListUI;
	@:serializeField
	private var hotkeyText:TextMeshProUGUI;
}
