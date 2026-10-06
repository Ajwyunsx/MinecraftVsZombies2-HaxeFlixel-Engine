// Ported from: Assets/Scripts/View/Archive/DetailsArchivePage.cs
package mvz2.ui.archive;

import mvz2.ui.archive.ArchiveDetailsSection;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import unity.GameObject;
import unity.Sprite;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import unity.ui.Image;
import unity.ui.ScrollRect;
import mvz2.ui.archive.ArchiveDetailsSection.ArchiveDetailsSectionViewData;
import flixel.util.FlxSignal;

class DetailsArchivePage extends ArchivePage
{
	public function UpdateDetails(viewData:ArchiveDetailsViewData):Void
	{
		nameText.text = viewData.name;
		backgroundImage.sprite = viewData.background;
		segmentsText.text = viewData.segments;
		musicText.text = viewData.music;
		tagsText.text = viewData.tags;
		sectionList.updateList(viewData.sections.length,
			function(i:Int, obj:GameObject)
			{
				var section = obj.GetComponent(ArchiveDetailsSection);
				section.UpdateSection(viewData.sections[i]);
			});
		descriptionScrollRect.verticalNormalizedPosition = 1;
	}
	private function Awake():Void
	{
		playButton.onClick.AddListener(() -> OnPlayClick.dispatch());
		returnButton.onClick.AddListener(() -> OnReturnClick.dispatch());
	}
	public var OnReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnPlayClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	@:serializeField
	private var returnButton:Button;
	// [Header("General")]
	@:serializeField
	private var nameText:TextMeshProUGUI;
	@:serializeField
	private var backgroundImage:Image;
	@:serializeField
	private var segmentsText:TextMeshProUGUI;
	@:serializeField
	private var musicText:TextMeshProUGUI;
	@:serializeField
	private var tagsText:TextMeshProUGUI;
	@:serializeField
	private var playButton:Button;
	// [Header("Sections")]
	@:serializeField
	private var descriptionScrollRect:ScrollRect;
	@:serializeField
	private var sectionList:ElementList;
}

// C# 中为 MVZ2.UI.Archive 的 ArchiveDetailsViewData 结构体。
class ArchiveDetailsViewData
{
	public var name:String;
	public var background:Null<Sprite>;
	public var segments:String;
	public var music:String;
	public var tags:String;
	public var sections:Array<ArchiveDetailsSectionViewData>;

	// PORT-NOTE: C# 结构体初始化器 `new ArchiveDetailsViewData { field = value }` 在 Haxe 中写作 `new ArchiveDetailsViewData({field: value})`，
	// 因此构造函数接受可选的匿名结构参数，同时兼容 `new ArchiveDetailsViewData()`。
	public function new(?data:{?name:String, ?background:Null<Sprite>, ?segments:String, ?music:String, ?tags:String, ?sections:Array<ArchiveDetailsSectionViewData>})
	{
		if (data == null)
			return;
		if (data.name != null) name = data.name;
		if (data.background != null) background = data.background;
		if (data.segments != null) segments = data.segments;
		if (data.music != null) music = data.music;
		if (data.tags != null) tags = data.tags;
		if (data.sections != null) sections = data.sections;
	}
}
