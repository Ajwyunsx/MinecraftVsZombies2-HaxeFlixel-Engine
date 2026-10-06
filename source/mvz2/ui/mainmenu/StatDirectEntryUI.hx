// Ported from: Assets/Scripts/View/Mainmenu/StatDirectEntryUI.cs
package mvz2.ui.mainmenu;

import unity.tmpro.TextMeshProUGUI;
import unity.MonoBehaviour;

class StatDirectEntryUI extends unity.MonoBehaviour
{
	public function UpdateEntry(viewData:StatDirectEntryViewData):Void
	{
		nameText.text = viewData.name;
		numberText.text = viewData.number;
	}
	@:serializeField
	private var nameText:TextMeshProUGUI;
	@:serializeField
	private var numberText:TextMeshProUGUI;
}

// C# 中为 MVZ2.UI.Mainmenu 的 StatDirectEntryViewData 结构体。
class StatDirectEntryViewData
{
	public var name:String;
	public var number:String;

	// PORT-NOTE: C# 结构体初始化器 `new StatDirectEntryViewData { field = value }` 在 Haxe 中写作 `new StatDirectEntryViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new StatDirectEntryViewData()`。
	public function new(?data:{?name:String, ?number:String})
	{
		if (data == null)
			return;
		if (data.name != null) name = data.name;
		if (data.number != null) number = data.number;
	}
}
