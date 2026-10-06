// Ported from: Assets/Scripts/Logic/Options/Widgets/OptionDropdownDefinition.cs
package mvz2logic.options;

// abstract
class OptionDropdownDefinition extends OptionWidgetDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function GetItemType():OptionWidgetType
	{
		return OptionWidgetType.Dropdown;
	}
	// abstract
	public function FillItems(context:IOptionContext, items:Array<String>):Void
	{
		throw "abstract";
	}
	// abstract
	public function GetValue(context:IOptionContext):Int
	{
		throw "abstract";
	}
	// abstract
	public function OnValueChanged(context:IOptionContext, index:Int):Void
	{
		throw "abstract";
	}
}
