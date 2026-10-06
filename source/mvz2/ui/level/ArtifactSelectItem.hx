// Ported from: Assets/Scripts/View/Level/Artifact/ArtifactSelectItem.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ITooltipAnchor;
import mvz2.ui.ITooltipTarget;
import mvz2.ui.TooltipAnchor;
import unity.GameObject;
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

class ArtifactSelectItem extends unity.MonoBehaviour implements ITooltipTarget implements IPointerEnterHandler implements IPointerExitHandler
{
	public function UpdateItem(viewData:ArtifactSelectItemViewData):Void
	{
		if (root != null) root.SetActive(!viewData.empty);
		if (!viewData.empty)
		{
			iconImage.sprite = viewData.icon;
			iconImage.enabled = iconImage.sprite != null;
			selectedObj.SetActive(viewData.selected);
			button.interactable = !viewData.disabled;
		}
	}
	function Awake():Void
	{
		button.onClick.AddListener(() -> OnClick.dispatch(this));
	}
	public function OnPointerEnter(eventData:PointerEventData):Void
	{
		OnPointerEnterSignal.dispatch(this);
	}
	public function OnPointerExit(eventData:PointerEventData):Void
	{
		OnPointerExitSignal.dispatch(this);
	}
	public var OnClick:FlxTypedSignal<ArtifactSelectItem->Void> = new FlxTypedSignal();
	// PORT-NOTE: C# 的事件与接口方法同名，Haxe 中字段与方法不能同名，事件字段加 Signal 后缀。
	public var OnPointerEnterSignal:FlxTypedSignal<ArtifactSelectItem->Void> = new FlxTypedSignal();
	public var OnPointerExitSignal:FlxTypedSignal<ArtifactSelectItem->Void> = new FlxTypedSignal();
	@:serializeField
	private var root:Null<GameObject>;
	@:serializeField
	private var iconImage:Image;
	@:serializeField
	private var selectedObj:GameObject;
	@:serializeField
	private var button:Button;
	@:serializeField
	private var tooltipAnchor:TooltipAnchor;
	public var Anchor(get, never):Null<ITooltipAnchor>;
	function get_Anchor():Null<ITooltipAnchor> return tooltipAnchor;
}

// C# 中为 MVZ2.UI.Level 的 ArtifactSelectItemViewData 结构体。
class ArtifactSelectItemViewData
{
	public var empty:Bool;
	public var icon:Null<Sprite>;
	public var selected:Bool;
	public var disabled:Bool;

	public function new() {}

	public static var Empty(get, never):ArtifactSelectItemViewData;
	static function get_Empty():ArtifactSelectItemViewData
	{
		var data = new ArtifactSelectItemViewData();
		data.empty = true;
		return data;
	}
}
