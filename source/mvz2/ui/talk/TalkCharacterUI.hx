// Ported from: Assets/Scripts/View/Talk/TalkCharacterUI.cs
package mvz2.ui.talk;

import unity.RectTransform;
import unity.Sprite;
import unity.Vector2;
import unity.Vector3;
import unity.ui.Image;
import unity.MonoBehaviour;

class TalkCharacterUI extends unity.MonoBehaviour
{
	// #region 公有方法
	public function SetScale(scale:Vector3):Void
	{
		transform.localScale = scale;
	}
	public function SetSprite(sprite:Sprite):Void
	{
		image.sprite = sprite;
	}
	public function SetFlipX(flipX:Bool):Void
	{
		image.transform.localScale = new Vector3(flipX ? -1 : 1, 1, 1);
	}
	public function SetPivot(pivot:Vector2):Void
	{
		imageRectTransform.pivot = pivot;
	}
	public function SetWidthExtend(widthExtend:Vector2):Void
	{
		var anchoredPos = imageRectTransform.anchoredPosition;
		var sizeDelta = imageRectTransform.sizeDelta;
		anchoredPos.x = (widthExtend.x - widthExtend.y) * -0.5;
		sizeDelta.x = widthExtend.x + widthExtend.y;
		imageRectTransform.anchoredPosition = anchoredPos;
		imageRectTransform.sizeDelta = sizeDelta;
	}
	// #endregion

	// #region 属性字段
	@:serializeField
	private var image:Image;
	@:serializeField
	private var imageRectTransform:RectTransform;
	// #endregion
}
