// Ported from: Assets/Scripts/MVZ2/Managers/ResolutionManager.cs
package mvz2.cameras;

import mvz2.options.OptionsManager;
import mvz2logic.options.LogicOptionItemID;
import pvzengine.NamespaceID;
import flixel.util.FlxSignal.FlxTypedSignal;
import unity.*;
import unity.Debug;
import unity.MonoBehaviour;
import unity.Resolution;
import unity.Screen;
import flixel.util.FlxSignal;

class ResolutionManager extends MonoBehaviour
{
	public function SetResolution(width:Int, height:Int):Void
	{
		Screen.SetResolution(width, height, Screen.fullScreenMode);
	}
	// TODO-PORT: C# 重载 SetResolution(Resolution resolution)，重命名以区分。
	public function SetResolutionFromRes(resolution:Resolution):Void
	{
		SetResolution(resolution.width, resolution.height);
	}
	public function GetResolutions():Array<Resolution>
	{
		return Screen.resolutions;
	}
	public function GetCurrentResolution():Resolution
	{
		var res = new Resolution();
		res.width = Screen.width;
		res.height = Screen.height;
		return res;
	}
	private function Awake():Void
	{
		OptionsManager.OnOptionChangedBool.add(OnOptionChangedBoolCallback);
	}
	private function OnEnable():Void
	{
		Check();
	}
	private function OnDisable():Void
	{
		lastWidth = 0;
		lastHeight = 0;
	}
	private function Update():Void
	{
		Check();
	}
	private function OnOptionChangedBoolCallback(id:NamespaceID, value:Bool):Void
	{
		if (id == LogicOptionItemID.fullscreen)
		{
			Screen.fullScreen = value;
		}
	}
	private function Check():Void
	{
		if (lastWidth != Screen.width || lastHeight != Screen.height)
		{
			lastWidth = Screen.width;
			lastHeight = Screen.height;
			OnResolutionChanged.dispatch(lastWidth, lastHeight);
		}
	}
	public static var OnResolutionChanged:FlxTypedSignal<Int->Int->Void> = new FlxTypedSignal<Int->Int->Void>();

	private var lastWidth:Int;
	private var lastHeight:Int;
}
