// Ported from: Assets/Scripts/View/Scene/MainSceneUI.cs
package mvz2.ui.scene;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ColorFader;
import mvz2.ui.CustomDialog;
import mvz2.ui.Tooltip;
import unity.Color;
import unity.ui.Image;
import unity.MonoBehaviour;
import mvz2.ui.Tooltip.TooltipContent;
import mvz2.ui.Tooltip.TooltipPosition;
import flixel.util.FlxSignal;

class MainSceneUI extends unity.MonoBehaviour
{
	public function SetScreenCoverColor(value:Color):Void
	{
		screenCoverFader.Value = value;
	}
	public function FadeScreenCoverColor(target:Color, duration:Float):Void
	{
		screenCoverFader.StartFade(target, duration);
	}
	public function ShowDialog(title:String, desc:String, options:Array<String>, ?onSelect:Int->Void = null):Void
	{
		ShowDialogTask(title, desc, options, null, onSelect);
	}
	public function ShowDialogTask(title:String, desc:String, options:Array<String>, ?onSelect:Int->unity.Task = null,
		?postSelect:Int->Void = null):Void
	{
		dialog.gameObject.SetActive(true);
		dialog.SetDialog(title, desc, options, function(i:Int)
		{
			// PORT-NOTE: C# 的 `await task` 在 Haxe 中映射为同步读取 task.awaitResult()。
			if (onSelect != null)
			{
				var task = onSelect(i);
				dialog.SetInteractable(false);
				task.awaitResult();
				dialog.SetInteractable(true);
			}
			dialog.gameObject.SetActive(false);
			if (postSelect != null)
			{
				postSelect(i);
			}
		});
		dialog.ResetPosition();
	}
	public function HasDialog():Bool
	{
		return dialog.gameObject.activeSelf;
	}

	// #region 工具提示
	public function ShowTooltip():Void
	{
		tooltip.Show();
	}
	public function HideTooltip():Void
	{
		tooltip.Hide();
	}
	public function SetTooltipPosition(viewData:TooltipPosition):Void
	{
		tooltip.SetPosition(viewData);
	}
	public function SetTooltipContent(viewData:TooltipContent):Void
	{
		tooltip.SetContent(viewData);
	}
	// #endregion

	public function SetDebugIconActive(active:Bool):Void
	{
		if (debugConsoleIcon.gameObject.activeSelf != active)
			debugConsoleIcon.gameObject.SetActive(active);
	}
	private function Awake():Void
	{
		screenCoverFader.OnValueChanged.add(OnBlackscreenFaderValueChangedCallback);
		debugConsoleIcon.OnClick.add(icon -> OnDebugIconClick.dispatch(icon));
	}
	private function OnBlackscreenFaderValueChangedCallback(value:Color):Void
	{
		blackscreenImage.color = value;
		blackscreenImage.raycastTarget = value.a > 0;
	}
	public var OnDebugIconClick:FlxTypedSignal<DebugConsoleIcon->Void> = new FlxTypedSignal();
	@:serializeField
	private var tooltip:Tooltip;
	@:serializeField
	private var dialog:CustomDialog;
	@:serializeField
	private var blackscreenImage:Image;
	@:serializeField
	private var screenCoverFader:ColorFader;
	@:serializeField
	private var debugConsoleIcon:DebugConsoleIcon;
}
