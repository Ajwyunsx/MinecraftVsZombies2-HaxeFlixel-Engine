// Ported from: Assets/Scripts/Vanilla/GameContent/Recharges/ShortRecharge.cs
package mvz2.gamecontent.recharges;

import mvz2.vanilla.localization.VanillaStrings;
import pvzengine.definitions.RechargeDefinition;
import pvzengine.seedpacks.EngineRechargeProps;

@:autoRechargeDefinition(VanillaRechargeNames.shortTime)
class ShortRecharge extends RechargeDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        SetProperty(EngineRechargeProps.START_MAX_RECHARGE, 0);
        SetProperty(EngineRechargeProps.MAX_RECHARGE, 225);
        SetProperty(EngineRechargeProps.QUALITY, 1);
        SetProperty(EngineRechargeProps.NAME, VanillaStrings.RECHARGE_SHORT);
    }
}
