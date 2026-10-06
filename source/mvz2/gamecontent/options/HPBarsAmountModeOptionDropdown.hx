// Ported from: Assets/Scripts/Logic/Options/Definitions/HPBarsAmountModeOptionDropdown.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.localization.LogicStrings;
import mvz2logic.options.IOptionContext;
import mvz2logic.options.LogicOptionItemID;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionDropdownDefinition;
using mvz2logic.saves.LogicSaveExt;
using mvz2logic.options.LogicOptionExt;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.hpBarsAmountMode)
class HPBarsAmountModeOptionDropdown extends OptionDropdownDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function ShouldEnable(context:IOptionContext):Bool
	{
		return Global.Saves.IsHPBarUnlocked() || Global.Debugs.CanUseDebugFeatures();
	}
	public override function GetValue(context:IOptionContext):Int
	{
		return Global.Options.GetHPBarAmountMode();
	}
	public override function FillItems(context:IOptionContext, items:Array<String>):Void
	{
		var localization = Global.Localization;
		items.push(localization.GetTextParticular(HP_BARS_AMOUNT_MODE_HIDDEN, LogicStrings.CONTEXT_HP_BARS_AMOUNT_MODE));
		items.push(localization.GetTextParticular(HP_BARS_AMOUNT_MODE_CURRENT_ONLY, LogicStrings.CONTEXT_HP_BARS_AMOUNT_MODE));
		items.push(localization.GetTextParticular(HP_BARS_AMOUNT_MODE_CURRENT_AND_MAX, LogicStrings.CONTEXT_HP_BARS_AMOUNT_MODE));
	}
	public override function OnValueChanged(context:IOptionContext, index:Int):Void
	{
		Global.Options.SetOptionInt(LogicOptionItemID.hpBarAmountMode, index);
		Global.Options.SaveOptions();
	}
	// [TranslateMsg("血条数值模式", LogicStrings.CONTEXT_HP_BARS_AMOUNT_MODE)]
	public static inline var HP_BARS_AMOUNT_MODE_HIDDEN:String = "隐藏";
	// [TranslateMsg("血条数值模式", LogicStrings.CONTEXT_HP_BARS_AMOUNT_MODE)]
	public static inline var HP_BARS_AMOUNT_MODE_CURRENT_ONLY:String = "当前血量";
	// [TranslateMsg("血条数值模式", LogicStrings.CONTEXT_HP_BARS_AMOUNT_MODE)]
	public static inline var HP_BARS_AMOUNT_MODE_CURRENT_AND_MAX:String = "全部";
}
