// Ported from: Assets/Scripts/View/Level/StarshardPanelPoint.cs
package mvz2.ui.level;

import unity.GameObject;
import unity.MonoBehaviour;

class StarshardPanelPoint extends unity.MonoBehaviour
{
	public function SetHighlight(highlight:Bool):Void
	{
		darkGameObject.SetActive(!highlight);
		highlightGameObject.SetActive(highlight);
	}
	@:serializeField
	private var darkGameObject:GameObject;
	@:serializeField
	private var highlightGameObject:GameObject;
}
