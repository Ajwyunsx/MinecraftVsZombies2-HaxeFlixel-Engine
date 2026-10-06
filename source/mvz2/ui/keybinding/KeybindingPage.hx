// Ported from: Assets/Scripts/View/Keybinding/KeybindingPage.cs
package mvz2.ui.keybinding;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import unity.GameObject;
import unity.UnityObject;
import unity.ui.Button;
import mvz2.ui.keybinding.KeybindingItem;
import unity.MonoBehaviour;
import mvz2.ui.keybinding.KeybindingItem.KeybindingItemViewData;
import flixel.util.FlxSignal;

class KeybindingPage extends unity.MonoBehaviour
{
	public function UpdateItems(viewData:Array<KeybindingItemViewData>):Void
	{
		items.updateList(viewData.length,
			function(i:Int, obj:GameObject)
			{
				var data = viewData[i];
				var item = obj.GetComponent(KeybindingItem);
				item.UpdateItem(data);
			},
			function(obj:GameObject)
			{
				var item = obj.GetComponent(KeybindingItem);
				item.OnKeyButtonClick.add(OnItemButtonClickCallback);
			},
			function(obj:GameObject)
			{
				var item = obj.GetComponent(KeybindingItem);
				item.OnKeyButtonClick.remove(OnItemButtonClickCallback);
			});
	}
	public function UpdateItem(index:Int, viewData:KeybindingItemViewData):Void
	{
		var item = items.getElementAs(index, KeybindingItem);
		if (UnityObject.exists(item))
			item.UpdateItem(viewData);
	}
	private function Awake():Void
	{
		backButton.onClick.AddListener(() -> OnBackButtonClick.dispatch());
		resetButton.onClick.AddListener(() -> OnResetButtonClick.dispatch());
	}
	private function OnItemButtonClickCallback(item:KeybindingItem):Void
	{
		OnItemButtonClick.dispatch(items.indexOfComponent(item));
	}
	public var OnBackButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnResetButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnItemButtonClick:FlxTypedSignal<Int->Void> = new FlxTypedSignal();


	@:serializeField
	private var items:ElementList;
	@:serializeField
	private var backButton:Button;
	@:serializeField
	private var resetButton:Button;
}
