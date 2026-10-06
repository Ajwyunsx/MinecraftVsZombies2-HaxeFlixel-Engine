// Ported from: Assets/Scripts/View/Almanac/ContraptionAlmanacPage.cs
package mvz2.ui.almanac;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.models.IModelBuilder;
import mvz2.ui.BlueprintDisplayer;
import mvz2.ui.CommandBlockSlot;
import unity.eventsystems.PointerEventData;
import unity.tmpro.TextMeshProUGUI;
import mvz2.ui.BlueprintDisplayer.ChoosingBlueprintViewData;
import flixel.util.FlxSignal;

class ContraptionAlmanacPage extends BookAlmanacPage
{
	public function SetEntries(entries:Array<ChoosingBlueprintViewData>, commandBlockVisible:Bool, commandBlockViewData:ChoosingBlueprintViewData):Void
	{
		blueprintDisplayer.UpdateItems(entries);
		commandBlockSlot.SetCommandBlockActive(commandBlockVisible);
		commandBlockSlot.UpdateCommandBlockItem(commandBlockViewData);
	}
	public function SetActiveEntry(model:IModelBuilder, name:String, description:String, cost:String, recharge:String):Void
	{
		entryModel.ChangeModel(model);
		SetDescription(name, description);
		costText.text = cost;
		rechargeText.text = recharge;
	}
	// protected override
	public override function Awake():Void
	{
		super.Awake();
		blueprintDisplayer.OnBlueprintSelect.add(OnEntryClickCallback);
		commandBlockSlot.OnSelect.add(OnCommandBlockClickCallback);
	}
	private function OnEntryClickCallback(index:Int, eventData:PointerEventData):Void
	{
		OnEntryClick.dispatch(index, eventData);
	}
	private function OnCommandBlockClickCallback(eventData:PointerEventData):Void
	{
		OnCommandBlockClick.dispatch(eventData);
	}
	public var OnEntryClick:FlxTypedSignal<Int->PointerEventData->Void> = new FlxTypedSignal();
	public var OnCommandBlockClick:FlxTypedSignal<PointerEventData->Void> = new FlxTypedSignal();
	@:serializeField
	private var blueprintDisplayer:BlueprintDisplayer;
	@:serializeField
	private var commandBlockSlot:CommandBlockSlot;
	@:serializeField
	private var entryModel:AlmanacModel;
	@:serializeField
	private var costText:TextMeshProUGUI;
	@:serializeField
	private var rechargeText:TextMeshProUGUI;
}
