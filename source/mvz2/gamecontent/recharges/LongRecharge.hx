// Ported from: Assets/Scripts/Vanilla/GameContent/Recharges/LongRecharge.cs
package mvz2.gamecontent.recharges;

import mvz2.vanilla.localization.VanillaStrings;
import pvzengine.definitions.RechargeDefinition;
import pvzengine.seedpacks.EngineRechargeProps;

@:autoRechargeDefinition(VanillaRechargeNames.longTime)
class LongRecharge extends RechargeDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        SetProperty(EngineRechargeProps.START_MAX_RECHARGE, 600);
        SetProperty(EngineRechargeProps.MAX_RECHARGE, 900);
        SetProperty(EngineRechargeProps.QUALITY, 3);
        SetProperty(EngineRechargeProps.NAME, VanillaStrings.RECHARGE_LONG);
    }
}
