// Ported from: Assets/Scripts/View/Widgets/TextSlider.cs
package mvz2.ui;

import unity.tmpro.TextMeshProUGUI;
import unity.ui.Slider;
import unity.MonoBehaviour;
import unity.ui.Text;

class TextSlider extends unity.MonoBehaviour implements IOptionsDialogElement
{
	public var Text(get, never):TextMeshProUGUI;
	function get_Text():TextMeshProUGUI return text;
	public var Slider(get, never):Slider;
	function get_Slider():Slider return slider;
	public var EndHandler(get, never):Null<SliderEndHandler>;
	function get_EndHandler():Null<SliderEndHandler> return endHandler;
	@:serializeField
	private var text:TextMeshProUGUI;
	@:serializeField
	private var slider:Slider;
	@:serializeField
	private var endHandler:Null<SliderEndHandler>;
}
