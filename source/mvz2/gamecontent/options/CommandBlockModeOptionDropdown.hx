// Ported from: Assets/Scripts/Logic/Options/Definitions/CommandBlockModeOptionDropdown.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.localization.LogicStrings;
import mvz2logic.options.IOptionContext;
import mvz2logic.options.LogicOptionItemID;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionDropdownDefinition;
using mvz2logic.saves.LogicSaveExt;
using mvz2logic.options.LogicOptionExt;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.commandBlockMode)
class CommandBlockModeOptionDropdown extends OptionDropdownDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function ShouldEnable(context:IOptionContext):Bool
	{
		return Global.Saves.IsCommandBlockUnlocked();
	}
	public override function GetValue(context:IOptionContext):Int
	{
		return Global.Options.GetCommandBlockMode();
	}
	public override function FillItems(context:IOptionContext, items:Array<String>):Void
	{
		var localization = Global.Localization;
		items.push(localization.GetTextParticular(LABEL_MANUAL, LogicStrings.CONTEXT_COMMAND_BLOCK_MODE));
		items.push(localization.GetTextParticular(LABEL_PREVIOUS, LogicStrings.CONTEXT_COMMAND_BLOCK_MODE));
	}
	public override function OnValueChanged(context:IOptionContext, index:Int):Void
	{
		Global.Options.SetOptionInt(LogicOptionItemID.commandBlockMode, index);
		Global.Options.SaveOptions();
	}
	// [TranslateMsg("命令方块模式", LogicStrings.CONTEXT_COMMAND_BLOCK_MODE)]
	public static inline var LABEL_MANUAL:String = "手选";
	// [TranslateMsg("命令方块模式", LogicStrings.CONTEXT_COMMAND_BLOCK_MODE)]
	public static inline var LABEL_PREVIOUS:String = "前位";
}
