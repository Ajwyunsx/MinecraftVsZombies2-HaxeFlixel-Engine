// Ported from: Assets/Scripts/View/Dialogs/InputNameDialog.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.tmpro.TMP_InputField;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Button;
import flixel.util.FlxSignal;

class InputNameDialog extends Dialog
{
	public function SetErrorMessage(error:String):Void
	{
		errorMessage.text = error;
	}
	public function ClearContent():Void
	{
		inputField.text = "";
	}
	private function Awake():Void
	{
		confirmButton.onClick.AddListener(() -> OnConfirm.dispatch(inputField.text));
		cancelButton.onClick.AddListener(() -> OnCancel.dispatch());
	}
	public var OnConfirm:FlxTypedSignal<String->Void> = new FlxTypedSignal();
	public var OnCancel:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	@:serializeField
	private var errorMessage:TextMeshProUGUI;
	@:serializeField
	private var inputField:TMP_InputField;
	@:serializeField
	private var confirmButton:Button;
	@:serializeField
	private var cancelButton:Button;
}
