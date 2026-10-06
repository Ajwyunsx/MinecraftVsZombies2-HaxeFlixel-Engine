// Ported from: Assets/Scripts/Logic/Options/Definitions/LanguageOptionDropdown.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.options.IOptionContext;
import mvz2logic.options.IOptionContext.IOptionContextLevel;
import mvz2logic.options.LogicOptionItemID;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionDropdownDefinition;
import tools.Ref;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.language)
class LanguageOptionDropdown extends OptionDropdownDefinition
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
		return true;
	}
	public override function GetValue(context:IOptionContext):Int
	{
		var codes = Global.Localization.GetAllLanguageCodes();
		var value = new Ref<String>(null);
		var lang = context.TryGetCachedOptionString(LogicOptionItemID.language, value) ? value.value : Global.Localization.GetCurrentLanguage();
		var index = codes.indexOf(lang);
		if (index < 0)
			index = 0;
		return index;
	}
	public override function FillItems(context:IOptionContext, items:Array<String>):Void
	{
		var codes = Global.Localization.GetAllLanguageCodes();
		for (code in codes)
		{
			var label = Global.Localization.GetLanguageName(code);
			items.push(label);
		}
	}
	public override function OnValueChanged(context:IOptionContext, index:Int):Void
	{
		var codes = Global.Localization.GetAllLanguageCodes();
		context.CacheOptionString(LogicOptionItemID.language, codes[index]);
		context.SetNeedReload();
	}
}
