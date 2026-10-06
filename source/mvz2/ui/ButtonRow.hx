// Ported from: Assets/Scripts/View/Widgets/ButtonRow.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.UnityObject;
import unity.ui.Button;
import unity.GameObject;
import unity.MonoBehaviour;
import unity.ui.Text;
import flixel.util.FlxSignal;

class ButtonRow extends unity.MonoBehaviour
{
	public function SetInteractable(interactable:Bool):Void
	{
		for (i in 0...buttonList.Count)
		{
			var button = buttonList.getElementAs(i, TextButton);
			if (!UnityObject.exists(button))
				continue;
			button.Button.interactable = interactable;
		}
	}
	public function UpdateButtons(buttonTexts:Array<String>):Void
	{
		buttonList.updateList(buttonTexts.length,
			function(i:Int, obj:unity.GameObject)
			{
				var button = obj.GetComponent(TextButton);
				button.Text.text = buttonTexts[i];
			},
			null,
			function(rect:unity.GameObject)
			{
				var button = rect.GetComponent(TextButton);
				button.Button.onClick.RemoveAllListeners();
				button.Button.onClick.AddListener(() -> OnButtonClick.dispatch(this, buttonList.indexOf(rect)));
			});
	}
	public var OnButtonClick:FlxTypedSignal<ButtonRow->Int->Void> = new FlxTypedSignal();
	@:serializeField
	private var buttonList:ElementList;
}
