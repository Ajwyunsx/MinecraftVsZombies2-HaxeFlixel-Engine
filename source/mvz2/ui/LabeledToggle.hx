// Ported from: Assets/Scripts/View/Widgets/LabeledToggle.cs
package mvz2.ui;

import unity.tmpro.TextMeshProUGUI;
import unity.ui.Toggle;
import unity.MonoBehaviour;
import unity.ui.Text;

class LabeledToggle extends unity.MonoBehaviour implements IOptionsDialogElement
{
	public var Text(get, never):TextMeshProUGUI;
	function get_Text():TextMeshProUGUI return text;
	public var Toggle(get, never):Toggle;
	function get_Toggle():Toggle return toggle;
	@:serializeField
	private var text:TextMeshProUGUI;
	@:serializeField
	private var toggle:Toggle;
}
