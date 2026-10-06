// Ported from: Assets/Scripts/Logic/Options/Definitions/CreditsOptionButton.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.options.IOptionContext;
import mvz2logic.options.IOptionContext.IOptionContextLevel;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionButtonDefinition;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.credits)
class CreditsOptionButton extends OptionButtonDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function ShouldEnable(context:IOptionContext):Bool
	{
		return !Std.isOfType(context, IOptionContextLevel);
	}
	public override function OnClick():Void
	{
		Global.Scene.OpenCreditsPanel();
	}
}
