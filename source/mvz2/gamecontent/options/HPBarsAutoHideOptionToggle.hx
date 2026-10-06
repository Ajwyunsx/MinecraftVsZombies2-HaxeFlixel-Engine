// Ported from: Assets/Scripts/Logic/Options/Definitions/HPBarsAutoHideOptionToggle.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.options.IOptionContext;
import mvz2logic.options.LogicOptionItemID;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionToggleDefinition;
using mvz2logic.saves.LogicSaveExt;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.hpBarsAutoHide)
class HPBarsAutoHideOptionToggle extends OptionToggleDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function ShouldEnable(context:IOptionContext):Bool
	{
		return Global.Saves.IsHPBarUnlocked() || Global.Debugs.CanUseDebugFeatures();
	}
	public override function GetValue(context:IOptionContext):Bool
	{
		return Global.Options.GetOptionBool(LogicOptionItemID.hpBarAutoHide);
	}

	public override function OnValueChanged(context:IOptionContext, value:Bool):Void
	{
		Global.Options.SetOptionBool(LogicOptionItemID.hpBarAutoHide, value);
		Global.Options.SaveOptions();
	}
}
