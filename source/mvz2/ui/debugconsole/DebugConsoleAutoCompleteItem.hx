// Ported from: Assets/Scripts/View/DebugConsole/DebugConsoleAutoCompleteItem.cs
package mvz2.ui.debugconsole;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Toggle;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class DebugConsoleAutoCompleteItem extends unity.MonoBehaviour
{
	public function SetText(text:String):Void
	{
		gameObject.name = text;
		this.text.text = text;
	}
	public function SetIsOn(isOn:Bool):Void
	{
		toggle.SetIsOnWithoutNotify(isOn);
	}
	private function Awake():Void
	{
		toggle.onValueChanged.AddListener(OnValueChangedCallback);
	}
	private function OnValueChangedCallback(value:Bool):Void
	{
		OnValueChanged.dispatch(this, value);
	}
	public var OnValueChanged:FlxTypedSignal<DebugConsoleAutoCompleteItem->Bool->Void> = new FlxTypedSignal();
	@:serializeField
	private var toggle:Toggle;
	@:serializeField
	private var text:TextMeshProUGUI;
}
