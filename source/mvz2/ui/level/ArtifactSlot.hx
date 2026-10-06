// Ported from: Assets/Scripts/View/Level/BlueprintChoose/ArtifactSlot.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ITooltipAnchor;
import mvz2.ui.ITooltipTarget;
import mvz2.ui.TooltipAnchor;
import unity.Sprite;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.ui.Button;
import unity.ui.Image;
import unity.MonoBehaviour;
import unity.eventsystems.IEventSystemHandler.IPointerEnterHandler;
import unity.eventsystems.IEventSystemHandler.IPointerExitHandler;
import flixel.addons.ui.Anchor;
import flixel.util.FlxSignal;

class ArtifactSlot extends unity.MonoBehaviour implements ITooltipTarget implements IPointerEnterHandler implements IPointerExitHandler
{
	public function ResetView():Void
	{
		SetSprite(null);
	}
	public function UpdateView(viewData:ArtifactViewData):Void
	{
		SetSprite(viewData.sprite);
	}
	function Awake():Void
	{
		button.onClick.AddListener(() -> OnClick.dispatch(this));
	}
	private function SetSprite(sprite:Null<Sprite>):Void
	{
		image.sprite = sprite;
		image.enabled = sprite != null;
	}
	public function OnPointerEnter(eventData:PointerEventData):Void
	{
		OnPointerEnterSignal.dispatch(this);
	}
	public function OnPointerExit(eventData:PointerEventData):Void
	{
		OnPointerExitSignal.dispatch(this);
	}
	public var OnClick:FlxTypedSignal<ArtifactSlot->Void> = new FlxTypedSignal();
	// PORT-NOTE: C# 的事件与接口方法同名，Haxe 中字段与方法不能同名，事件字段加 Signal 后缀。
	public var OnPointerEnterSignal:FlxTypedSignal<ArtifactSlot->Void> = new FlxTypedSignal();
	public var OnPointerExitSignal:FlxTypedSignal<ArtifactSlot->Void> = new FlxTypedSignal();
	@:serializeField
	var image:Image;
	@:serializeField
	var button:Button;
	@:serializeField
	var tooltipAnchor:TooltipAnchor;
	public var Anchor(get, never):Null<ITooltipAnchor>;
	function get_Anchor():Null<ITooltipAnchor> return tooltipAnchor;
}

// C# 中为 MVZ2.UI.Level 的 ArtifactViewData 结构体。
class ArtifactViewData
{
	public var sprite:Null<Sprite>;

	public function new() {}
}
