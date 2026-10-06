// Ported from: Assets/Scripts/View/Mainmenu/StatEntryUI.cs
package mvz2.ui.mainmenu;

import haxe.Int64;
import unity.tmpro.TextMeshProUGUI;
import unity.MonoBehaviour;

class StatEntryUI extends unity.MonoBehaviour
{
	public function UpdateEntry(viewData:StatEntryViewData):Void
	{
		nameText.text = viewData.name;
		countText.text = Std.string(viewData.count);
	}
	@:serializeField
	private var nameText:TextMeshProUGUI;
	@:serializeField
	private var countText:TextMeshProUGUI;
}

// C# 中为 MVZ2.UI.Mainmenu 的 StatEntryViewData 结构体。
class StatEntryViewData
{
	public var name:String;
	public var count:Int64;

	// PORT-NOTE: C# 结构体初始化器 `new StatEntryViewData { field = value }` 在 Haxe 中写作 `new StatEntryViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new StatEntryViewData()`。
	public function new(?data:{?name:String, ?count:Int64})
	{
		if (data == null)
			return;
		if (data.name != null) name = data.name;
		if (data.count != null) count = data.count;
	}
}
