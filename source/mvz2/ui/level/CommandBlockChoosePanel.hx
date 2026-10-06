// Ported from: Assets/Scripts/View/Level/BlueprintChoose/CommandBlockChoosePanel.cs
package mvz2.ui.level;

import mvz2.ui.BlueprintDisplayer;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2logic.inputs.PointerInteraction;
import unity.eventsystems.PointerEventData;
import unity.ui.Button;
import unity.MonoBehaviour;
import mvz2.ui.BlueprintDisplayer.ChoosingBlueprintViewData;
import flixel.util.FlxSignal;

class CommandBlockChoosePanel extends unity.MonoBehaviour
{
	public function UpdateItems(viewDatas:Array<ChoosingBlueprintViewData>):Void
	{
		displayer.UpdateItems(viewDatas);
	}
	public function GetItem(index:Int):Null<Blueprint>
	{
		return displayer.GetItem(index);
	}
	function Awake():Void
	{
		cancelButton.onClick.AddListener(() -> OnCancelButtonClick.dispatch());
		displayer.OnBlueprintPointerInteraction.add((index, data, i) -> OnBlueprintPointerInteraction.dispatch(index, data, i));
		displayer.OnBlueprintSelect.add((index, data) -> OnBlueprintSelect.dispatch(index, data));
	}
	public var OnCancelButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnBlueprintPointerInteraction:FlxTypedSignal<Int->PointerEventData->PointerInteraction->Void> = new FlxTypedSignal();
	public var OnBlueprintSelect:FlxTypedSignal<Int->PointerEventData->Void> = new FlxTypedSignal();
	@:serializeField
	var cancelButton:Button;
	@:serializeField
	var displayer:BlueprintDisplayer;
}
