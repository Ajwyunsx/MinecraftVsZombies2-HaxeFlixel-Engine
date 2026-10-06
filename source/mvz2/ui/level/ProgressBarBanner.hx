// Ported from: Assets/Scripts/View/Level/ProgressBarBanner.cs
package mvz2.ui.level;

import unity.Mathf;
import unity.RectTransform;
import unity.MonoBehaviour;

class ProgressBarBanner extends unity.MonoBehaviour
{
	public function SetRiseProgress(progress:Float):Void
	{
		var sizeDelta = pole.sizeDelta;
		sizeDelta.y = Mathf.Lerp(startY, endY, progress);
		pole.sizeDelta = sizeDelta;
	}
	@:serializeField
	private var pole:RectTransform;
	@:serializeField
	private var startY:Float;
	@:serializeField
	private var endY:Float;
}
