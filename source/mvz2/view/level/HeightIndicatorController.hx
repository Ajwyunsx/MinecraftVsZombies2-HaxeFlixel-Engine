// Ported from: Assets/Scripts/View/Level/HeightIndicatorController.cs
package mvz2.view.level;

import unity.Color;
import unity.SpriteRenderer;
import unity.Vector2;
import unity.MonoBehaviour;

class HeightIndicatorController extends unity.MonoBehaviour
{
	public function SetHeight(value:Float):Void
	{
		indicatorRenderer.size = new Vector2(indicatorRenderer.size.x, value);
	}
	public function SetColor(color:Color):Void
	{
		indicatorRenderer.color = color;
	}
	@:serializeField
	private var indicatorRenderer:SpriteRenderer;
}
