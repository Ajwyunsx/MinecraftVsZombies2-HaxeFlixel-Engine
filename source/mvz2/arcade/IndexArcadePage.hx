// Ported from: Assets/Scripts/View/Arcade/IndexArcadePage.cs
package mvz2.arcade;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.arcade.ArcadeCategoryItem;
import unity.ui.Button;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class IndexArcadePage extends unity.MonoBehaviour
{
	public function SetActive(active:Bool):Void
	{
		gameObject.SetActive(active);
	}
	private function Awake():Void
	{
		minigameItem.OnClick.add(item -> OnButtonClick.dispatch(ButtonType.Minigame));
		puzzleItem.OnClick.add(item -> OnButtonClick.dispatch(ButtonType.Puzzle));
		returnButton.onClick.AddListener(() -> OnReturnClick.dispatch());
	}
	public var OnReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnButtonClick:FlxTypedSignal<ButtonType->Void> = new FlxTypedSignal();
	@:serializeField
	private var minigameItem:ArcadeCategoryItem;
	@:serializeField
	private var puzzleItem:ArcadeCategoryItem;
	@:serializeField
	private var returnButton:Button;
}

enum abstract ButtonType(Int)
{
	var Minigame = 0;
	var Puzzle = 1;
}
