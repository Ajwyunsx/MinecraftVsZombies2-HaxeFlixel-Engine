// Ported from: Assets/Scripts/View/Widgets/LabeledDropdown.cs
package mvz2.ui;

import unity.tmpro.TMP_Dropdown;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Dropdown;
import unity.MonoBehaviour;
import unity.ui.Text;

class LabeledDropdown extends unity.MonoBehaviour implements IOptionsDialogElement
{
	public var Text(get, never):TextMeshProUGUI;
	function get_Text():TextMeshProUGUI return text;
	public var Dropdown(get, never):TMP_Dropdown;
	function get_Dropdown():TMP_Dropdown return dropdown;
	@:serializeField
	private var text:TextMeshProUGUI;
	@:serializeField
	private var dropdown:TMP_Dropdown;
}
