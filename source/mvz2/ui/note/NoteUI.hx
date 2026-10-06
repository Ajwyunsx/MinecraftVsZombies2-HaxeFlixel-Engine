// Ported from: Assets/Scripts/View/Note/NoteUI.cs
package mvz2.ui.note;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.TextButton;
import unity.GameObject;
import unity.Sprite;
import unity.ui.Button;
import unity.ui.Image;
import unity.MonoBehaviour;
import unity.ui.Text;
import flixel.util.FlxSignal;

class NoteUI extends unity.MonoBehaviour
{
	public function SetNoteSprite(sprite:Null<Sprite>):Void
	{
		noteImage.sprite = sprite;
	}
	public function SetBackground(sprite:Null<Sprite>):Void
	{
		backgroundImage.sprite = sprite;
	}
	public function SetButtonText(text:String):Void
	{
		button.Text.text = text;
	}
	public function SetButtonInteractable(interactable:Bool):Void
	{
		button.Button.interactable = interactable;
	}
	public function SetCanFlip(flip:Bool):Void
	{
		flipObj.SetActive(flip);
	}
	public function SetFlipAtLeft(left:Bool):Void
	{
		flipButtonLeft.gameObject.SetActive(left);
		flipButtonRight.gameObject.SetActive(!left);
	}
	function Awake():Void
	{
		button.Button.onClick.AddListener(OnButtonClickCallback);
		flipButtonLeft.onClick.AddListener(OnNoteFlipClickCallback);
		flipButtonRight.onClick.AddListener(OnNoteFlipClickCallback);
	}
	private function OnNoteFlipClickCallback():Void
	{
		OnNoteFlipClick.dispatch();
	}
	private function OnButtonClickCallback():Void
	{
		OnButtonClick.dispatch();
	}
	public var OnButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnNoteFlipClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	// #region 属性字段
	@:serializeField
	private var noteImage:Image;
	@:serializeField
	private var backgroundImage:Image;
	@:serializeField
	private var flipObj:GameObject;
	@:serializeField
	private var flipButtonLeft:Button;
	@:serializeField
	private var flipButtonRight:Button;
	@:serializeField
	private var button:TextButton;
	// #endregion
}
