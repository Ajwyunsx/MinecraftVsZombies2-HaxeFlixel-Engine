// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter1/MineTNTInvincibleBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Contraption_mineTNTInvincible)
class MineTNTInvincibleBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
        AddModifier(new BooleanModifier(VanillaEntityProps.CAN_DEACTIVE, false));
    }
}
