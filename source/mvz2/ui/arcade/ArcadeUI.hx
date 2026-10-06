// Ported from: Assets/Scripts/View/Arcade/ArcadeUI.cs
package mvz2.ui.arcade;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.arcade.IndexArcadePage;
import mvz2.ui.arcade.ArcadeItemsPage;
import unity.CanvasGroup;
import mvz2.ui.arcade.ArcadeItem;
import mvz2.ui.arcade.IndexArcadePage.ButtonType;
import unity.MonoBehaviour;
import mvz2.ui.arcade.ArcadeItem.ArcadeItemViewData;
import flixel.util.FlxSignal;

class ArcadeUI extends unity.MonoBehaviour
{
	public function DisplayPage(page:ArcadePage):Void
	{
		indexUI.SetActive(page == ArcadePage.Index);
		minigamePage.SetActive(page == ArcadePage.Minigame);
		puzzlePage.SetActive(page == ArcadePage.Puzzle);
	}
	public function SetAllInteractable(interactable:Bool):Void
	{
		canvasGroup.interactable = interactable;
	}
	public function SetMinigameItems(items:Array<ArcadeItemViewData>):Void
	{
		minigamePage.SetItems(items);
	}
	public function SetPuzzleItems(items:Array<ArcadeItemViewData>):Void
	{
		puzzlePage.SetItems(items);
	}

	private function Awake():Void
	{
		indexUI.OnReturnClick.add(() -> OnIndexReturnClick.dispatch());
		indexUI.OnButtonClick.add(type -> OnIndexButtonClick.dispatch(type));
		minigamePage.OnEntryClick.add(index -> OnItemClick.dispatch(ArcadePage.Minigame, index));
		minigamePage.OnReturnClick.add(() -> OnPageReturnClick.dispatch(ArcadePage.Minigame));
		puzzlePage.OnEntryClick.add(index -> OnItemClick.dispatch(ArcadePage.Puzzle, index));
		puzzlePage.OnReturnClick.add(() -> OnPageReturnClick.dispatch(ArcadePage.Puzzle));
	}
	public var OnIndexReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnPageReturnClick:FlxTypedSignal<ArcadePage->Void> = new FlxTypedSignal();
	public var OnIndexButtonClick:FlxTypedSignal<ButtonType->Void> = new FlxTypedSignal();
	public var OnItemClick:FlxTypedSignal<ArcadePage->Int->Void> = new FlxTypedSignal();
	@:serializeField
	private var canvasGroup:CanvasGroup;
	@:serializeField
	private var indexUI:IndexArcadePage;
	@:serializeField
	private var minigamePage:ArcadeItemsPage;
	@:serializeField
	private var puzzlePage:ArcadeItemsPage;
}

enum abstract ArcadePage(Int)
{
	var Index = 0;
	var Minigame = 1;
	var Puzzle = 2;
}
