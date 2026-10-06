// Ported from: Assets/Scripts/View/Keybinding/KeybindingItem.cs
package mvz2.ui.keybinding;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.Color;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class KeybindingItem extends unity.MonoBehaviour
{
	public function UpdateItem(viewData:KeybindingItemViewData):Void
	{
		nameText.text = viewData.name;
		keyText.text = viewData.key;
		keyText.color = viewData.keyColor;
	}
	private function Awake():Void
	{
		button.onClick.AddListener(() -> OnKeyButtonClick.dispatch(this));
	}
	public var OnKeyButtonClick:FlxTypedSignal<KeybindingItem->Void> = new FlxTypedSignal();

	@:serializeField
	private var nameText:TextMeshProUGUI;
	@:serializeField
	private var button:Button;
	@:serializeField
	private var keyText:TextMeshProUGUI;
}

// C# 中为 MVZ2.UI.Keybinding 的 KeybindingItemViewData 结构体。
class KeybindingItemViewData
{
	public var name:String;
	public var key:String;
	public var keyColor:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 abstract-over-class 的 null 解引用

	// PORT-NOTE: C# 结构体初始化器 `new KeybindingItemViewData { field = value }` 在 Haxe 中写作 `new KeybindingItemViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new KeybindingItemViewData()`。
	public function new(?data:{?name:String, ?key:String, ?keyColor:Color})
	{
		if (data == null)
			return;
		if (data.name != null) name = data.name;
		if (data.key != null) key = data.key;
		if (data.keyColor != null) keyColor = data.keyColor;
	}
}
