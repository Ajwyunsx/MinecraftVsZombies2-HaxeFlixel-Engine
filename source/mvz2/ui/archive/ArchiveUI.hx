// Ported from: Assets/Scripts/View/Archive/ArchiveUI.cs
package mvz2.ui.archive;

import mvz2.ui.archive.ArchiveTagItem;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.archive.DetailsArchivePage;
import mvz2.ui.archive.IndexArchivePage;
import mvz2.ui.archive.SimulationArchivePage;
import unity.Sprite;
import unity.Vector3;
import unity.MonoBehaviour;
import mvz2.ui.archive.ArchiveTagItem.ArchiveTagViewData;
import mvz2.ui.archive.DetailsArchivePage.ArchiveDetailsViewData;
import flixel.util.FlxSignal;

class ArchiveUI extends unity.MonoBehaviour
{
	public function DisplayPage(page:Page):Void
	{
		indexUI.SetActive(page == Page.Index);
		details.SetActive(page == Page.Details);
		simulation.SetActive(page == Page.Simulation);
	}
	public function SetIndexSearch(content:String):Void
	{
		indexUI.SetSearch(content);
	}
	public function SetIndexTags(tags:Array<ArchiveTagViewData>):Void
	{
		indexUI.UpdateTags(tags);
	}
	public function SetIndexTalks(talks:Array<String>):Void
	{
		indexUI.UpdateTalks(talks);
	}
	public function UpdateDetails(viewData:ArchiveDetailsViewData):Void
	{
		details.UpdateDetails(viewData);
	}
	public function SetSimulationBackground(background:Null<Sprite>):Void
	{
		simulation.SetBackground(background);
	}
	public function SetShake(shake:Vector3):Void
	{
		simulation.SetShake(shake);
	}
	private function Awake():Void
	{
		indexUI.OnReturnClick.add(() -> OnIndexReturnClick.dispatch());
		indexUI.OnSearchEndEdit.add(value -> OnSearchEndEdit.dispatch(value));
		indexUI.OnTagValueChanged.add((index, value) -> OnTalkTagValueChanged.dispatch(index, value));
		indexUI.OnTalkClick.add(value -> OnTalkEntryClick.dispatch(value));

		details.OnReturnClick.add(() -> OnDetailsReturnClick.dispatch());
		details.OnPlayClick.add(() -> OnDetailsPlayClick.dispatch());
	}
	public var OnIndexReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnSearchEndEdit:FlxTypedSignal<String->Void> = new FlxTypedSignal();
	public var OnTalkTagValueChanged:FlxTypedSignal<Int->Bool->Void> = new FlxTypedSignal();
	public var OnTalkEntryClick:FlxTypedSignal<Int->Void> = new FlxTypedSignal();

	public var OnDetailsReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnDetailsPlayClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();

	@:serializeField
	private var indexUI:IndexArchivePage;
	@:serializeField
	private var details:DetailsArchivePage;
	@:serializeField
	private var simulation:SimulationArchivePage;
}

enum abstract Page(Int)
{
	var Index = 0;
	var Details = 1;
	var Simulation = 2;
}
