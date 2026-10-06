// Ported from: Assets/Scripts/View/Archive/ArchivePage.cs
package mvz2.ui.archive;

import unity.MonoBehaviour;
// abstract
class ArchivePage extends unity.MonoBehaviour
{
	public function SetActive(active:Bool):Void
	{
		gameObject.SetActive(active);
	}
}
