// Ported from: Assets/Scripts/View/Mainmenu/StatCategoryUI.cs
package mvz2.ui.mainmenu;

import mvz2.ui.ElementList;
import unity.GameObject;
import unity.Transform;
import unity.Vector3;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import mvz2.ui.mainmenu.StatEntryUI;
import unity.MonoBehaviour;
import mvz2.ui.mainmenu.StatEntryUI.StatEntryViewData;

class StatCategoryUI extends unity.MonoBehaviour
{
	public function UpdateCategory(viewData:StatCategoryViewData):Void
	{
		titleText.text = viewData.title;
		sumText.text = viewData.sum;
		entryList.updateList(viewData.entries.length,
			function(i:Int, obj:GameObject)
			{
				var entry = obj.GetComponent(StatEntryUI);
				entry.UpdateEntry(viewData.entries[i]);
			});
	}
	public function SetExpanded(expanded:Bool):Void
	{
		expandArrowTransform.localEulerAngles = new Vector3(0, 0, expanded ? -90 : 0);
		entriesRoot.SetActive(expanded);
	}
	public function IsExpanded():Bool
	{
		return entriesRoot.activeSelf;
	}
	private function Awake():Void
	{
		expandArrowButton.onClick.AddListener(() -> SetExpanded(!IsExpanded()));
	}
	@:serializeField
	private var expandArrowTransform:Transform;
	@:serializeField
	private var expandArrowButton:Button;
	@:serializeField
	private var entriesRoot:GameObject;
	@:serializeField
	private var entryList:ElementList;
	@:serializeField
	private var titleText:TextMeshProUGUI;
	@:serializeField
	private var sumText:TextMeshProUGUI;
}

// C# 中为 MVZ2.UI.Mainmenu 的 StatCategoryViewData 结构体。
class StatCategoryViewData
{
	public var entries:Array<StatEntryViewData>;
	public var title:String;
	public var sum:String;

	// PORT-NOTE: C# 结构体初始化器 `new StatCategoryViewData { field = value }` 在 Haxe 中写作 `new StatCategoryViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new StatCategoryViewData()`。
	public function new(?data:{?entries:Array<StatEntryViewData>, ?title:String, ?sum:String})
	{
		if (data == null)
			return;
		if (data.entries != null) entries = data.entries;
		if (data.title != null) title = data.title;
		if (data.sum != null) sum = data.sum;
	}
}
