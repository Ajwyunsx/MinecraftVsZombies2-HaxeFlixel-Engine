// Ported from: Assets/Scripts/Logic/Options/Definitions/HPBarsHoverDisplayRangeOptionSlider.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.options.IOptionContext;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionSliderDefinition;
import unity.Mathf;
using mvz2logic.saves.LogicSaveExt;
using mvz2logic.options.LogicOptionExt;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.hpBarsHoverDisplayRange)
class HPBarsHoverDisplayRangeOptionSlider extends OptionSliderDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function ShouldEnable(context:IOptionContext):Bool
	{
		return Global.Saves.IsHPBarUnlocked() || Global.Debugs.CanUseDebugFeatures();
	}

	public override function GetValue(context:IOptionContext):Float
	{
		return Global.Options.GetHPBarHoverDisplayRange();
	}

	public override function GetLabelValue(context:IOptionContext, value:Float):String
	{
		return Std.string(Mathf.RoundToInt(value));
	}

	public override function OnValueChanged(context:IOptionContext, value:Float):Void
	{
		Global.Options.SetHPBarHoverDisplayRange(value);
	}

	public override function OnEndEdit(context:IOptionContext, value:Float):Void
	{
		Global.Options.SetHPBarHoverDisplayRange(value);
		Global.Options.SaveOptions();
	}
}
