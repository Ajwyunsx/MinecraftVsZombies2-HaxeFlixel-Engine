// Ported from: Assets/Scripts/View/MusicRoom/MusicRoomUI.cs
package mvz2.ui.musicroom;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import unity.GameObject;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import unity.ui.Slider;
import unity.MonoBehaviour;
import unity.UnityObject;
import pvzengine.base.UpdateList;
import flixel.util.FlxSignal;

class MusicRoomUI extends unity.MonoBehaviour
{
	public function UpdateList(items:Array<String>):Void
	{
		itemList.updateList(items.length,
			function(i:Int, obj:GameObject)
			{
				var item = obj.GetComponent(MusicRoomListItem);
				item.UpdateName(items[i]);
			},
			function(obj:GameObject)
			{
				var item = obj.GetComponent(MusicRoomListItem);
				item.OnClick.add(OnItemClickCallback);
			},
			function(obj:GameObject)
			{
				var item = obj.GetComponent(MusicRoomListItem);
				item.OnClick.remove(OnItemClickCallback);
			});
	}
	public function UpdateInformation(name:String, info:String, description:String, totalTime:String):Void
	{
		nameText.text = name;
		informationText.text = info;
		descriptionText.text = description;
		totalTimeText.text = totalTime;
	}
	public function SetPlaying(playing:Bool):Void
	{
		playButtonObj.SetActive(!playing);
		pauseButtonObj.SetActive(playing);
	}
	public function SetMusicTime(time:Float, currentTime:String):Void
	{
		barSlider.SetValueWithoutNotify(time);
		currentTimeText.text = currentTime;
	}
	public function GetMusicBarValue():Float
	{
		return barSlider.value;
	}
	public function SetSelectedItem(index:Int):Void
	{
		var count = itemList.Count;
		for (i in 0...count)
		{
			var item = itemList.getElementAs(i, MusicRoomListItem);
			if (unity.UnityObject.exists(item))
				item.SetSelected(index == i);
		}
	}
	public function SetTrackButtonVisible(value:Bool):Void
	{
		trackButtonRoot.SetActive(value);
	}
	public function SetTrackButtonStyle(sub:Bool):Void
	{
		mainTrackButton.gameObject.SetActive(!sub);
		subTrackButton.gameObject.SetActive(sub);
	}
	private function Awake():Void
	{
		returnButton.onClick.AddListener(() -> OnReturnClick.dispatch());
		playButton.onClick.AddListener(() -> OnPlayButtonClick.dispatch());
		pauseButton.onClick.AddListener(() -> OnPauseButtonClick.dispatch());
		barSlider.onValueChanged.AddListener(value -> OnMusicBarDrag.dispatch(value));
		musicBar.OnPointerUpSignal.add(() -> OnMusicBarPointerUp.dispatch());
		mainTrackButton.onClick.AddListener(() -> OnTrackButtonClick.dispatch());
		subTrackButton.onClick.AddListener(() -> OnTrackButtonClick.dispatch());
	}
	private function OnItemClickCallback(item:MusicRoomListItem):Void
	{
		OnMusicItemClick.dispatch(itemList.indexOfComponent(item));
	}
	public var OnReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnPlayButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnPauseButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnTrackButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnMusicItemClick:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnMusicBarDrag:FlxTypedSignal<Float->Void> = new FlxTypedSignal();
	public var OnMusicBarPointerUp:FlxTypedSignal<Void->Void> = new FlxTypedSignal();

	@:serializeField
	private var itemList:ElementList;
	@:serializeField
	private var returnButton:Button;
	@:serializeField
	private var nameText:TextMeshProUGUI;
	@:serializeField
	private var informationText:TextMeshProUGUI;
	@:serializeField
	private var descriptionText:TextMeshProUGUI;
	@:serializeField
	private var playButton:Button;
	@:serializeField
	private var pauseButton:Button;
	@:serializeField
	private var trackButtonRoot:GameObject;
	@:serializeField
	private var mainTrackButton:Button;
	@:serializeField
	private var subTrackButton:Button;
	@:serializeField
	private var playButtonObj:GameObject;
	@:serializeField
	private var pauseButtonObj:GameObject;
	@:serializeField
	private var currentTimeText:TextMeshProUGUI;
	@:serializeField
	private var totalTimeText:TextMeshProUGUI;
	@:serializeField
	private var musicBar:MusicBar;
	@:serializeField
	private var barSlider:Slider;
}
