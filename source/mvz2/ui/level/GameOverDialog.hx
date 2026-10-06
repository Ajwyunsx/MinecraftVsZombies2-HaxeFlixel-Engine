// Ported from: Assets/Scripts/View/Level/GameOverDialog.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.ui.Button;
import unity.tmpro.TextMeshProUGUI;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class GameOverDialog extends unity.MonoBehaviour
{
	public function SetMessage(message:String):Void
	{
		messageText.text = message;
	}
	public function SetInteractable(interactable:Bool):Void
	{
		retryButton.interactable = interactable;
		backButton.interactable = interactable;
	}
	function Awake():Void
	{
		retryButton.onClick.AddListener(() -> OnRetryButtonClicked.dispatch());
		backButton.onClick.AddListener(() -> OnBackButtonClicked.dispatch());
	}
	public var OnRetryButtonClicked:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnBackButtonClicked:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	@:serializeField
	private var messageText:TextMeshProUGUI;
	@:serializeField
	private var retryButton:Button;
	@:serializeField
	private var backButton:Button;
}
