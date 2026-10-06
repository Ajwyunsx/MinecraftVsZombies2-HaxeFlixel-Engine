// Ported from: Assets/Scripts/Logic/Options/Widgets/OptionButtonDefinition.cs
package mvz2logic.options;

// abstract
class OptionButtonDefinition extends OptionWidgetDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function GetItemType():OptionWidgetType
	{
		return OptionWidgetType.Button;
	}
	public function GetLabelValue(context:IOptionContext):String return "";
	// abstract
	public function OnClick():Void
	{
		throw "abstract";
	}
}
