// Ported from: Assets/Scripts/View/Store/StoreUI.cs
package mvz2.ui.store;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import mvz2.ui.MoneyPanel;
import mvz2.ui.store.StoreProductItem;
import mvz2.ui.talk.SpeechBubble;
import unity.GameObject;
import unity.Sprite;
import unity.SpriteRenderer;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import unity.MonoBehaviour;
import mvz2.ui.store.StoreProductItem.ProductItemViewData;
import mvz2.ui.talk.SpeechBubble.SpeechBubbleDirection;
import flixel.util.FlxSignal;

class StoreUI extends unity.MonoBehaviour
{
	public function Display():Void
	{
		speechBubble.SetDirection(SpeechBubbleDirection.Left);
	}
	public function SetStoreUIVisible(visible:Bool):Void
	{
		storeUIRoot.SetActive(visible);
		speechBubble.SetDirection(SpeechBubbleDirection.Left);
	}
	public function SetMoney(money:String):Void
	{
		moneyPanel.SetMoney(money);
	}
	public function SetProducts(viewDatas:Array<ProductItemViewData>):Void
	{
		products.updateList(viewDatas.length,
			function(i:Int, obj:GameObject)
			{
				var page = obj.GetComponent(StoreProductItem);
				page.UpdateItem(viewDatas[i]);
			},
			function(obj:GameObject)
			{
				var page = obj.GetComponent(StoreProductItem);
				page.OnClick.add(OnPageProductClickCallback);
				page.OnPointerEnterSignal.add(OnPageProductPointerEnterCallback);
				page.OnPointerExitSignal.add(OnPageProductPointerExitCallback);
			},
			function(obj:GameObject)
			{
				var page = obj.GetComponent(StoreProductItem);
				page.OnClick.remove(OnPageProductClickCallback);
				page.OnPointerEnterSignal.remove(OnPageProductPointerEnterCallback);
				page.OnPointerExitSignal.remove(OnPageProductPointerExitCallback);
			});
	}
	public function SetPageNumber(pageNumber:String):Void
	{
		pageText.text = pageNumber;
	}
	public function SetPageButtonInteractable(prev:Bool, next:Bool):Void
	{
		prevPageButton.interactable = prev;
		nextPageButton.interactable = next;
	}
	public function SetBackground(sprite:Null<Sprite>):Void
	{
		background.sprite = sprite;
	}
	public function ShowTalk(message:String):Void
	{
		speechBubble.SetText(message);
		speechBubble.SetShowing(true);
	}
	public function HideTalk():Void
	{
		speechBubble.SetShowing(false);
	}
	private function Awake():Void
	{
		returnButton.onClick.AddListener(() -> OnReturnClick.dispatch());
		prevPageButton.onClick.AddListener(() -> OnPageButtonClick.dispatch(false));
		nextPageButton.onClick.AddListener(() -> OnPageButtonClick.dispatch(true));
	}
	private function OnPageProductClickCallback(item:StoreProductItem):Void
	{
		OnProductClick.dispatch(products.indexOfComponent(item));
	}
	private function OnPageProductPointerEnterCallback(item:StoreProductItem):Void
	{
		OnProductPointerEnter.dispatch(products.indexOfComponent(item));
	}
	private function OnPageProductPointerExitCallback(item:StoreProductItem):Void
	{
		OnProductPointerExit.dispatch(products.indexOfComponent(item));
	}
	public var OnReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnPageButtonClick:FlxTypedSignal<Bool->Void> = new FlxTypedSignal();
	public var OnProductClick:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnProductPointerEnter:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnProductPointerExit:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	@:serializeField
	private var storeUIRoot:GameObject;
	@:serializeField
	private var background:SpriteRenderer;
	@:serializeField
	private var speechBubble:SpeechBubble;
	@:serializeField
	private var returnButton:Button;
	@:serializeField
	private var prevPageButton:Button;
	@:serializeField
	private var nextPageButton:Button;
	@:serializeField
	private var pageText:TextMeshProUGUI;
	@:serializeField
	private var moneyPanel:MoneyPanel;
	@:serializeField
	private var products:ElementList;
}
