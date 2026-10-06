// Ported from: Assets/Scripts/Logic/Contents/GlobalCallbacks/DebugGlobalCallbacks.cs
package mvz2logic.contents.globalcallbacks;

import mvz2logic.callbacks.LogicCallbacks;
import mvz2logic.Global;
import mvz2logic.modding.IGlobalCallbacks;
import mvz2logic.modding.Mod;
import mvz2logic.saves.LogicSaveExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.StringCallbackParams;

@:modGlobalCallbacks
class DebugGlobalCallbacks implements IGlobalCallbacks
{
	public function new() {}
	public function Apply(mod:Mod):Void
	{
		mod.AddTrigger(LogicCallbacks.IS_SPECIAL_USER_NAME, IsSpecialUserNameCallback);
	}
	public function IsSpecialUserNameCallback(param:StringCallbackParams, result:CallbackResult):Void
	{
		var name = param.text;
		if (LogicSaveExt.IsDebugUserName(Global.Saves, name))
		{
			result.SetValue(true);
		}
	}
}
