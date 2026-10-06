// Ported from: Assets/Scripts/View/Level/Artifact/ArtifactItemUI.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.models.Model;
import mvz2.ui.ITooltipAnchor;
import mvz2.ui.ITooltipTarget;
import mvz2.ui.TooltipAnchor;
import unity.Animator;
import unity.Sprite;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.ui.Image;
import unity.tmpro.TextMeshProUGUI;
import unity.MonoBehaviour;
import mvz2.models.Model.SerializableAnimator;
import unity.eventsystems.IEventSystemHandler.IPointerEnterHandler;
import unity.eventsystems.IEventSystemHandler.IPointerExitHandler;
import flixel.addons.ui.Anchor;
import flixel.util.FlxSignal;

class ArtifactItemUI extends unity.MonoBehaviour implements ITooltipTarget implements IPointerEnterHandler implements IPointerExitHandler
{
	public function SetGlowing(glowing:Bool):Void
	{
		if (!animator.gameObject.activeInHierarchy)
			return;
		animator.SetBool("Glowing", glowing);
	}
	public function Shine():Void
	{
		if (!animator.gameObject.activeInHierarchy)
			return;
		animator.SetTrigger("Shine");
	}
	public function SetGrayscale(grayscale:Bool):Void
	{
		if (!animator.gameObject.activeInHierarchy)
			return;
		animator.SetBool("Grayscale", grayscale);
	}
	public function SetIcon(sprite:Null<Sprite>):Void
	{
		for (icon in iconImages)
		{
			icon.sprite = sprite;
			icon.enabled = icon.sprite != null;
		}
	}
	public function SetNumber(number:String):Void
	{
		numText.text = number;
	}
	public function UpdateAnimator(deltaTime:Float):Void
	{
		if (!animator.gameObject.activeInHierarchy)
			return;
		animator.enabled = false;
		animator.Update(deltaTime);
	}
	public function GetSerializableAnimator():SerializableAnimator
	{
		return new SerializableAnimator(animator);
	}
	public function LoadFromSerializableAnimator(seri:SerializableAnimator):Void
	{
		seri.Deserialize(animator);
	}
	public function OnPointerEnter(eventData:PointerEventData):Void
	{
		OnPointerEnterSignal.dispatch(this);
	}
	public function OnPointerExit(eventData:PointerEventData):Void
	{
		OnPointerExitSignal.dispatch(this);
	}
	// PORT-NOTE: C# 的事件与接口方法同名，Haxe 中字段与方法不能同名，事件字段加 Signal 后缀。
	public var OnPointerEnterSignal:FlxTypedSignal<ArtifactItemUI->Void> = new FlxTypedSignal();
	public var OnPointerExitSignal:FlxTypedSignal<ArtifactItemUI->Void> = new FlxTypedSignal();

	@:serializeField
	private var animator:Animator;
	@:serializeField
	private var iconImages:Array<Image>;
	@:serializeField
	private var numText:TextMeshProUGUI;
	@:serializeField
	private var tooltipAnchor:TooltipAnchor;
	public var Anchor(get, never):Null<ITooltipAnchor>;
	function get_Anchor():Null<ITooltipAnchor> return tooltipAnchor;
}
