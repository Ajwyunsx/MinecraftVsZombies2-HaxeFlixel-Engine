// Ported from: Assets/Scripts/Logic/Options/Definitions/VSyncOptionToggle.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.options.IOptionContext;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionToggleDefinition;
using mvz2logic.options.LogicOptionExt;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.vSync)
class VSyncOptionToggle extends OptionToggleDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function ShouldEnable(context:IOptionContext):Bool
	{
		if (Global.Game.IsMobile())
			return false;
		return super.ShouldEnable(context);
	}
	public override function GetValue(context:IOptionContext):Bool
	{
		return Global.Options.GetVSync();
	}

	public override function OnValueChanged(context:IOptionContext, value:Bool):Void
	{
		Global.Options.SetVSync(value);
		Global.Options.SaveOptions();
	}
}
