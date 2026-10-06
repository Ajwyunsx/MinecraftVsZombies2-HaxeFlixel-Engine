// Ported from: Assets/Scripts/Logic/Options/Widgets/OptionWidgetDefinition.cs
package mvz2logic.options;

enum abstract OptionWidgetType(Int)
{
	var Button = 0;
	var Toggle = 1;
	var Dropdown = 2;
	var Slider = 3;
}
