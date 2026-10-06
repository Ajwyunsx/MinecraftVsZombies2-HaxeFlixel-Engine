// Ported from: Assets/Scripts/View/Level/HPBar/HPBar.cs
package mvz2.ui.level;

import unity.Color;
import unity.Sprite;
import unity.ui.Image;
import unity.tmpro.TextMeshProUGUI;
import unity.MonoBehaviour;

class HPBar extends unity.MonoBehaviour
{
	public function UpdateBar(data:HPBarViewData):Void
	{
		SetBarColor(data.barColor);
		SetBarFill(data.barAmount);
		SetText(data.text);
		SetIcon(data.icon);
	}
	public function SetBarColor(color:Color):Void
	{
		barImage.color = color;
	}
	public function SetBarFill(value:Float):Void
	{
		barImage.fillAmount = value;
	}
	public function SetText(text:String):Void
	{
		this.text.text = text;
	}
	public function SetIcon(sprite:Null<Sprite>):Void
	{
		icon.sprite = sprite;
		icon.enabled = sprite != null;
	}
	@:serializeField
	private var barImage:Image;
	@:serializeField
	private var text:TextMeshProUGUI;
	@:serializeField
	private var icon:Image;
}

// C# 中为 MVZ2.UI.Level 的 HPBarViewData 结构体。
class HPBarViewData
{
	public var barColor:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 abstract-over-class 的 null 解引用
	public var barAmount:Float;
	public var text:String;
	public var icon:Null<Sprite>;

	public function new() {}
}
