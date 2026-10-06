// Ported from: Assets/Scripts/View/Mainmenu/MainmenuButton.cs
package mvz2.ui.mainmenu;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.CursorHandler;
import unity.Sprite;
import unity.SpriteRenderer;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.MonoBehaviour;
import unity.eventsystems.IEventSystemHandler.IPointerClickHandler;
import unity.eventsystems.IEventSystemHandler.IPointerEnterHandler;
import unity.eventsystems.IEventSystemHandler.IPointerExitHandler;
import flixel.util.FlxSignal;

// [RequireComponent(typeof(CursorHandler))]
class MainmenuButton extends unity.MonoBehaviour implements IPointerClickHandler implements IPointerEnterHandler implements IPointerExitHandler
{
	public function SetSprite(sprite:Sprite):Void
	{
		spriteRenderer.sprite = sprite;
	}

	private function Awake():Void
	{
		cursorHandler = GetComponent(CursorHandler);
	}
	private function OnEnable():Void
	{
		UpdateSprite();
	}
	private function OnDisable():Void
	{
		if (isHovered)
		{
			isHovered = false;
			UpdateSprite();
		}
	}
	public function OnPointerClick(eventData:PointerEventData):Void
	{
		if (Interactable)
			OnClick.dispatch();
	}

	public function OnPointerEnter(eventData:PointerEventData):Void
	{
		if (Interactable)
		{
			isHovered = true;
			UpdateSprite();
		}
	}

	public function OnPointerExit(eventData:PointerEventData):Void
	{
		if (isHovered)
		{
			isHovered = false;
			UpdateSprite();
		}
	}
	private function UpdateSprite():Void
	{
		OnUpdateSprite.dispatch(this);
	}
	public var OnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnUpdateSprite:FlxTypedSignal<MainmenuButton->Void> = new FlxTypedSignal();
	public var Interactable(get, set):Bool;
	function get_Interactable():Bool return interactable;
	function set_Interactable(value:Bool):Bool
	{
		interactable = value;
		cursorHandler.Interactable = value;
		UpdateSprite();
		return value;
	}
	public var IsHovered(get, never):Bool;
	function get_IsHovered():Bool return isHovered;
	public var NormalSprite(get, never):Sprite;
	function get_NormalSprite():Sprite return normalSprite;
	public var HoveredSprite(get, never):Sprite;
	function get_HoveredSprite():Sprite return hoveredSprite;
	public var DisabledSprite(get, never):Sprite;
	function get_DisabledSprite():Sprite return disabledSprite;

	private var isHovered:Bool;
	private var cursorHandler:CursorHandler;
	@:serializeField
	private var interactable:Bool = true;
	@:serializeField
	private var spriteRenderer:SpriteRenderer;
	@:serializeField
	private var normalSprite:Sprite;
	@:serializeField
	private var hoveredSprite:Sprite;
	@:serializeField
	private var disabledSprite:Sprite;
}
