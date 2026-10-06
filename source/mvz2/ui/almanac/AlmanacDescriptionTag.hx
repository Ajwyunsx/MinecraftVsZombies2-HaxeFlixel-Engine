// Ported from: Assets/Scripts/View/Almanac/AlmanacDescriptionTag.cs
package mvz2.ui.almanac;

import mvz2.ui.almanac.AlmanacTagIcon;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.UnityObject;
import unity.Vector3;
import unity.MonoBehaviour;
import unity.Vector2;
import mvz2.ui.almanac.AlmanacTagIcon.AlmanacTagIconViewData;
import flixel.util.FlxSignal;

class AlmanacDescriptionTag extends unity.MonoBehaviour
{
	public function UpdateTag(viewData:AlmanacDescriptionTagViewData):Void
	{
		linkID = viewData.linkID;
		if (UnityObject.exists(icon))
			icon.UpdateContainer(viewData.icon);
	}
	public function SetScale(size:Vector3):Void
	{
		if (UnityObject.exists(icon))
			icon.SetScale(size);
	}
	private function Awake():Void
	{
		if (!UnityObject.exists(icon))
			return;
		icon.OnPointerEnterSignal.add(_ -> OnPointerEnter.dispatch(linkID != null ? linkID : ""));
		icon.OnPointerExitSignal.add(_ -> OnPointerExit.dispatch(linkID != null ? linkID : ""));
		icon.OnPointerDownSignal.add(_ -> OnPointerDown.dispatch(linkID != null ? linkID : ""));
	}
	public var OnPointerEnter:FlxTypedSignal<String->Void> = new FlxTypedSignal();
	public var OnPointerExit:FlxTypedSignal<String->Void> = new FlxTypedSignal();
	public var OnPointerDown:FlxTypedSignal<String->Void> = new FlxTypedSignal();
	public var linkID:Null<String>;
	public var icon:Null<AlmanacTagIcon>;
}

// C# 中为 MVZ2.UI.Almanac 的 AlmanacDescriptionTagViewData 结构体。
class AlmanacDescriptionTagViewData
{
	public var linkID:String;
	public var icon:AlmanacTagIconViewData;
	public var size:unity.Vector2 = new unity.Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用

	// PORT-NOTE: C# 结构体初始化器 `new AlmanacDescriptionTagViewData { field = value }` 在 Haxe 中写作 `new AlmanacDescriptionTagViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new AlmanacDescriptionTagViewData()`。
	public function new(?data:{?linkID:String, ?icon:AlmanacTagIconViewData, ?size:unity.Vector2})
	{
		if (data == null)
			return;
		if (data.linkID != null) linkID = data.linkID;
		if (data.icon != null) icon = data.icon;
		if (data.size != null) size = data.size;
	}
}
