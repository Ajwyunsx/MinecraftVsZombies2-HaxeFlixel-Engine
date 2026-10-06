// Ported from: Assets/Scripts/Logic/Options/Widgets/OptionWidgetDefinition.cs
package mvz2logic.options;

import mvz2logic.definitions.LogicDefinitionTypes;
import pvzengine.base.Definition;

// abstract
class OptionWidgetDefinition extends Definition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public function ShouldEnable(context:IOptionContext):Bool return true;
	// abstract
	public function GetItemType():OptionWidgetType
	{
		throw "abstract";
	}
	public override function GetDefinitionType():String
	{
		return LogicDefinitionTypes.OPTION_WIDGET;
	}
}
