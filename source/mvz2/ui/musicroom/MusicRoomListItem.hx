// Ported from: Assets/Scripts/View/MusicRoom/MusicRoomListItem.cs
package mvz2.ui.musicroom;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Toggle;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class MusicRoomListItem extends unity.MonoBehaviour
{
	public function UpdateName(name:String):Void
	{
		nameText.text = name;
	}
	public function SetSelected(selected:Bool):Void
	{
		toggle.SetIsOnWithoutNotify(selected);
	}
	private function Awake():Void
	{
		toggle.onValueChanged.AddListener(function(value:Bool)
		{
			if (value)
			{
				OnClick.dispatch(this);
			}
		});
	}
	public var OnClick:FlxTypedSignal<MusicRoomListItem->Void> = new FlxTypedSignal();
	@:serializeField
	private var toggle:Toggle;
	@:serializeField
	private var nameText:TextMeshProUGUI;
}
