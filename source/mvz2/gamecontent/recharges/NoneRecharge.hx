// Ported from: Assets/Scripts/Vanilla/GameContent/Recharges/NoneRecharge.cs
package mvz2.gamecontent.recharges;

import mvz2.vanilla.localization.VanillaStrings;
import pvzengine.definitions.RechargeDefinition;
import pvzengine.seedpacks.EngineRechargeProps;

@:autoRechargeDefinition(VanillaRechargeNames.none)
class NoneRecharge extends RechargeDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        SetProperty(EngineRechargeProps.START_MAX_RECHARGE, 0);
        SetProperty(EngineRechargeProps.MAX_RECHARGE, 0);
        SetProperty(EngineRechargeProps.NAME, VanillaStrings.RECHARGE_NONE);
    }
}
