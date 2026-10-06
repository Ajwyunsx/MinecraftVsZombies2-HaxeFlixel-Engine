// Ported from: Assets/Scripts/MVZ2/Level/Blueprints/ChosenBlueprintController.cs
package mvz2.level;

import mvz2.ui.Blueprint;
import mvz2.ui.Tooltip.TooltipContent;
import mvz2logic.blueprints.BlueprintChooseItem;
import mvz2logic.saves.BlueprintChooseSaveItem;
import pvzengine.NamespaceID;
import pvzengine.seedpacks.SeedDefinition;
import unity.Debug;
import unity.eventsystems.PointerEventData;
import mvz2.managers.ResourceManager;
import mvz2.ui.Tooltip;
import mvz2.gamecontent.contraptions.CommandBlock;
import pvzengine.base.Definition;
import Main;

class ChosenBlueprintController extends BlueprintController
{
	// #region 生命周期
	public function Init(controller:ILevelController, blueprint:Blueprint, index:Int, definition:SeedDefinition):Void
	{
		Definition = definition;
		InitBlueprint(controller, blueprint, index);
		ui.gameObject.name = definition.GetID().toString();
		ui.SetDisabled(false);
		ui.SetRecharge(0);
		ui.SetSelected(false);
		ui.SetTwinkleAlpha(0);
	}
	override function OnActive():Void
	{
		super.OnActive();
		ui.OnSelect.add(OnPointerSelectCallback);
	}
	override function OnDeactive():Void
	{
		super.OnDeactive();
		ui.OnSelect.remove(OnPointerSelectCallback);
	}
	// #endregion

	// #region UI
	override public function GetTooltipViewData():TooltipContent
	{
		var tooltip = super.GetTooltipViewData();
		var id = Definition.GetID();
		tooltip.error = Controller.BlueprintChoosePart.GetChosenBlueprintTooltipError(Index);
		tooltip.description = Main.ResourceManager.GetBlueprintTooltip(id);
		return tooltip;
	}
	// #endregion

	// #region 事件回调
	private function OnPointerSelectCallback(blueprint:Blueprint, eventData:PointerEventData):Void
	{
		if (!Controller.ChooseBlueprintsInteractable())
			return;
		Controller.BlueprintChoosePart.UnchooseBlueprint(Index);
	}
	// #endregion

	override public function GetSeedDefinition():SeedDefinition
	{
		return Definition;
	}
	override public function IsCommandBlock():Bool
	{
		return CommandBlock;
	}
	public function GetDefinitionID():NamespaceID return Definition.GetID();
	public function ToChooseItem():BlueprintChooseItem
	{
		return new BlueprintChooseItem(GetDefinitionID(), CommandBlock, Innate);
	}
	public function ToChooseSaveItem():BlueprintChooseSaveItem
	{
		return new BlueprintChooseSaveItem(GetDefinitionID(), CommandBlock);
	}
	public function CompareChooseItem(item:BlueprintChooseItem):Bool
	{
		return item.id == Definition.GetID() && CommandBlock == item.isCommandBlock;
	}
	public function CompareChooseSaveItem(item:BlueprintChooseSaveItem):Bool
	{
		return item.id == Definition.GetID() && CommandBlock == item.isCommandBlock;
	}
	public var Innate(default, set):Bool;
	function set_Innate(v:Bool):Bool return Innate = v;
	public var CommandBlock(default, set):Bool;
	function set_CommandBlock(v:Bool):Bool return CommandBlock = v;
	public var Definition(default, null):SeedDefinition = null;
}
