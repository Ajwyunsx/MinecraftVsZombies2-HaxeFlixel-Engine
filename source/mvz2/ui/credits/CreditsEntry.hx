// Ported from: Assets/Scripts/View/Credits/CreditsEntry.cs
package mvz2.ui.credits;

import unity.tmpro.TextMeshProUGUI;
import unity.MonoBehaviour;

class CreditsEntry extends unity.MonoBehaviour
{
	public function UpdateEntry(name:String):Void
	{
		nameText.text = name;
	}

	@:serializeField
	private var nameText:TextMeshProUGUI;
}
