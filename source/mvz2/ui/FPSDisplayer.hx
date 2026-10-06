// Ported from: Assets/Scripts/View/FPSDisplayer.cs
package mvz2.ui;

import unity.RectTransform;
import unity.Vector2;
import unity.Vector3;
import unity.tmpro.TextMeshProUGUI;
import unity.MonoBehaviour;

class FPSDisplayer extends unity.MonoBehaviour
{
	public function SetActive(active:Bool):Void
	{
		gameObject.SetActive(active);
	}
	public function SetCorner(corner:Vector2):Void
	{
		rectTransform.pivot = corner;
		rectTransform.anchorMin = corner;
		rectTransform.anchorMax = corner;
		rectTransform.anchoredPosition = new Vector2(0, 0);
	}
	public function SetFPS(text:String):Void
	{
		fpsText.text = text;
	}
	@:serializeField
	private var rectTransform:RectTransform;
	@:serializeField
	private var fpsText:TextMeshProUGUI;
}
