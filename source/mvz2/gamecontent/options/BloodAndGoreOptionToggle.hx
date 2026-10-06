// Ported from: Assets/Scripts/Logic/Options/Definitions/BloodAndGoreOptionToggle.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.options.IOptionContext;
import mvz2logic.options.IOptionContext.IOptionContextLevel;
import mvz2logic.options.LogicOptionItemID;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionToggleDefinition;
import tools.Ref;
using mvz2logic.options.LogicOptionExt;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.bloodAndGore)
class BloodAndGoreOptionToggle extends OptionToggleDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function ShouldEnable(context:IOptionContext):Bool
	{
		return !Std.isOfType(context, IOptionContextLevel);
	}
	public override function GetValue(context:IOptionContext):Bool
	{
		var value = new Ref<Bool>(false);
		return context.TryGetCachedOptionBool(LogicOptionItemID.showHotkeys, value) ? value.value : Global.Options.HasBloodAndGore();
	}

	public override function OnValueChanged(context:IOptionContext, value:Bool):Void
	{
		context.CacheOptionBool(LogicOptionItemID.bloodAndGore, value);
		context.SetNeedReload();
	}
}
