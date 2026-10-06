// Ported from: Assets/Scripts/View/Addons/LanguagePackItem.cs
package mvz2.ui.addons;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.Sprite;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Image;
import unity.ui.Toggle;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class LanguagePackItem extends unity.MonoBehaviour
{
	public function UpdateItem(viewData:LanguagePackViewData):Void
	{
		nameText.text = viewData.name;
		descriptionText.text = viewData.description;
		icon.sprite = viewData.icon;
	}
	public function SetToggled(value:Bool):Void
	{
		toggle.SetIsOnWithoutNotify(value);
	}
	private function Awake():Void
	{
		toggle.onValueChanged.AddListener(v -> OnToggled.dispatch(this, v));
	}
	public var OnToggled:FlxTypedSignal<LanguagePackItem->Bool->Void> = new FlxTypedSignal();
	@:serializeField
	private var toggle:Toggle;
	@:serializeField
	private var nameText:TextMeshProUGUI;
	@:serializeField
	private var descriptionText:TextMeshProUGUI;
	@:serializeField
	private var icon:Image;
}

// C# 中为 MVZ2.UI.Addons 的 LanguagePackViewData 结构体。
class LanguagePackViewData
{
	public var name:String;
	public var description:String;
	public var icon:Sprite;

	// PORT-NOTE: C# 结构体初始化器 `new LanguagePackViewData { field = value }` 在 Haxe 中写作 `new LanguagePackViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new LanguagePackViewData()`。
	public function new(?data:{?name:String, ?description:String, ?icon:Sprite})
	{
		if (data == null)
			return;
		if (data.name != null) name = data.name;
		if (data.description != null) description = data.description;
		if (data.icon != null) icon = data.icon;
	}
}
