// Ported from: Assets/Scripts/Logic/Options/Widgets/OptionToggleDefinition.cs
package mvz2logic.options;

// abstract
class OptionToggleDefinition extends OptionWidgetDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function GetItemType():OptionWidgetType
	{
		return OptionWidgetType.Toggle;
	}
	// abstract
	public function GetValue(context:IOptionContext):Bool
	{
		throw "abstract";
	}
	// abstract
	public function OnValueChanged(context:IOptionContext, value:Bool):Void
	{
		throw "abstract";
	}
}
