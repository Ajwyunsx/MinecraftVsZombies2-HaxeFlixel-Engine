// Ported from: Assets/Scripts/View/Level/LevelUIUnit.cs
package mvz2.ui.level;

import unity.MonoBehaviour;
class LevelUIUnit extends unity.MonoBehaviour
{
	public function SetActive(active:Bool):Void
	{
		gameObject.SetActive(active);
	}
}
