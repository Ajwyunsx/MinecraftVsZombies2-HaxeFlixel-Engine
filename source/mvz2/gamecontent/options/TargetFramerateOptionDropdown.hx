// Ported from: Assets/Scripts/Logic/Options/Definitions/TargetFramerateOptionDropdown.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.localization.LogicStrings;
import mvz2logic.options.IOptionContext;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionDropdownDefinition;
using mvz2logic.options.LogicOptionExt;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.targetFramerate)
class TargetFramerateOptionDropdown extends OptionDropdownDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function GetValue(context:IOptionContext):Int
	{
		var framerate = Global.Options.GetTargetFramerate();
		var index = targetFramerates.indexOf(framerate);
		if (index < 0)
		{
			index = 0;
		}
		return index;
	}
	public override function FillItems(context:IOptionContext, items:Array<String>):Void
	{
		var localization = Global.Localization;
		for (framerate in targetFramerates)
		{
			if (framerate == -1)
			{
				items.push(localization.GetTextParticular(FRAMERATE_DEFAULT, LogicStrings.CONTEXT_TARGET_FRAMERATE));
			}
			else
			{
				items.push(Std.string(framerate));
			}
		}
	}
	public override function OnValueChanged(context:IOptionContext, index:Int):Void
	{
		var framerate = targetFramerates[index];
		Global.Options.SetTargetFramerate(framerate);
		Global.Options.SaveOptions();
	}
	// [TranslateMsg("目标帧率", LogicStrings.CONTEXT_TARGET_FRAMERATE)]
	public static inline var FRAMERATE_DEFAULT:String = "默认";

	public static var targetFramerates:Array<Int> = [
		-1,
		30,
		60,
		90,
		120,
		144
	];
}
