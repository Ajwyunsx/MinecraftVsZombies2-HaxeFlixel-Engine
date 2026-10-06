// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Debug/DebugNoRechargeBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import pvzengine.definitions.BuffDefinition;
import pvzengine.level.EngineLevelProps;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaBuffNames.Level_debugNoRecharge)
class DebugNoRechargeBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(EngineLevelProps.RECHARGE_SPEED, NumberOperator.Set, 99999999));
    }
}
