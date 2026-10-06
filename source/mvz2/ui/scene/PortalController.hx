// Ported from: Assets/Scripts/View/Scene/PortalController.cs
package mvz2.ui.scene;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.FloatFader;
import unity.Animator;
import unity.ui.Image;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class PortalController extends unity.MonoBehaviour
{
	public function SetAlpha(value:Float):Void
	{
		fader.Value = value;
	}
	public function StartFade(target:Float, duration:Float):Void
	{
		fader.StartFade(target, duration);
	}
	private function Awake():Void
	{
		fader.OnValueChanged.add(OnValueChangedCallback);
		fader.OnFadeFinished.add(OnFadeFinishedCallback);
	}
	private function Update():Void
	{
		raycastBlocker.raycastTarget = fader.EndValue > fader.StartValue || fader.Value > 0.85;
	}
	private function OnValueChangedCallback(value:Float):Void
	{
		animator.SetFloat("Blend", value);
	}
	private function OnFadeFinishedCallback(value:Float):Void
	{
		OnFadeFinished.dispatch(value);
	}
	public var OnFadeFinished:FlxTypedSignal<Float->Void> = new FlxTypedSignal();
	@:serializeField
	private var animator:Animator;
	@:serializeField
	private var raycastBlocker:Image;
	@:serializeField
	private var fader:FloatFader;
}
