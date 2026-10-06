// Ported from: Assets/Scripts/View/Almanac/AlmanacPage.cs
package mvz2.ui.almanac;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.ui.Button;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

// abstract
class AlmanacPage extends unity.MonoBehaviour
{
	public function SetActive(active:Bool):Void
	{
		gameObject.SetActive(active);
	}
	// protected virtual
	public function Awake():Void
	{
		returnButton.onClick.AddListener(() -> OnReturnClick.dispatch());
	}
	public var OnReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	@:serializeField
	private var returnButton:Button;
}
