// Ported from: Assets/Scripts/View/Archive/SimulationArchivePage.cs
package mvz2.ui.archive;

import unity.RectTransform;
import unity.Sprite;
import unity.UnityObject;
import unity.Vector3;
import unity.ui.HorizontalOrVerticalLayoutGroup;
import unity.ui.Image;
import unity.ui.HorizontalOrVerticalLayoutGroup.AspectRatioFitter;

class SimulationArchivePage extends ArchivePage
{
	public function SetShake(shake:Vector3):Void
	{
		if (UnityObject.exists(shakeRoot))
		{
			shakeRoot.localPosition = shake;
		}
	}
	public function SetBackground(background:Null<Sprite>):Void
	{
		backgroundImage.sprite = background;
		if (UnityObject.exists(background))
		{
			backgroundRatioFitter.aspectRatio = background.rect.width / background.rect.height;
		}
	}
	@:serializeField
	private var shakeRoot:RectTransform;
	@:serializeField
	private var backgroundImage:Image;
	@:serializeField
	private var backgroundRatioFitter:AspectRatioFitter;
}
