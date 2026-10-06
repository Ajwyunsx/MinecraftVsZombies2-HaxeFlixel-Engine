// Ported from: Assets/Scripts/View/Blueprint/CommandBlockSlot.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2logic.inputs.PointerInteraction;
import unity.GameObject;
import unity.UnityObject;
import unity.eventsystems.PointerEventData;
import mvz2.ui.BlueprintDisplayer;
import unity.MonoBehaviour;
import mvz2.ui.BlueprintDisplayer.ChoosingBlueprintViewData;
import flixel.util.FlxSignal;

class CommandBlockSlot extends unity.MonoBehaviour
{
	public function UpdateCommandBlockItem(viewData:ChoosingBlueprintViewData):Void
	{
		var blueprint = commandBlockBlueprint;
		if (UnityObject.exists(blueprint))
		{
			blueprint.UpdateView(viewData.blueprint);
			blueprint.SetDisabled(viewData.disabled);
			blueprint.SetSelected(viewData.selected);
			blueprint.SetRecharge(viewData.recharge);
		}
	}
	public function SetCommandBlockActive(value:Bool):Void
	{
		if (UnityObject.exists(commandBlockRoot))
		{
			commandBlockRoot.SetActive(value);
		}
	}
	public function GetCommandBlockBlueprint():Null<Blueprint>
	{
		return commandBlockBlueprint;
	}
	function Awake():Void
	{
		if (commandBlockBlueprint != null)
		{
			commandBlockBlueprint.OnPointerInteraction.add((blueprint, eventData, i) -> OnPointerInteraction.dispatch(eventData, i));
			commandBlockBlueprint.OnSelect.add((blueprint, data) -> OnSelect.dispatch(data));
		}
	}
	public var OnPointerInteraction:FlxTypedSignal<PointerEventData->PointerInteraction->Void> = new FlxTypedSignal();
	public var OnSelect:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	@:serializeField
	var commandBlockRoot:Null<GameObject>;
	@:serializeField
	var commandBlockBlueprint:Null<Blueprint>;
}
