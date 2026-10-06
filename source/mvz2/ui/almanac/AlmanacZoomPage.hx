// Ported from: Assets/Scripts/View/Almanac/AlmanacZoomPage.cs
package mvz2.ui.almanac;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.PanZoomController;
import unity.Sprite;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import unity.ui.Image;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class AlmanacZoomPage extends unity.MonoBehaviour
{
	public function Display():Void
	{
		gameObject.SetActive(true);
		panZoomController.ResetView();
	}
	public function Hide():Void
	{
		gameObject.SetActive(false);
	}
	public function SetSprite(sprite:Sprite):Void
	{
		image.sprite = sprite;
	}
	public function SetZoomHintText(text:String):Void
	{
		hintText.text = text;
	}
	public function SetPageButtonActive(active:Bool):Void
	{
		prevButton.gameObject.SetActive(active);
		nextButton.gameObject.SetActive(active);
	}
	private function Awake():Void
	{
		returnButton.onClick.AddListener(() -> OnReturnClick.dispatch());
		prevButton.onClick.AddListener(() -> OnPageButtonClick.dispatch(false));
		nextButton.onClick.AddListener(() -> OnPageButtonClick.dispatch(true));
	}
	public var OnReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnPageButtonClick:FlxTypedSignal<Bool->Void> = new FlxTypedSignal();
	@:serializeField
	private var hintText:TextMeshProUGUI;
	@:serializeField
	private var image:Image;
	@:serializeField
	private var panZoomController:PanZoomController;
	@:serializeField
	private var prevButton:Button;
	@:serializeField
	private var nextButton:Button;
	@:serializeField
	private var returnButton:Button;
}
