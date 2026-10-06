// Ported from: Assets/Scripts/View/Mainmenu/AchievementEntryUI.cs
package mvz2.ui.mainmenu;

import unity.GameObject;
import unity.Sprite;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Image;
import unity.MonoBehaviour;

class AchievementEntryUI extends unity.MonoBehaviour
{
	public function UpdateEntry(viewData:AchievementEntryViewData):Void
	{
		iconImage.sprite = viewData.icon;
		notEarnedIconImage.sprite = viewData.icon;
		iconImage.enabled = viewData.earned;
		notEarnedIconImage.enabled = !viewData.earned;
		nameText.text = viewData.name;
		earnedObj.SetActive(false); // 先禁用，这样会触发Translator的OnEnable，重新对文本进行翻译，防止切换语言后出现问题。
		earnedObj.SetActive(viewData.earned);
		descriptionText.text = viewData.description;
	}
	@:serializeField
	private var iconImage:Image;
	@:serializeField
	private var notEarnedIconImage:Image;
	@:serializeField
	private var nameText:TextMeshProUGUI;
	@:serializeField
	private var earnedObj:GameObject;
	@:serializeField
	private var descriptionText:TextMeshProUGUI;
}

// C# 中为 MVZ2.UI.Mainmenu 的 AchievementEntryViewData 结构体。
class AchievementEntryViewData
{
	public var icon:Null<Sprite>;
	public var name:String;
	public var earned:Bool;
	public var description:String;

	// PORT-NOTE: C# 结构体初始化器 `new AchievementEntryViewData { field = value }` 在 Haxe 中写作 `new AchievementEntryViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new AchievementEntryViewData()`。
	public function new(?data:{?icon:Null<Sprite>, ?name:String, ?earned:Bool, ?description:String})
	{
		if (data == null)
			return;
		if (data.icon != null) icon = data.icon;
		if (data.name != null) name = data.name;
		if (data.earned != null) earned = data.earned;
		if (data.description != null) description = data.description;
	}
}
