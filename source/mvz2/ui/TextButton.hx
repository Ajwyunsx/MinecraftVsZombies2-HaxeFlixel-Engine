// Ported from: Assets/Scripts/View/Widgets/TextButton.cs
package mvz2.ui;

import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import unity.MonoBehaviour;
import unity.ui.Text;

class TextButton extends unity.MonoBehaviour implements IOptionsDialogElement
{
	public var Text(get, never):TextMeshProUGUI;
	function get_Text():TextMeshProUGUI return text;
	public var Button(get, never):Button;
	function get_Button():Button return button;
	@:serializeField
	private var text:TextMeshProUGUI;
	@:serializeField
	private var button:Button;
}
