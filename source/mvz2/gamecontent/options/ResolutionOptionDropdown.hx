// Ported from: Assets/Scripts/Logic/Options/Definitions/ResolutionOptionDropdown.cs
package mvz2.gamecontent.options;

import mvz2logic.Global;
import mvz2logic.options.IOptionContext;
import mvz2logic.options.LogicOptionWidgetNames;
import mvz2logic.options.OptionDropdownDefinition;
import unity.Resolution;
import unity.Screen;

@:autoOptionWidgetDefinition(LogicOptionWidgetNames.resolution)
class ResolutionOptionDropdown extends OptionDropdownDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public override function ShouldEnable(context:IOptionContext):Bool
	{
		return !Global.Game.IsMobile();
	}

	public override function FillItems(context:IOptionContext, items:Array<String>):Void
	{
		var resolutions = Screen.resolutions;
		var currentResolution = MakeCurrentResolution();
		var values:Array<Resolution>;
		var hasCurrent = false;
		for (r in resolutions)
		{
			if (CompareResolution(r, currentResolution))
			{
				hasCurrent = true;
				break;
			}
		}
		if (!hasCurrent)
		{
			values = [for (_ in 0...(resolutions.length + 1)) null];
			for (i in 0...resolutions.length)
			{
				values[i] = resolutions[i];
			}
			values[values.length - 1] = currentResolution;
		}
		else
		{
			values = resolutions;
		}
		var texts = [for (v in values) GetResolutionName(v)];
		for (t in texts)
		{
			items.push(t);
		}
	}

	public override function GetValue(context:IOptionContext):Int
	{
		var resolutions = Screen.resolutions;
		var currentResolution = MakeCurrentResolution();
		var index = -1;
		for (i in 0...resolutions.length)
		{
			if (CompareResolution(resolutions[i], currentResolution))
			{
				index = i;
				break;
			}
		}
		if (index < 0)
		{
			index = resolutions.length;
		}
		return index;
	}

	public override function OnValueChanged(context:IOptionContext, index:Int):Void
	{
		var resolutions = Screen.resolutions;
		if (index >= resolutions.length)
			return;
		var resolution = resolutions[index];
		Screen.SetResolution(resolution.width, resolution.height, Screen.fullScreenMode, resolution.refreshRateRatio);
	}
	private static function MakeCurrentResolution():Resolution
	{
		// C#: new Resolution() { width = ..., height = ..., refreshRateRatio = ... }
		var currentResolution = new Resolution();
		currentResolution.width = Screen.width;
		currentResolution.height = Screen.height;
		currentResolution.refreshRateRatio = Screen.currentResolution.refreshRateRatio;
		return currentResolution;
	}
	public static function CompareResolution(res1:Resolution, res2:Resolution):Bool
	{
		if (res1.width != res2.width || res1.height != res2.height)
			return false;
		if (res1.refreshRateRatio.CompareTo(res2.refreshRateRatio) != 0)
			return false;
		return true;
	}
	public static function GetResolutionName(resolution:Resolution):String
	{
		return Global.Localization.GetText(RESOLUTION_NAME, [resolution.width, resolution.height, resolution.refreshRateRatio]);
	}
	// [TranslateMsg("分辨率名，{0}为宽，{1}为高,{2}为刷新率")]
	public static inline var RESOLUTION_NAME:String = "{0}x{1} @{2:0.##}Hz";
}
