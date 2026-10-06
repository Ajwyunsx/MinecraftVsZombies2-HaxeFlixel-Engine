// Ported from: Assets/Scripts/View/Almanac/AlmanacEntryGroupUI.cs
package mvz2.ui.almanac;

import mvz2.ui.almanac.AlmanacEntry;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import unity.GameObject;
import unity.tmpro.TextMeshProUGUI;
import unity.MonoBehaviour;
import mvz2.ui.almanac.AlmanacEntry.AlmanacEntryViewData;
import flixel.util.FlxSignal;

class AlmanacEntryGroupUI extends unity.MonoBehaviour
{
	public function UpdateEntry(viewData:AlmanacEntryGroupViewData):Void
	{
		titleText.text = viewData.name;
		entryList.updateList(viewData.entries.length,
			function(i:Int, obj:GameObject)
			{
				var entry = obj.GetComponent(AlmanacEntry);
				entry.UpdateEntry(viewData.entries[i]);
			},
			function(obj:GameObject)
			{
				var entry = obj.GetComponent(AlmanacEntry);
				entry.OnClick.add(OnEntryClickCallback);
			},
			function(obj:GameObject)
			{
				var entry = obj.GetComponent(AlmanacEntry);
				entry.OnClick.remove(OnEntryClickCallback);
			});
	}
	private function OnEntryClickCallback(entry:AlmanacEntry):Void
	{
		OnEntryClick.dispatch(this, entryList.indexOfComponent(entry));
	}
	public var OnEntryClick:FlxTypedSignal<AlmanacEntryGroupUI->Int->Void> = new FlxTypedSignal();
	@:serializeField
	private var titleText:TextMeshProUGUI;
	@:serializeField
	private var entryList:ElementList;
}

// C# 中为 MVZ2.UI.Almanac 的 AlmanacEntryGroupViewData 结构体。
class AlmanacEntryGroupViewData
{
	public var name:String;
	public var entries:Array<AlmanacEntryViewData>;

	// PORT-NOTE: C# 结构体初始化器 `new AlmanacEntryGroupViewData { field = value }` 在 Haxe 中写作 `new AlmanacEntryGroupViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new AlmanacEntryGroupViewData()`。
	public function new(?data:{?name:String, ?entries:Array<AlmanacEntryViewData>})
	{
		if (data == null)
			return;
		if (data.name != null) name = data.name;
		if (data.entries != null) entries = data.entries;
	}
}
