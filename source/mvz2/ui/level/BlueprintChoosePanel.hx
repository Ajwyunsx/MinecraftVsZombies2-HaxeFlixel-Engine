// Ported from: Assets/Scripts/View/Level/BlueprintChoose/BlueprintChoosePanel.cs
package mvz2.ui.level;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2logic.inputs.PointerInteraction;
import unity.eventsystems.PointerEventData;
import unity.ui.Button;
import mvz2.ui.BlueprintDisplayer;
import mvz2.ui.CommandBlockSlot;
import unity.MonoBehaviour;
import mvz2.ui.BlueprintDisplayer.ChoosingBlueprintViewData;
import flixel.util.FlxSignal;

class BlueprintChoosePanel extends unity.MonoBehaviour
{
	public function UpdateElements(viewData:BlueprintChoosePanelViewData):Void
	{
		viewLawnButton.gameObject.SetActive(viewData.canViewLawn);
		repickButton.gameObject.SetActive(viewData.canRepick);
		commandBlockSlot.SetCommandBlockActive(viewData.hasCommandBlock);
	}
	public function UpdateCommandBlockItem(viewData:ChoosingBlueprintViewData):Void
	{
		commandBlockSlot.UpdateCommandBlockItem(viewData);
	}
	public function UpdateItems(viewDatas:Array<ChoosingBlueprintViewData>):Void
	{
		displayer.UpdateItems(viewDatas);
	}
	public function GetItem(index:Int):Null<Blueprint>
	{
		return displayer.GetItem(index);
	}
	public function GetCommandBlockBlueprintItem():Null<Blueprint>
	{
		return commandBlockSlot != null ? commandBlockSlot.GetCommandBlockBlueprint() : null;
	}
	function Awake():Void
	{
		startButton.onClick.AddListener(() -> OnStartButtonClick.dispatch());
		viewLawnButton.onClick.AddListener(() -> OnViewLawnButtonClick.dispatch());
		cancelButton.onClick.AddListener(() -> OnCancelButtonClick.dispatch());
		repickButton.onClick.AddListener(() -> OnRepickButtonClick.dispatch());
		displayer.OnBlueprintPointerInteraction.add((index, data, i) -> OnBlueprintPointerInteraction.dispatch(index, data, i));
		displayer.OnBlueprintSelect.add((index, data) -> OnBlueprintSelect.dispatch(index, data));
		commandBlockSlot.OnPointerInteraction.add((e, i) -> OnCommandBlockBlueprintPointerInteraction.dispatch(e, i));
		commandBlockSlot.OnSelect.add((data) -> OnCommandBlockBlueprintSelect.dispatch(data));
	}
	private function CallBlueprintPointerInteraction(index:Int, eventData:PointerEventData, interaction:PointerInteraction):Void
	{
		OnBlueprintPointerInteraction.dispatch(index, eventData, interaction);
	}
	public var OnStartButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnViewLawnButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnCancelButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnRepickButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	public var OnCommandBlockBlueprintPointerInteraction:FlxTypedSignal<PointerEventData->PointerInteraction->Void> = new FlxTypedSignal();
	public var OnCommandBlockBlueprintSelect:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	public var OnBlueprintPointerInteraction:FlxTypedSignal<Int->PointerEventData->PointerInteraction->Void> = new FlxTypedSignal();
	public var OnBlueprintSelect:FlxTypedSignal<Int->PointerEventData->Void> = new FlxTypedSignal();
	@:serializeField
	var startButton:Button;
	@:serializeField
	var viewLawnButton:Button;
	@:serializeField
	var cancelButton:Button;
	@:serializeField
	var repickButton:Button;
	@:serializeField
	var displayer:BlueprintDisplayer;
	@:serializeField
	var commandBlockSlot:CommandBlockSlot;
}

// C# 中为 MVZ2.UI.Level 的 BlueprintChoosePanelViewData 结构体。
class BlueprintChoosePanelViewData
{
	public var canViewLawn:Bool;
	public var hasCommandBlock:Bool;
	public var canRepick:Bool;

	public function new() {}
}
