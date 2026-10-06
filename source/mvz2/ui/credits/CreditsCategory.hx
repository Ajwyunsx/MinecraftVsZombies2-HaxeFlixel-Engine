// Ported from: Assets/Scripts/View/Credits/CreditsCategory.cs
package mvz2.ui.credits;

import mvz2.ui.ElementList;
import unity.tmpro.TextMeshProUGUI;
import unity.GameObject;
import unity.MonoBehaviour;

class CreditsCategory extends unity.MonoBehaviour
{
	public function UpdateCategory(viewData:CreditsCategoryViewData):Void
	{
		nameText.text = viewData.name;
		entries.updateList(viewData.entries.length,
			function(i:Int, obj:unity.GameObject)
			{
				var data = viewData.entries[i];
				var entry = obj.GetComponent(CreditsEntry);
				entry.UpdateEntry(data);
			});
	}

	@:serializeField
	private var nameText:TextMeshProUGUI;
	@:serializeField
	private var entries:ElementList;
}

// C# 中为 MVZ2.UI.Credits 的 CreditsCategoryViewData 结构体。
// PORT-NOTE: C# 结构体初始化器 `new CreditsCategoryViewData { name = ..., entries = ... }` 在 Haxe 中写作 `new CreditsCategoryViewData({name: ..., entries: ...})`，
// 因此构造函数接受可选的匿名结构参数，同时兼容 `new CreditsCategoryViewData()`。
class CreditsCategoryViewData
{
	public var name:String;
	public var entries:Array<String>;

	public function new(?data:{?name:String, ?entries:Array<String>})
	{
		if (data == null)
			return;
		if (data.name != null) name = data.name;
		if (data.entries != null) entries = data.entries;
	}
}
