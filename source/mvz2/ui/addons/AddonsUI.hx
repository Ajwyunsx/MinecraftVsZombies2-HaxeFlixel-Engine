// Ported from: Assets/Scripts/View/Addons/AddonsUI.cs
package mvz2.ui.addons;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.GameObject;
import unity.ui.Button;
import mvz2.localization.LanguagePack;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class AddonsUI extends unity.MonoBehaviour
{
	public function SetIndexVisible(visible:Bool):Void
	{
		indexUI.SetActive(visible);
	}
	public function SetLoadingVisible(visible:Bool):Void
	{
		loadingScreen.SetActive(visible);
	}
	private function Awake():Void
	{
		buttonDict.set(AddonsButtonType.LanguagePack, languagePackButton);
		buttonDict.set(AddonsButtonType.Return, returnButton);

		for (key in buttonDict.keys())
		{
			var capturedKey = key;
			buttonDict.get(key).onClick.AddListener(() -> OnButtonClick.dispatch(capturedKey));
		}
	}
	public var OnButtonClick:FlxTypedSignal<AddonsButtonType->Void> = new FlxTypedSignal();
	@:serializeField
	private var languagePackButton:Button;
	@:serializeField
	private var returnButton:Button;
	@:serializeField
	private var indexUI:GameObject;
	@:serializeField
	private var loadingScreen:GameObject;
	private var buttonDict:Map<AddonsButtonType, Button> = new Map<AddonsButtonType, Button>();
}

// PORT-NOTE: C# AddonsUI.Buttons -> AddonsButtonType (mvz2.ui.addons.LanguagePacksUI also
// declares a top-level Buttons; Haxe forbids two same-named types in one package)
enum abstract AddonsButtonType(Int)
{
	var LanguagePack = 0;
	var Return = 1;
}
