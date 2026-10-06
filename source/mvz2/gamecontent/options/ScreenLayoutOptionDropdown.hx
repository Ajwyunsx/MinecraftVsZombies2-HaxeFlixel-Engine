// Ported from: Assets/Scripts/Logic/Options/Definitions/ScreenLayoutOptionDropdown.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.localization.LogicStrings;
import mvz2logic.options.IOptionContext;
import mvz2logic.options.IOptionContext.IOptionContextLevel;
import mvz2logic.options.LogicOptionItemID;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionDropdownDefinition;
import mvz2logic.options.ScreenLayouts;
import tools.Ref;
using mvz2logic.options.LogicOptionExt;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.screenLayout)
class ScreenLayoutOptionDropdown extends OptionDropdownDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function ShouldEnable(context:IOptionContext):Bool
	{
		if (Std.isOfType(context, IOptionContextLevel))
		{
			return false;
		}
		return super.ShouldEnable(context);
	}
	public override function GetValue(context:IOptionContext):Int
	{
		var value = new Ref<Int>(0);
		var screenLayout = context.TryGetCachedOptionInt(LogicOptionItemID.screenLayout, value) ? value.value : Global.Options.GetScreenLayout();
		var index = screenLayouts.indexOf(screenLayout);
		if (index < 0)
		{
			index = 0;
		}
		return index;
	}
	public override function FillItems(context:IOptionContext, items:Array<String>):Void
	{
		var localization = Global.Localization;
		for (i in 0...screenLayouts.length)
		{
			var text = screenLayoutTexts[i];
			items.push(localization.GetTextParticular(text, LogicStrings.CONTEXT_SCREEN_LAYOUT));
		}
	}
	public override function OnValueChanged(context:IOptionContext, index:Int):Void
	{
		var screenLayout = screenLayouts[index];
		context.CacheOptionInt(LogicOptionItemID.screenLayout, screenLayout);
		context.SetNeedReload();
	}
	// [TranslateMsg("屏幕布局", LogicStrings.CONTEXT_SCREEN_LAYOUT)]
	public static inline var SCREEN_LAYOUT_AUTO:String = "自动";
	// [TranslateMsg("屏幕布局", LogicStrings.CONTEXT_SCREEN_LAYOUT)]
	public static inline var SCREEN_LAYOUT_DESKTOP:String = "桌面";
	// [TranslateMsg("屏幕布局", LogicStrings.CONTEXT_SCREEN_LAYOUT)]
	public static inline var SCREEN_LAYOUT_MOBILE:String = "移动";

	public static var screenLayouts:Array<Int> = [
		ScreenLayouts.AUTO,
		ScreenLayouts.DESKTOP,
		ScreenLayouts.MOBILE,
	];

	public static var screenLayoutTexts:Array<String> = [
		SCREEN_LAYOUT_AUTO,
		SCREEN_LAYOUT_DESKTOP,
		SCREEN_LAYOUT_MOBILE,
	];
}
