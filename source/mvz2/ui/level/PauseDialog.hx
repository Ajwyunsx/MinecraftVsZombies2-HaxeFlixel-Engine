// Ported from: Assets/Scripts/View/Level/PauseDialog.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.Sprite;
import unity.ui.Button;
import unity.ui.Image;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class PauseDialog extends unity.MonoBehaviour
{
	public function SetPausedImage(sprite:Sprite):Void
	{
		pausedImage.sprite = sprite;
	}
	function Awake():Void
	{
		resumeButton.onClick.AddListener(() -> OnResumeClicked.dispatch());
	}
	public var OnResumeClicked:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	@:serializeField
	private var pausedImage:Image;
	@:serializeField
	private var resumeButton:Button;
}
