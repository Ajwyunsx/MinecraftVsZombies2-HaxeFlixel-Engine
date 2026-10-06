// Ported from: Assets/Scripts/View/Almanac/AlmanacTagIconLayer.cs
package mvz2.ui.almanac;

import unity.Color;
import unity.Sprite;
import unity.ui.Image;
import unity.MonoBehaviour;

class AlmanacTagIconLayer extends unity.MonoBehaviour
{
	public function UpdateView(viewData:AlmanacTagIconLayerViewData):Void
	{
		image.sprite = viewData.sprite;
		image.enabled = image.sprite != null;
		image.color = viewData.tint;
	}
	@:serializeField
	private var image:Image;
}

// C# 中为 MVZ2.UI.Almanac 的 AlmanacTagIconLayerViewData 结构体。
class AlmanacTagIconLayerViewData
{
	public var sprite:Null<Sprite>;
	public var tint:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 abstract-over-class 的 null 解引用

	// PORT-NOTE: C# 结构体初始化器 `new AlmanacTagIconLayerViewData { field = value }` 在 Haxe 中写作 `new AlmanacTagIconLayerViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new AlmanacTagIconLayerViewData()`。
	public function new(?data:{?sprite:Null<Sprite>, ?tint:Color})
	{
		if (data == null)
			return;
		if (data.sprite != null) sprite = data.sprite;
		if (data.tint != null) tint = data.tint;
	}
}
