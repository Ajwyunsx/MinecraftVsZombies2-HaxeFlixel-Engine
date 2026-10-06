// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/SeedPacks/Chapter6/ControlRodRechargeBuff.cs
package mvz2.gamecontent.buffs.seedpacks;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import pvzengine.definitions.BuffDefinition;
import pvzengine.level.EngineSeedProps;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaBuffNames.SeedPack_controlRodRecharge)
class ControlRodRechargeBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(EngineSeedProps.RECHARGE_SPEED, NumberOperator.Multiply, 1.5));
    }
}
