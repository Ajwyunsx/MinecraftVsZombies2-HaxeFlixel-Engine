// Ported from: Assets/Scripts/View/Level/LevelLoadedDialog.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.ui.Button;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class LevelLoadedDialog extends unity.MonoBehaviour
{
	function Awake():Void
	{
		resumeButton.onClick.AddListener(() -> OnButtonClicked.dispatch(ButtonType.Resume));
		restartButton.onClick.AddListener(() -> OnButtonClicked.dispatch(ButtonType.Restart));
		exitButton.onClick.AddListener(() -> OnButtonClicked.dispatch(ButtonType.Exit));
	}
	public var OnButtonClicked:FlxTypedSignal<ButtonType->Void> = new FlxTypedSignal();
	@:serializeField
	private var resumeButton:Button;
	@:serializeField
	private var restartButton:Button;
	@:serializeField
	private var exitButton:Button;
}

// C# 中为 LevelLoadedDialog 的嵌套枚举 ButtonType。
enum abstract ButtonType(Int)
{
	var Resume = 0;
	var Restart = 1;
	var Exit = 2;
}
