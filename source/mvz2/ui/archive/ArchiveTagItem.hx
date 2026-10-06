// Ported from: Assets/Scripts/View/Archive/ArchiveTagItem.cs
package mvz2.ui.archive;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Toggle;
import unity.MonoBehaviour;
import flixel.util.FlxSignal;

class ArchiveTagItem extends unity.MonoBehaviour
{
	public function UpdateTag(tag:ArchiveTagViewData):Void
	{
		tagText.text = tag.name;
		toggle.SetIsOnWithoutNotify(tag.value);
	}
	private function Awake():Void
	{
		toggle.onValueChanged.AddListener(value -> OnValueChanged.dispatch(this, value));
	}
	public var OnValueChanged:FlxTypedSignal<ArchiveTagItem->Bool->Void> = new FlxTypedSignal();
	@:serializeField
	private var toggle:Toggle;
	@:serializeField
	private var tagText:TextMeshProUGUI;
}

// C# 中为 MVZ2.UI.Archive 的 ArchiveTagViewData 结构体。
class ArchiveTagViewData
{
	public var name:String;
	public var value:Bool;

	// PORT-NOTE: C# 结构体初始化器 `new ArchiveTagViewData { field = value }` 在 Haxe 中写作 `new ArchiveTagViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new ArchiveTagViewData()`。
	public function new(?data:{?name:String, ?value:Bool})
	{
		if (data == null)
			return;
		if (data.name != null) name = data.name;
		if (data.value != null) value = data.value;
	}
}
