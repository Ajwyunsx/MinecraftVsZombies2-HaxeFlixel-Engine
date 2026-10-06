// Ported from: Assets/Scripts/View/Dialogs/UserManageItem.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.Color;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Toggle;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class UserManageItem extends unity.MonoBehaviour
{
	public function SetIsOn(value:Bool):Void
	{
		toggle.SetIsOnWithoutNotify(value);
	}
	public function SetName(name:String):Void
	{
		nameText.text = name;
	}
	public function SetColor(color:Color):Void
	{
		nameText.color = color;
	}
	private function Awake():Void
	{
		toggle.onValueChanged.AddListener(value -> OnValueChanged.dispatch(this, value));
	}
	public var OnValueChanged:FlxTypedSignal<UserManageItem->Bool->Void> = new FlxTypedSignal();
	@:serializeField
	private var nameText:TextMeshProUGUI;
	@:serializeField
	private var toggle:Toggle;
}
