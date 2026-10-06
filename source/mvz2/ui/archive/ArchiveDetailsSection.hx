// Ported from: Assets/Scripts/View/Archive/ArchiveDetailsSection.cs
package mvz2.ui.archive;

import unity.tmpro.TextMeshProUGUI;
import unity.MonoBehaviour;

class ArchiveDetailsSection extends unity.MonoBehaviour
{
	public function UpdateSection(viewData:ArchiveDetailsSectionViewData):Void
	{
		descriptionText.text = viewData.description;
		talksText.text = viewData.talks;
	}
	@:serializeField
	private var descriptionText:TextMeshProUGUI;
	@:serializeField
	private var talksText:TextMeshProUGUI;
}

// C# 中为 MVZ2.UI.Archive 的 ArchiveDetailsSectionViewData 结构体。
class ArchiveDetailsSectionViewData
{
	public var description:String;
	public var talks:String;

	// PORT-NOTE: C# 结构体初始化器 `new ArchiveDetailsSectionViewData { field = value }` 在 Haxe 中写作 `new ArchiveDetailsSectionViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new ArchiveDetailsSectionViewData()`。
	public function new(?data:{?description:String, ?talks:String})
	{
		if (data == null)
			return;
		if (data.description != null) description = data.description;
		if (data.talks != null) talks = data.talks;
	}
}
