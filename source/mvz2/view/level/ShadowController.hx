// Ported from: Assets/Scripts/View/Level/ShadowController.cs
package mvz2.view.level;

import unity.Color;
import unity.SpriteRenderer;
import unity.MonoBehaviour;

class ShadowController extends unity.MonoBehaviour
{
	public function SetAlpha(value:Float):Void
	{
		var col = shadowRenderer.color;
		shadowRenderer.color = new Color(col.r, col.g, col.b, value);
	}
	@:serializeField
	private var shadowRenderer:SpriteRenderer;
}
