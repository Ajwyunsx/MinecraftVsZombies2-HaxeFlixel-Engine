// Ported from: Assets/Scripts/Logic/Options/Definitions/AnimationFrequencyOptionSlider.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.LogicMain;
import mvz2logic.options.IOptionContext;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionSliderDefinition;
using mvz2logic.options.LogicOptionExt;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.animationFrequency)
class AnimationFrequencyOptionSlider extends OptionSliderDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function GetValue(context:IOptionContext):Float
	{
		return Global.Options.GetAnimationFrequency();
	}
	public override function GetLabelValue(context:IOptionContext, value:Float):String
	{
		return LogicMain.GetFloatPercentageText(value);
	}
	public override function OnValueChanged(context:IOptionContext, value:Float):Void
	{
		Global.Options.SetAnimationFrequency(value);
	}

	public override function OnEndEdit(context:IOptionContext, value:Float):Void
	{
		Global.Options.SetAnimationFrequency(value);
		Global.Options.SaveOptions();
	}
}
