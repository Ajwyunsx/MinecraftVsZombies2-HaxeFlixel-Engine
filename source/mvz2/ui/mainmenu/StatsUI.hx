// Ported from: Assets/Scripts/View/Mainmenu/StatsUI.cs
package mvz2.ui.mainmenu;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import unity.GameObject;
import unity.UnityObject;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import mvz2.ui.mainmenu.StatCategoryUI;
import mvz2.ui.mainmenu.StatDirectEntryUI;
import unity.MonoBehaviour;
import mvz2.ui.mainmenu.StatCategoryUI.StatCategoryViewData;
import mvz2.ui.mainmenu.StatDirectEntryUI.StatDirectEntryViewData;
import flixel.util.FlxSignal;

class StatsUI extends unity.MonoBehaviour
{
	public function UpdateStats(viewData:StatsViewData):Void
	{
		playTimeText.text = viewData.playTimeText;
		if (UnityObject.exists(entryList))
		{
			entryList.gameObject.SetActive(viewData.entries.length > 0);
			entryList.updateList(viewData.entries.length,
				function(i:Int, obj:GameObject)
				{
					var category = obj.GetComponent(StatDirectEntryUI);
					category.UpdateEntry(viewData.entries[i]);
				});
		}
		if (UnityObject.exists(categoryList))
		{
			categoryList.gameObject.SetActive(viewData.categories.length > 0);
			categoryList.updateList(viewData.categories.length,
				function(i:Int, obj:GameObject)
				{
					var category = obj.GetComponent(StatCategoryUI);
					category.UpdateCategory(viewData.categories[i]);
					category.SetExpanded(false);
				});
		}
	}
	private function Awake():Void
	{
		backButton.onClick.AddListener(() -> OnReturnClick.dispatch());
	}
	public var OnReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	@:serializeField
	private var playTimeText:TextMeshProUGUI;
	@:serializeField
	private var entryList:ElementList;
	@:serializeField
	private var categoryList:ElementList;
	@:serializeField
	private var backButton:Button;
}

// C# 中为 MVZ2.UI.Mainmenu 的 StatsViewData 结构体。
class StatsViewData
{
	public var playTimeText:String;
	public var entries:Array<StatDirectEntryViewData>;
	public var categories:Array<StatCategoryViewData>;

	// PORT-NOTE: C# 结构体初始化器 `new StatsViewData { field = value }` 在 Haxe 中写作 `new StatsViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new StatsViewData()`。
	public function new(?data:{?playTimeText:String, ?entries:Array<StatDirectEntryViewData>, ?categories:Array<StatCategoryViewData>})
	{
		if (data == null)
			return;
		if (data.playTimeText != null) playTimeText = data.playTimeText;
		if (data.entries != null) entries = data.entries;
		if (data.categories != null) categories = data.categories;
	}
}
