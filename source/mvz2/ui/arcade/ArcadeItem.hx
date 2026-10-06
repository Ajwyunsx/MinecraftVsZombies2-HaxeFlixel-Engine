// Ported from: Assets/Scripts/View/Arcade/ArcadeItem.cs
package mvz2.ui.arcade;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.GameObject;
import unity.Sprite;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import unity.ui.Image;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class ArcadeItem extends unity.MonoBehaviour
{
	public function UpdateItem(viewData:ArcadeItemViewData):Void
	{
		rootObject.SetActive(!viewData.empty);

		icon.gameObject.SetActive(viewData.unlocked);
		lockedIcon.gameObject.SetActive(!viewData.unlocked);

		button.interactable = viewData.unlocked;

		var sprite = viewData.sprite;
		icon.sprite = sprite;
		icon.enabled = sprite != null;

		clearSprite.sprite = viewData.clearSprite;
		clearSprite.enabled = viewData.clearSprite != null;

		nameText.text = viewData.name;
		hintText.text = viewData.hint;
	}
	private function Awake():Void
	{
		button.onClick.AddListener(() -> OnClick.dispatch(this));
	}
	public var OnClick:FlxTypedSignal<ArcadeItem->Void> = new FlxTypedSignal();
	@:serializeField
	private var rootObject:GameObject;
	@:serializeField
	private var button:Button;
	@:serializeField
	private var icon:Image;
	@:serializeField
	private var lockedIcon:Image;
	@:serializeField
	private var clearSprite:Image;
	@:serializeField
	private var nameText:TextMeshProUGUI;
	@:serializeField
	private var hintText:TextMeshProUGUI;
}

// C# 中为 MVZ2.UI.Arcade 的 ArcadeItemViewData 结构体。
class ArcadeItemViewData
{
	public var empty:Bool;
	public var sprite:Null<Sprite>;
	public var hint:String;
	public var name:String;
	public var clearSprite:Null<Sprite>;
	public var unlocked:Bool;

	public static var Empty(get, never):ArcadeItemViewData;
	static function get_Empty():ArcadeItemViewData
	{
		var data = new ArcadeItemViewData();
		data.empty = true;
		return data;
	}

	// PORT-NOTE: C# 结构体初始化器 `new ArcadeItemViewData { field = value }` 在 Haxe 中写作 `new ArcadeItemViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new ArcadeItemViewData()`。
	public function new(?data:{?empty:Bool, ?sprite:Null<Sprite>, ?hint:String, ?name:String, ?clearSprite:Null<Sprite>, ?unlocked:Bool})
	{
		if (data == null)
			return;
		if (data.empty != null) empty = data.empty;
		if (data.sprite != null) sprite = data.sprite;
		if (data.hint != null) hint = data.hint;
		if (data.name != null) name = data.name;
		if (data.clearSprite != null) clearSprite = data.clearSprite;
		if (data.unlocked != null) unlocked = data.unlocked;
	}
}
