// Ported from: Assets/Scripts/View/Map/MapButton.cs
package mvz2.ui.map;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.Animator;
import unity.Color;
import unity.GameObject;
import unity.Sprite;
import unity.SpriteRenderer;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.tmpro.TextMeshPro;
import unity.ui.Selectable;
import unity.eventsystems.IEventSystemHandler.IPointerClickHandler;
import unity.eventsystems.IEventSystemHandler.IPointerDownHandler;
import unity.eventsystems.IEventSystemHandler.IPointerEnterHandler;
import unity.eventsystems.IEventSystemHandler.IPointerExitHandler;
import unity.eventsystems.IEventSystemHandler.IPointerUpHandler;
import flixel.util.FlxSignal;

class MapButton extends Selectable implements IPointerDownHandler implements IPointerClickHandler implements IPointerUpHandler implements IPointerEnterHandler implements IPointerExitHandler
{
	public function SetColor(color:Color):Void
	{
		buttonRenderer.color = color;
	}
	public function SetText(text:String):Void
	{
		buttonText.text = text;
	}
	public function SetBorderSprite(back:Null<Sprite>, bottom:Null<Sprite>, overlay:Null<Sprite>):Void
	{
		defaultBorder.SetActive(false);
		customBorder.SetActive(true);
		borderBack.sprite = back;
		borderBottom.sprite = bottom;
		borderOverlay.sprite = overlay;
	}
	public function SetBorderSpriteToDefault():Void
	{
		defaultBorder.SetActive(true);
		customBorder.SetActive(false);
	}
	// PORT-NOTE: unity.ui.Selectable shim 已定义同名空实现，Haxe 要求子类显式 override。
	public override function OnPointerDown(eventData:PointerEventData):Void
	{
		if (!IsInteractable())
			return;
		// Not left mouse nor first touch.
		if (eventData.pointerId != -1 && eventData.pointerId != 0)
			return;
		isPointerDown = true;
		UpdatePointer();
	}

	public function OnPointerClick(eventData:PointerEventData):Void
	{
		if (!IsInteractable())
			return;
		// Not left mouse nor first touch.
		if (eventData.pointerId != -1 && eventData.pointerId != 0)
			return;
		isPointerDown = false;
		UpdatePointer();
		OnClick.dispatch();
	}

	public override function OnPointerUp(eventData:PointerEventData):Void
	{
		// Not left mouse nor first touch.
		if (eventData.pointerId != -1 && eventData.pointerId != 0)
			return;
		isPointerDown = false;
		UpdatePointer();
	}

	public override function OnPointerEnter(eventData:PointerEventData):Void
	{
		isPointerEnter = true;
		UpdatePointer();
	}

	public override function OnPointerExit(eventData:PointerEventData):Void
	{
		isPointerEnter = false;
		UpdatePointer();
	}
	private function UpdatePointer():Void
	{
		// PORT-NOTE: C# 里 `animator` 由 `Selectable` 的 `[SerializeField] private Animator animator`
		// 提供（MapButton 自己没有声明该字段，只是读取它）。移植层 `unity.ui.Selectable.animator`
		// 是 `Dynamic` 且恒为 null，所以这里按 Unity 的同一语义**从同一 GameObject 上取 Animator 组件**
		// （prefab 里 MapButton 节点上确实挂着 Animator，见 Prefabs/Map/MapButton.json 节点 2）。
		// TODO-PORT: 这是「prefab 引用字段在 shim 基类上不可注入」的兜底；等
		// ScenePrefabInjector 能把 Selectable.animator 注入后再考虑改回纯字段读取。
		var animator = animatorComponent;
		if (animator == null && gameObject != null)
			animator = gameObject.GetComponent(Animator);
		if (animator != null)
			animator.SetBool("Pressed", isPointerEnter && isPointerDown);
	}
	public var OnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	private var isPointerEnter:Bool;
	private var isPointerDown:Bool;
	// PORT-NOTE: C# 字段 animator 隐藏了 UnityEngine.UI.Selectable.animator，Haxe 不允许同名重定义，故改名 animatorComponent。
	@:serializeField
	private var animatorComponent:Animator;
	@:serializeField
	private var buttonRenderer:SpriteRenderer;
	@:serializeField
	private var buttonText:TextMeshPro;
	@:serializeField
	private var defaultBorder:GameObject;
	@:serializeField
	private var customBorder:GameObject;
	@:serializeField
	private var borderBack:SpriteRenderer;
	@:serializeField
	private var borderBottom:SpriteRenderer;
	@:serializeField
	private var borderOverlay:SpriteRenderer;
}
