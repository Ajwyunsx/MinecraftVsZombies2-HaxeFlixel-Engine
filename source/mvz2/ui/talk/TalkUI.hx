// Ported from: Assets/Scripts/View/Talk/TalkUI.cs
package mvz2.ui.talk;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ColorFader;
import mvz2.ui.FloatFader;
import mvz2.ui.RaycastReceiver;
import mvz2.ui.talk.SpeechBubble;
import unity.CanvasGroup;
import unity.Color;
import unity.GameObject;
import unity.Sprite;
import unity.Transform;
import unity.Vector3;
import unity.eventsystems.PointerEventData;
import unity.ui.Button;
import unity.ui.Image;
import unity.MonoBehaviour;
import mvz2.ui.talk.SpeechBubble.SpeechBubbleDirection;
import flixel.util.FlxSignal;

class TalkUI extends unity.MonoBehaviour
{
	// #region 公有方法

	// #region 对话气泡
	public function SetSpeechBubbleShowing(value:Bool):Void
	{
		speechBubble.SetShowing(value);
	}
	public function SetSpeechBubbleText(text:String):Void
	{
		speechBubble.SetText(text);
	}
	public function SetSpeechBubbleDirection(direction:SpeechBubbleDirection):Void
	{
		speechBubble.SetDirection(direction);
	}
	public function ForceReshowSpeechBubble():Void
	{
		speechBubble.ForceReshow();
	}
	// #endregion
	public function SetSkipButtonActive(value:Bool):Void
	{
		skipButton.gameObject.SetActive(value);
	}
	public function SetBlockerActive(value:Bool):Void
	{
		blockerObject.SetActive(value);
	}
	public function SetRaycastReceiverActive(value:Bool):Void
	{
		raycastReceiver.gameObject.SetActive(value);
	}

	// #region 前景图
	public function SetForegroundSprite(sprite:Null<Sprite>):Void
	{
		foregroundImage.sprite = sprite;
	}
	public function SetForegroundAlpha(value:Float):Void
	{
		foregroundFader.Value = value;
	}
	public function GetForegroundAlpha():Float
	{
		return foregroundFader.Value;
	}
	public function StartForegroundFade(target:Float, duration:Float):Void
	{
		foregroundFader.StartFade(target, duration);
	}
	// #endregion

	// #region 前景色
	public function SetForecolor(value:Color):Void
	{
		forecolorFader.Value = value;
	}
	public function StartForecolorFade(target:Color, duration:Float):Void
	{
		forecolorFader.StartFade(target, duration);
	}
	// #endregion

	// #region 背景图
	public function SetBackgroundSprite(sprite:Null<Sprite>):Void
	{
		backgroundImage.sprite = sprite;
	}
	public function SetBackgroundAlpha(value:Float):Void
	{
		backgroundFader.Value = value;
	}
	public function GetBackgroundAlpha():Float
	{
		return backgroundFader.Value;
	}
	public function StartBackgroundFade(target:Float, duration:Float):Void
	{
		backgroundFader.StartFade(target, duration);
	}
	// #endregion

	// #region 背景色
	public function SetBackcolor(value:Color):Void
	{
		backcolorFader.Value = value;
	}
	public function StartBackcolorFade(target:Color, duration:Float):Void
	{
		backcolorFader.StartFade(target, duration);
	}
	// #endregion


	// #region 展示物品
	public function ShowTalkItem(sprite:Null<Sprite>):Void
	{
		talkItem.ForceShow();
		talkItem.SetShowing(true);
		talkItem.SetSprite(sprite);
	}
	public function HideTalkItem():Void
	{
		talkItem.SetShowing(false);
	}
	// #endregion

	public function SetShake(shake:Vector3):Void
	{
		for (root in shakeRoots)
		{
			if (root == null)
				continue;
			root.localPosition = shake;
		}
	}

	// #endregion

	// #region 私有方法

	// #region 生命周期
	private function Awake():Void
	{
		skipButton.gameObject.SetActive(false);
		blockerObject.SetActive(false);
		raycastReceiver.gameObject.SetActive(false);
		SetSkipButtonActive(false);

		skipButton.onClick.AddListener(() -> OnSkipClick.dispatch());
		raycastReceiver.OnPointerDownSignal.add(OnRaycastReceiverPointerDownCallback);
		foregroundFader.OnValueChanged.add(OnForegroundAlphaChangedCallback);
		forecolorFader.OnValueChanged.add(OnForegroundColorChangedCallback);
		backgroundFader.OnValueChanged.add(OnBackgroundAlphaChangedCallback);
		backcolorFader.OnValueChanged.add(OnBackgroundColorChangedCallback);
	}
	// #endregion

	// #region 事件回调
	private function OnRaycastReceiverPointerDownCallback(eventData:PointerEventData):Void
	{
		OnClick.dispatch();
	}
	private function OnForegroundAlphaChangedCallback(value:Float):Void
	{
		foregroundCanvasGroup.alpha = value;
	}
	private function OnForegroundColorChangedCallback(value:Color):Void
	{
		var color = forecolorImage.color;
		color.r = value.r;
		color.g = value.g;
		color.b = value.b;
		color.a = value.a;
		forecolorImage.color = color;
	}
	private function OnBackgroundAlphaChangedCallback(value:Float):Void
	{
		backgroundCanvasGroup.alpha = value;
	}
	private function OnBackgroundColorChangedCallback(value:Color):Void
	{
		var color = backcolorImage.color;
		color.r = value.r;
		color.g = value.g;
		color.b = value.b;
		color.a = value.a;
		backcolorImage.color = color;
	}
	// #endregion


	// #endregion

	// #region 事件
	public var OnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnSkipClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	// #endregion 动作

	// #region 属性字段
	@:serializeField
	private var talkItem:TalkItem;
	@:serializeField
	private var speechBubble:SpeechBubble;
	@:serializeField
	private var skipButton:Button;
	@:serializeField
	private var raycastReceiver:RaycastReceiver;
	@:serializeField
	private var blockerObject:GameObject;

	// [Header("Foreground")]
	@:serializeField
	private var foregroundCanvasGroup:CanvasGroup;
	@:serializeField
	private var foregroundImage:Image;
	@:serializeField
	private var foregroundFader:FloatFader;
	@:serializeField
	private var forecolorImage:Image;
	@:serializeField
	private var forecolorFader:ColorFader;

	// [Header("Background")]
	@:serializeField
	private var backgroundCanvasGroup:CanvasGroup;
	@:serializeField
	private var backgroundImage:Image;
	@:serializeField
	private var backgroundFader:FloatFader;
	@:serializeField
	private var backcolorImage:Image;
	@:serializeField
	private var backcolorFader:ColorFader;
	@:serializeField
	private var shakeRoots:Array<Transform>;
	// #endregion 属性
}
