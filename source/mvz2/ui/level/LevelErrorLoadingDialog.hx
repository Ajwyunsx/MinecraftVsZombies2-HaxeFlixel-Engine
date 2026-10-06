// Ported from: Assets/Scripts/View/Level/LevelErrorLoadingDialog.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.CanvasGroup;
import unity.ui.Button;
import unity.tmpro.TextMeshProUGUI;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class LevelErrorLoadingDialog extends unity.MonoBehaviour
{
	public function SetInteractable(interactable:Bool):Void
	{
		canvasGroup.interactable = interactable;
	}
	public function SetDescription(text:String):Void
	{
		descriptionText.text = text;
	}
	function Awake():Void
	{
		restartButton.onClick.AddListener(() -> OnButtonClicked.dispatch(true));
		exitButton.onClick.AddListener(() -> OnButtonClicked.dispatch(false));
	}
	public var OnButtonClicked:FlxTypedSignal<Bool->Void> = new FlxTypedSignal();
	@:serializeField
	private var canvasGroup:CanvasGroup;
	@:serializeField
	private var descriptionText:TextMeshProUGUI;
	@:serializeField
	private var restartButton:Button;
	@:serializeField
	private var exitButton:Button;
}
