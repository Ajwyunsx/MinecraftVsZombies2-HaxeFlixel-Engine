// Ported from: Assets/Scripts/Logic/Options/Widgets/OptionSliderDefinition.cs
package mvz2logic.options;

// abstract
class OptionSliderDefinition extends OptionWidgetDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function GetItemType():OptionWidgetType
	{
		return OptionWidgetType.Slider;
	}
	// abstract
	public function GetValue(context:IOptionContext):Float
	{
		throw "abstract";
	}
	// abstract
	public function GetLabelValue(context:IOptionContext, value:Float):String
	{
		throw "abstract";
	}
	// abstract
	public function OnValueChanged(context:IOptionContext, value:Float):Void
	{
		throw "abstract";
	}
	// abstract
	public function OnEndEdit(context:IOptionContext, value:Float):Void
	{
		throw "abstract";
	}
}
