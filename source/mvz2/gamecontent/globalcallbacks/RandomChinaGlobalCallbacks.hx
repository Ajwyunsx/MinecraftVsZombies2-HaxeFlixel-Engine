// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/RandomChinaGlobalCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.vanilla.game.VanillaGameExt;
import mvz2logic.Global;
import pvzengine.callbacks.EmptyCallbackParams;
import mvz2logic.callbacks.LogicCallbacks;
import pvzengine.callbacks.StringCallbackParams;
import mvz2logic.modding.Mod;
import pvzengine.callbacks.CallbackResult;

@:modGlobalCallbacks
class RandomChinaGlobalCallbacks extends VanillaGlobalCallbacks
{
    public override function Apply(mod:Mod):Void
    {
        mod.AddTrigger(LogicCallbacks.IS_SPECIAL_USER_NAME, IsSpecialUserNameCallback);
        mod.AddTrigger(LogicCallbacks.GET_BLUEPRINT_SLOT_COUNT, GetBlueprintSlotCountCallback);
        mod.AddTrigger(LogicCallbacks.GET_INNATE_BLUEPRINTS, GetInnateBlueprintsCallback);
    }
    public function IsSpecialUserNameCallback(param:StringCallbackParams, result:CallbackResult):Void
    {
        var name = param.text;
        if (VanillaGameExt.IsRandomChinaUserName(Global.Saves, name))
        {
            result.SetValue(true);
        }
    }
    public function GetBlueprintSlotCountCallback(param:EmptyCallbackParams, result:CallbackResult):Void
    {
        if (!VanillaGameExt.IsRandomChina(Global.Saves))
            return;
        var value = result.GetValue();
        result.SetValue(value - 2);
    }
    public function GetInnateBlueprintsCallback(param:GetInnateBlueprintsParams, result:CallbackResult):Void
    {
        if (!VanillaGameExt.IsRandomChina(Global.Saves))
            return;
        param.list.push(VanillaContraptionID.randomChina);
    }
}
