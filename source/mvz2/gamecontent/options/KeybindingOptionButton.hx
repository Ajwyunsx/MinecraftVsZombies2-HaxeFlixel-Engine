// Ported from: Assets/Scripts/Logic/Options/Definitions/KeybindingOptionButton.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.options.IOptionContext;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionButtonDefinition;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.keybinding)
class KeybindingOptionButton extends OptionButtonDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function ShouldEnable(context:IOptionContext):Bool
	{
		return !Global.Game.IsMobile();
	}
	public override function OnClick():Void
	{
		Global.Scene.OpenKeybindingPanel();
	}
}
