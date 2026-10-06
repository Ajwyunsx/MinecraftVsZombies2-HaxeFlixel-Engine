// Ported from: Assets/Scripts/View/Blueprint/Blueprint.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.models.UIModel;
import mvz2.view.level.LevelPointerInteractionHandler;
import mvz2logic.inputs.PointerInteraction;
import unity.GameObject;
import unity.Mathf;
import unity.Sprite;
import unity.eventsystems.PointerEventData;
import unity.ui.Image;
import unity.tmpro.TextMeshProUGUI;
import mvz2.models.Model;
import unity.MonoBehaviour;
import flixel.addons.ui.Anchor;
import flixel.util.FlxSignal;

class Blueprint extends unity.MonoBehaviour implements ITooltipTarget
{
	public function UpdateView(viewData:BlueprintViewData):Void
	{
		SetEmpty(viewData.empty);
		SetCost(viewData.cost);
		SetTriggerActive(viewData.triggerActive);

		// Styles.
		if (standaloneBackground != null) standaloneBackground.sprite = viewData.standaloneBackground;
		if (mobileBackground != null) mobileBackground.sprite = viewData.mobileBackground;
		if (mobileFrameTop != null) mobileFrameTop.sprite = viewData.mobileFrameTop;
		if (mobileFrameBottom != null) mobileFrameBottom.sprite = viewData.mobileFrameBottom;

		var icon = viewData.icon;
		iconImage.enabled = icon != null && !viewData.iconGrayscale;
		iconImage.sprite = icon;
		iconImageCommandBlock.enabled = icon != null && viewData.iconGrayscale;
		iconImageCommandBlock.sprite = icon;
	}
	public function SetEmpty(empty:Bool):Void
	{
		emptyObj.SetActive(empty);
		rootObj.SetActive(!empty);
	}
	public function SetCost(cost:String):Void
	{
		costText.text = cost;
	}
	public function SetTriggerActive(active:Bool):Void
	{
		triggerCostObject.SetActive(active);
	}
	public function SetHotkeyText(hotkey:String):Void
	{
		if (hotkeyText != null)
			hotkeyText.text = hotkey;
	}
	public function SetRecharge(charge:Float):Void
	{
		rechargeImage.fillAmount = charge;
	}
	public function RechargeFlash():Void
	{
		rechargeFlashAlpha = 1;
		UpdateRechargeFlash();
	}
	public function UpdateAnimation(deltaTime:Float):Void
	{
		rechargeFlashAlpha = Mathf.Clamp01(rechargeFlashAlpha - deltaTime / rechargeFlashTime);
		UpdateRechargeFlash();
	}
	public function SetDisabled(disabled:Bool):Void
	{
		disabledObject.SetActive(disabled);
	}
	public function SetSelected(selected:Bool):Void
	{
		selectedObject.SetActive(selected);
	}
	public function SetTwinkleAlpha(alpha:Float):Void
	{
		var color = twinkleImage.color;
		color.a = alpha;
		twinkleImage.color = color;
	}
	function Awake():Void
	{
		holdStreakHandler.OnPointerInteraction.add((_, d, i) -> CallPointerInteraction(d, i));
	}
	private function UpdateRechargeFlash():Void
	{
		var color = rechargeFlashImage.color;
		color.a = rechargeFlashAlpha;
		rechargeFlashImage.color = color;
	}
	private function CallPointerInteraction(eventData:PointerEventData, interaction:PointerInteraction):Void
	{
		OnPointerInteraction.dispatch(this, eventData, interaction);
		if (interaction == selectInteraction)
		{
			OnSelect.dispatch(this, eventData);
		}
	}
	public var OnPointerInteraction:FlxTypedSignal<Blueprint->PointerEventData->PointerInteraction->Void> = new FlxTypedSignal();
	public var OnSelect:FlxTypedSignal<Blueprint->PointerEventData->Void> = new FlxTypedSignal();
	public var Anchor(get, never):Null<ITooltipAnchor>;
	function get_Anchor():Null<ITooltipAnchor> return tooltipAnchor;
	public var Model(get, never):UIModel;
	function get_Model():UIModel return model;
	private var rechargeFlashAlpha:Float = 0;
	@:serializeField
	private var selectInteraction:PointerInteraction = PointerInteraction.Down;
	@:serializeField
	private var holdStreakHandler:LevelPointerInteractionHandler;
	@:serializeField
	private var emptyObj:GameObject;
	@:serializeField
	private var rootObj:GameObject;

	// [Header("Styles (Standalone)")]
	@:serializeField
	private var standaloneBackground:Image;

	// [Header("Styles (Mobile)")]
	@:serializeField
	private var mobileBackground:Image;
	@:serializeField
	private var mobileFrameTop:Image;
	@:serializeField
	private var mobileFrameBottom:Image;

	// [Header("Elements")]
	@:serializeField
	private var iconImage:Image;
	@:serializeField
	private var iconImageCommandBlock:Image;
	@:serializeField
	private var triggerCostObject:GameObject;
	@:serializeField
	private var costText:TextMeshProUGUI;

	// [Header("Overlays")]
	@:serializeField
	private var twinkleImage:Image;
	@:serializeField
	private var rechargeImage:Image;
	@:serializeField
	private var rechargeFlashImage:Image;
	@:serializeField
	private var rechargeFlashTime:Float = 0.5;
	@:serializeField
	private var selectedObject:GameObject;
	@:serializeField
	private var disabledObject:GameObject;
	@:serializeField
	private var hotkeyText:TextMeshProUGUI;

	// [Header("Miscs")]
	@:serializeField
	private var model:UIModel;
	@:serializeField
	private var tooltipAnchor:TooltipAnchor;
}

// C# 中为 MVZ2.UI 的 BlueprintViewData 结构体。
class BlueprintViewData
{
	public var empty:Bool;
	public var cost:String;
	public var icon:Null<Sprite>;
	public var triggerActive:Bool;
	public var iconGrayscale:Bool;

	// Styles.
	public var standaloneBackground:Null<Sprite>;
	public var mobileBackground:Null<Sprite>;
	public var mobileFrameTop:Null<Sprite>;
	public var mobileFrameBottom:Null<Sprite>;

	public function new() {}

	public static var Empty(get, never):BlueprintViewData;
	static function get_Empty():BlueprintViewData
	{
		var data = new BlueprintViewData();
		data.empty = true;
		return data;
	}
}
