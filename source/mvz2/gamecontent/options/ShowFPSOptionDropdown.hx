// Ported from: Assets/Scripts/Logic/Options/Definitions/ShowFPSOptionDropdown.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.localization.LogicStrings;
import mvz2logic.options.IOptionContext;
import mvz2logic.options.LogicOptionItemID;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionDropdownDefinition;
using mvz2logic.options.LogicOptionExt;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.showFPS)
class ShowFPSOptionDropdown extends OptionDropdownDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function GetValue(context:IOptionContext):Int
	{
		return Global.Options.GetFPSMode();
	}
	public override function FillItems(context:IOptionContext, items:Array<String>):Void
	{
		var localization = Global.Localization;
		items.push(localization.GetTextParticular(FPS_MODE_DISABLED, LogicStrings.CONTEXT_FPS_MODE));
		items.push(localization.GetTextParticular(FPS_MODE_TOP_LEFT, LogicStrings.CONTEXT_FPS_MODE));
		items.push(localization.GetTextParticular(FPS_MODE_TOP_RIGHT, LogicStrings.CONTEXT_FPS_MODE));
		items.push(localization.GetTextParticular(FPS_MODE_BOTTOM_LEFT, LogicStrings.CONTEXT_FPS_MODE));
		items.push(localization.GetTextParticular(FPS_MODE_BOTTOM_RIGHT, LogicStrings.CONTEXT_FPS_MODE));
	}
	public override function OnValueChanged(context:IOptionContext, index:Int):Void
	{
		Global.Options.SetOptionInt(LogicOptionItemID.fpsMode, index);
		Global.Options.SaveOptions();
	}
	// [TranslateMsg("FPS模式", LogicStrings.CONTEXT_FPS_MODE)]
	public static inline var FPS_MODE_DISABLED:String = "关闭";
	// [TranslateMsg("FPS模式", LogicStrings.CONTEXT_FPS_MODE)]
	public static inline var FPS_MODE_TOP_LEFT:String = "左上";
	// [TranslateMsg("FPS模式", LogicStrings.CONTEXT_FPS_MODE)]
	public static inline var FPS_MODE_TOP_RIGHT:String = "右上";
	// [TranslateMsg("FPS模式", LogicStrings.CONTEXT_FPS_MODE)]
	public static inline var FPS_MODE_BOTTOM_LEFT:String = "左下";
	// [TranslateMsg("FPS模式", LogicStrings.CONTEXT_FPS_MODE)]
	public static inline var FPS_MODE_BOTTOM_RIGHT:String = "右下";
}
