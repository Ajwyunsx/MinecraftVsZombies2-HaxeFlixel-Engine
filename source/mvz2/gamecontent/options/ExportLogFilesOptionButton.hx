// Ported from: Assets/Scripts/Logic/Options/Definitions/ExportLogFilesOptionButton.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionButtonDefinition;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.exportLogFiles)
class ExportLogFilesOptionButton extends OptionButtonDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function OnClick():Void
	{
		Global.Debugs.ExportLogFiles();
	}
}
