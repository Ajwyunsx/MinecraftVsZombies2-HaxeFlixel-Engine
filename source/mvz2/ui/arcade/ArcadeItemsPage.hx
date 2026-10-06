// Ported from: Assets/Scripts/View/Arcade/ArcadeItemsPage.cs
package mvz2.ui.arcade;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import unity.GameObject;
import unity.ui.Button;
import unity.ui.ScrollRect;
import mvz2.ui.arcade.ArcadeItem;
import unity.MonoBehaviour;
import mvz2.ui.arcade.ArcadeItem.ArcadeItemViewData;
import flixel.util.FlxSignal;

class ArcadeItemsPage extends unity.MonoBehaviour
{
	public function SetActive(active:Bool):Void
	{
		gameObject.SetActive(active);
		itemsScrollRect.verticalNormalizedPosition = 1;
	}
	// protected virtual
	private function Awake():Void
	{
		returnButton.onClick.AddListener(() -> OnReturnClick.dispatch());
	}
	public function SetItems(items:Array<ArcadeItemViewData>):Void
	{
		itemList.updateList(items.length,
			function(i:Int, obj:GameObject)
			{
				var entry = obj.GetComponent(ArcadeItem);
				entry.UpdateItem(items[i]);
			},
			function(obj:GameObject)
			{
				var entry = obj.GetComponent(ArcadeItem);
				entry.OnClick.add(OnEntryClickCallback);
			},
			function(obj:GameObject)
			{
				var entry = obj.GetComponent(ArcadeItem);
				entry.OnClick.remove(OnEntryClickCallback);
			});
	}
	private function OnEntryClickCallback(item:ArcadeItem):Void
	{
		OnEntryClick.dispatch(itemList.indexOfComponent(item));
	}
	public var OnEntryClick:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	@:serializeField
	private var returnButton:Button;
	@:serializeField
	private var itemList:ElementList;
	@:serializeField
	private var itemsScrollRect:ScrollRect;
}
