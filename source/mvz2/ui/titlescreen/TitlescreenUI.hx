// Ported from: Assets/Scripts/View/TitleScreen/TitlescreenUI.cs
package mvz2.ui.titlescreen;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.LanguageDialog;
import unity.GameObject;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import unity.ui.Image;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class TitlescreenUI extends unity.MonoBehaviour
{
	public function SetVersionText(text:String):Void
	{
		versionText.text = text;
	}
	public function SetLoadingProgress(value:Float):Void
	{
		buttonFillImage.fillAmount = value;
	}
	public function SetLoadingText(text:String):Void
	{
		buttonText.text = text;
	}
	public function ShowLanguageDialog(languages:Array<String>):Void
	{
		languageDialog.SetLanguages(languages);
		languageDialogObj.SetActive(true);
	}
	public function HideLanguageDialog():Void
	{
		languageDialogObj.SetActive(false);
	}
	public function SetButtonInteractable(interactable:Bool):Void
	{
		button.interactable = interactable;
	}
	private function Awake():Void
	{
		button.onClick.AddListener(() -> OnButtonClick.dispatch());
		languageDialog.OnConfirm.add(i -> OnLanguageDialogConfirmed.dispatch(i));
	}
	public var OnButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnLanguageDialogConfirmed:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	// #region 属性字段
	@:serializeField
	private var button:Button;
	@:serializeField
	private var buttonFillImage:Image;
	@:serializeField
	private var languageDialog:LanguageDialog;
	@:serializeField
	private var languageDialogObj:GameObject;
	@:serializeField
	private var buttonText:TextMeshProUGUI;
	@:serializeField
	private var versionText:TextMeshProUGUI;
	// #endregion
}
