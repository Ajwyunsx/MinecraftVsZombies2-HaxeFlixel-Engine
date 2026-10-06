// Ported from: Assets/Scripts/Vanilla/GameContent/Recharges/VeryLongRecharge.cs
package mvz2.gamecontent.recharges;

import mvz2.vanilla.localization.VanillaStrings;
import pvzengine.definitions.RechargeDefinition;
import pvzengine.seedpacks.EngineRechargeProps;

@:autoRechargeDefinition(VanillaRechargeNames.veryLongTime)
class VeryLongRecharge extends RechargeDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        SetProperty(EngineRechargeProps.START_MAX_RECHARGE, 1050);
        SetProperty(EngineRechargeProps.MAX_RECHARGE, 1500);
        SetProperty(EngineRechargeProps.QUALITY, 6);
        SetProperty(EngineRechargeProps.NAME, VanillaStrings.RECHARGE_VERY_LONG);
    }
}
