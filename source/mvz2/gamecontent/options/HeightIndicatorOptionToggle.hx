// Ported from: Assets/Scripts/Logic/Options/Definitions/HeightIndicatorOptionToggle.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.options.IOptionContext;
import mvz2logic.options.LogicOptionItemID;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionToggleDefinition;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.heightIndicator)
class HeightIndicatorOptionToggle extends OptionToggleDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function GetValue(context:IOptionContext):Bool
	{
		return Global.Options.GetOptionBool(LogicOptionItemID.heightIndicator);
	}

	public override function OnValueChanged(context:IOptionContext, value:Bool):Void
	{
		Global.Options.SetOptionBool(LogicOptionItemID.heightIndicator, value);
		Global.Options.SaveOptions();
	}
}
