// Ported from: Assets/Scripts/View/Dialogs/Dialog.cs
package mvz2.ui;

import unity.RectTransform;
import unity.Vector2;
import unity.MonoBehaviour;

// abstract
class Dialog extends unity.MonoBehaviour
{
	public function ResetPosition():Void
	{
		dialogTransform.anchoredPosition = Vector2.zero;
	}
	@:serializeField
	private var dialogTransform:RectTransform;
}
