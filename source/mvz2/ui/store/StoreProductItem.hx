// Ported from: Assets/Scripts/View/Store/StoreProductItem.cs
package mvz2.ui.store;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.Blueprint;
import unity.GameObject;
import unity.Sprite;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import unity.ui.Image;
import unity.MonoBehaviour;
import unity.UnityObject;
import mvz2.ui.Blueprint.BlueprintViewData;
import unity.eventsystems.IEventSystemHandler.IPointerEnterHandler;
import unity.eventsystems.IEventSystemHandler.IPointerExitHandler;
import flixel.util.FlxSignal;

class StoreProductItem extends unity.MonoBehaviour implements IPointerEnterHandler implements IPointerExitHandler
{
	public function UpdateItem(viewData:ProductItemViewData):Void
	{
		root.SetActive(!viewData.empty);
		iconImage.sprite = viewData.icon;
		iconImage.enabled = !viewData.isBlueprint && iconImage.sprite != null;

		blueprintRoot.SetActive(viewData.isBlueprint);
		if (unity.UnityObject.exists(blueprintStandalone))
		{
			blueprintStandalone.gameObject.SetActive(!viewData.isBlueprintMobile);
			blueprintStandalone.UpdateView(viewData.blueprint);
		}
		if (unity.UnityObject.exists(blueprintMobile))
		{
			blueprintMobile.gameObject.SetActive(viewData.isBlueprintMobile);
			blueprintMobile.UpdateView(viewData.blueprint);
		}

		iconText.text = viewData.text;
		priceText.text = viewData.price;
		button.interactable = viewData.interactable;
	}
	private function Awake():Void
	{
		button.onClick.AddListener(() -> OnClick.dispatch(this));
	}
	public function OnPointerEnter(eventData:PointerEventData):Void
	{
		OnPointerEnterSignal.dispatch(this);
	}

	public function OnPointerExit(eventData:PointerEventData):Void
	{
		OnPointerExitSignal.dispatch(this);
	}
	public var OnClick:FlxTypedSignal<StoreProductItem->Void> = new FlxTypedSignal();
	// PORT-NOTE: C# 的事件与接口方法同名，Haxe 中字段与方法不能同名，事件字段加 Signal 后缀。
	public var OnPointerEnterSignal:FlxTypedSignal<StoreProductItem->Void> = new FlxTypedSignal();
	public var OnPointerExitSignal:FlxTypedSignal<StoreProductItem->Void> = new FlxTypedSignal();
	@:serializeField
	private var button:Button;
	@:serializeField
	private var root:GameObject;
	@:serializeField
	private var iconImage:Image;
	@:serializeField
	private var blueprintRoot:GameObject;
	@:serializeField
	private var blueprintStandalone:Null<Blueprint>;
	@:serializeField
	private var blueprintMobile:Null<Blueprint>;
	@:serializeField
	private var iconText:TextMeshProUGUI;
	@:serializeField
	private var priceText:TextMeshProUGUI;
}

// C# 中为 MVZ2.UI.Store 的 ProductItemViewData 结构体。
class ProductItemViewData
{
	public var empty:Bool;
	public var icon:Null<Sprite>;
	public var blueprint:BlueprintViewData;
	public var isBlueprint:Bool;
	public var isBlueprintMobile:Bool;
	public var text:String;
	public var price:String;
	public var interactable:Bool;

	public static var Empty(get, never):ProductItemViewData;
	static function get_Empty():ProductItemViewData
	{
		var data = new ProductItemViewData();
		data.empty = true;
		return data;
	}

	// PORT-NOTE: C# 结构体初始化器 `new ProductItemViewData { field = value }` 在 Haxe 中写作 `new ProductItemViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new ProductItemViewData()`。
	public function new(?data:{?empty:Bool, ?icon:Null<Sprite>, ?blueprint:BlueprintViewData, ?isBlueprint:Bool, ?isBlueprintMobile:Bool, ?text:String, ?price:String, ?interactable:Bool})
	{
		if (data == null)
			return;
		if (data.empty != null) empty = data.empty;
		if (data.icon != null) icon = data.icon;
		if (data.blueprint != null) blueprint = data.blueprint;
		if (data.isBlueprint != null) isBlueprint = data.isBlueprint;
		if (data.isBlueprintMobile != null) isBlueprintMobile = data.isBlueprintMobile;
		if (data.text != null) text = data.text;
		if (data.price != null) price = data.price;
		if (data.interactable != null) interactable = data.interactable;
	}
}
