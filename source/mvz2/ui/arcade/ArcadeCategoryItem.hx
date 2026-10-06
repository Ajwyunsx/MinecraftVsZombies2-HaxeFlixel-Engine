// Ported from: Assets/Scripts/View/Arcade/ArcadeCategoryItem.cs
package mvz2.ui.arcade;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.Sprite;
import unity.ui.Button;
import unity.ui.Image;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class ArcadeCategoryItem extends unity.MonoBehaviour
{
	public function UpdateItem(viewData:ArcadeCategoryItemViewData):Void
	{
		var sprite = viewData.sprite;
		icon.sprite = sprite;
		icon.enabled = sprite != null;
	}
	private function Awake():Void
	{
		button.onClick.AddListener(() -> OnClick.dispatch(this));
	}
	public var OnClick:FlxTypedSignal<ArcadeCategoryItem->Void> = new FlxTypedSignal();
	@:serializeField
	private var button:Button;
	@:serializeField
	private var icon:Image;
}

// C# 中为 MVZ2.UI.Arcade 的 ArcadeCategoryItemViewData 结构体。
class ArcadeCategoryItemViewData
{
	public var sprite:Sprite;

	// PORT-NOTE: C# 结构体初始化器 `new ArcadeCategoryItemViewData { field = value }` 在 Haxe 中写作 `new ArcadeCategoryItemViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new ArcadeCategoryItemViewData()`。
	public function new(?data:{?sprite:Sprite})
	{
		if (data == null)
			return;
		if (data.sprite != null) sprite = data.sprite;
	}
}
