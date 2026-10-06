// Ported from: Assets/Scripts/View/Almanac/AlmanacEntry.cs
package mvz2.ui.almanac;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.Color;
import unity.GameObject;
import unity.RectTransform;
import unity.Sprite;
import unity.UnityObject;
import unity.Vector2;
import unity.Vector3;
import unity.ui.HorizontalOrVerticalLayoutGroup;
import unity.ui.Button;
import unity.ui.Image;
import unity.MonoBehaviour;
import unity.ui.HorizontalOrVerticalLayoutGroup.AspectRatioFitter;
import flixel.util.FlxSignal;

class AlmanacEntry extends unity.MonoBehaviour
{
	public function UpdateEntry(viewData:AlmanacEntryViewData):Void
	{
		rootObject.SetActive(!viewData.empty);
		var sprite = viewData.sprite;
		iconRoot.localPosition = new Vector3(viewData.offset.x, viewData.offset.y, 0);
		icon.sprite = sprite;
		icon.enabled = sprite != null;
		icon.color = viewData.color;
		if (UnityObject.exists(sprite))
		{
			ratioFitter.aspectRatio = sprite.rect.width / sprite.rect.height;
		}
		else
		{
			ratioFitter.aspectRatio = 1;
		}
	}
	private function Awake():Void
	{
		button.onClick.AddListener(() -> OnClick.dispatch(this));
	}
	public var OnClick:FlxTypedSignal<AlmanacEntry->Void> = new FlxTypedSignal();
	@:serializeField
	private var rootObject:GameObject;
	@:serializeField
	private var button:Button;
	@:serializeField
	private var iconRoot:RectTransform;
	@:serializeField
	private var icon:Image;
	@:serializeField
	private var ratioFitter:AspectRatioFitter;
}

// C# 中为 MVZ2.UI.Almanac 的 AlmanacEntryViewData 结构体。
class AlmanacEntryViewData
{
	public var empty:Bool;
	public var sprite:Null<Sprite>;
	public var color:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 abstract-over-class 的 null 解引用
	public var offset:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用

	public static var Empty(get, never):AlmanacEntryViewData;
	static function get_Empty():AlmanacEntryViewData
	{
		var data = new AlmanacEntryViewData();
		data.empty = true;
		return data;
	}

	// PORT-NOTE: C# 结构体初始化器 `new AlmanacEntryViewData { field = value }` 在 Haxe 中写作 `new AlmanacEntryViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new AlmanacEntryViewData()`。
	public function new(?data:{?empty:Bool, ?sprite:Null<Sprite>, ?color:Color, ?offset:Vector2})
	{
		if (data == null)
			return;
		if (data.empty != null) empty = data.empty;
		if (data.sprite != null) sprite = data.sprite;
		if (data.color != null) color = data.color;
		if (data.offset != null) offset = data.offset;
	}
}
