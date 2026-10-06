// Ported from: Assets/Scripts/View/Archive/ArchiveTalkItem.cs
package mvz2.ui.archive;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class ArchiveTalkItem extends unity.MonoBehaviour
{
	public function UpdateName(name:String):Void
	{
		nameText.text = name;
	}
	private function Awake():Void
	{
		button.onClick.AddListener(() -> OnClick.dispatch(this));
	}
	public var OnClick:FlxTypedSignal<ArchiveTalkItem->Void> = new FlxTypedSignal();
	@:serializeField
	private var button:Button;
	@:serializeField
	private var nameText:TextMeshProUGUI;
}
