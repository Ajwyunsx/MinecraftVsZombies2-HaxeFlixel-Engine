// Ported from: Assets/Scripts/View/Archive/IndexArchivePage.cs
package mvz2.ui.archive;

import mvz2.ui.archive.ArchiveTagItem;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import unity.GameObject;
import unity.tmpro.TMP_InputField;
import unity.ui.Button;
import mvz2.ui.archive.ArchiveTagItem.ArchiveTagViewData;
import flixel.util.FlxSignal;

class IndexArchivePage extends ArchivePage
{
	public function SetSearch(value:String):Void
	{
		searchInputField.SetTextWithoutNotify(value);
	}
	public function UpdateTags(tags:Array<ArchiveTagViewData>):Void
	{
		tagsList.updateList(tags.length,
			function(i:Int, obj:GameObject)
			{
				var tagItem = obj.GetComponent(ArchiveTagItem);
				tagItem.UpdateTag(tags[i]);
			},
			function(obj:GameObject)
			{
				var tagItem = obj.GetComponent(ArchiveTagItem);
				tagItem.OnValueChanged.add(OnTagValueChangedCallback);
			},
			function(obj:GameObject)
			{
				var tagItem = obj.GetComponent(ArchiveTagItem);
				tagItem.OnValueChanged.remove(OnTagValueChangedCallback);
			});
	}
	public function UpdateTalks(talks:Array<String>):Void
	{
		talksList.updateList(talks.length,
			function(i:Int, obj:GameObject)
			{
				var item = obj.GetComponent(ArchiveTalkItem);
				item.UpdateName(talks[i]);
			},
			function(obj:GameObject)
			{
				var item = obj.GetComponent(ArchiveTalkItem);
				item.OnClick.add(OnTalkClickCallback);
			},
			function(obj:GameObject)
			{
				var item = obj.GetComponent(ArchiveTalkItem);
				item.OnClick.remove(OnTalkClickCallback);
			});
	}
	private function Awake():Void
	{
		searchInputField.onEndEdit.AddListener(value -> OnSearchEndEdit.dispatch(value));
		returnButton.onClick.AddListener(() -> OnReturnClick.dispatch());
	}
	private function OnTagValueChangedCallback(item:ArchiveTagItem, value:Bool):Void
	{
		OnTagValueChanged.dispatch(tagsList.indexOfComponent(item), value);
	}
	private function OnTalkClickCallback(item:ArchiveTalkItem):Void
	{
		OnTalkClick.dispatch(talksList.indexOfComponent(item));
	}
	public var OnTagValueChanged:FlxTypedSignal<Int->Bool->Void> = new FlxTypedSignal();
	public var OnTalkClick:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnSearchEndEdit:FlxTypedSignal<String->Void> = new FlxTypedSignal();
	public var OnReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	@:serializeField
	private var returnButton:Button;
	@:serializeField
	private var searchInputField:TMP_InputField;
	@:serializeField
	private var tagsList:ElementList;
	@:serializeField
	private var talksList:ElementList;
}
