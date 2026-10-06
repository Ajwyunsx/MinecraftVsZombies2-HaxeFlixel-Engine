// Ported from: Assets/Scripts/View/Level/ProgressBar.cs
package mvz2.ui.level;

import mvz2.ui.ElementListUI;
import unity.RectTransform;
import unity.Sprite;
import unity.Vector2;
import unity.Vector4;
import unity.ui.Image;
import unity.ui.LayoutElement;
import unity.ui.Slider;
import unity.tmpro.TextMeshProUGUI;
import unity.MonoBehaviour;
import unity.ui.Image.FillMethod;
import unity.ui.Image.ImageType;
import unity.ui.Slider.SliderDirection;

class ProgressBar extends unity.MonoBehaviour
{
	public function UpdateTemplate(viewData:ProgressBarTemplateViewData):Void
	{
		layoutElement.minWidth = viewData.size.x;
		layoutElement.minHeight = viewData.size.y;
		backgroundImage.sprite = viewData.backgroundSprite;
		foregroundImage.sprite = viewData.foregroundSprite;
		foregroundImage.enabled = foregroundImage.sprite != null;

		barImage.sprite = viewData.barSprite;
		barImage.type = viewData.barMode == ProgressBarMode.Filled ? ImageType.Filled : ImageType.Sliced;
		barImage.fillMethod = FillMethod.Horizontal;
		barImage.fillOrigin = (cast (viewData.fromLeft ? OriginHorizontal.Left : OriginHorizontal.Right) : Int);

		iconImage.sprite = viewData.iconSprite;
		iconImage.enabled = iconImage.sprite != null;
		slider.direction = viewData.fromLeft ? SliderDirection.LeftToRight : SliderDirection.RightToLeft;

		var padding = viewData.padding;
		var left = padding.x;
		var bottom = padding.y;
		var right = padding.z;
		var top = padding.w;
		var offset = new Vector2((left - right) * 0.5, (bottom - top) * 0.5);
		var size = new Vector2(-left - right, -bottom - top);
		barRegion.anchoredPosition = offset;
		barRegion.sizeDelta = size;

		barText.rectTransform.anchoredPosition += viewData.textOffset;
	}
	public function SetProgress(progress:Float):Void
	{
		slider.SetValueWithoutNotify(progress);
	}
	public function SetProgressText(text:String):Void
	{
		barText.text = text;
	}
	public function SetBannerProgresses(progresses:Array<Float>):Void
	{
		flags.updateList(progresses.length,
			function(i:Int, rect:RectTransform)
			{
				var component = rect.GetComponent(ProgressBarBanner);
				component.SetRiseProgress(progresses[i]);
			});
	}

	@:serializeField
	private var layoutElement:LayoutElement;
	@:serializeField
	private var flags:ElementListUI;
	@:serializeField
	private var foregroundImage:Image;
	@:serializeField
	private var backgroundImage:Image;
	@:serializeField
	private var barImage:Image;
	@:serializeField
	private var iconImage:Image;
	@:serializeField
	private var barRegion:RectTransform;
	@:serializeField
	private var slider:Slider;
	@:serializeField
	private var barText:TextMeshProUGUI;
}

// C# 中为 MVZ2.UI.Level 的 ProgressBarTemplateViewData 结构体。
class ProgressBarTemplateViewData
{
	public var size:Vector2 = new Vector2();
	public var backgroundSprite:Null<Sprite>;
	public var foregroundSprite:Null<Sprite>;
	public var barSprite:Null<Sprite>;
	public var iconSprite:Null<Sprite>;
	public var fromLeft:Bool;
	public var barMode:ProgressBarMode = ProgressBarMode.Sliced;
	public var padding:Vector4 = new Vector4();
	public var textOffset:Vector2 = new Vector2();

	public function new() {}
}

// UnityEngine.UI.Image.OriginHorizontal
enum abstract OriginHorizontal(Int)
{
	var Left = 0;
	var Right = 1;
}

enum abstract ProgressBarMode(Int)
{
	var Sliced = 0;
	var Filled = 1;
}
