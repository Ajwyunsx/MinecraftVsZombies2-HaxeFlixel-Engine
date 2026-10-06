// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter2/CarryingOtherBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Contraption_carryingOther)
class CarryingOtherBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(VanillaEntityProps.INVISIBLE, true));
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
        AddModifier(new BooleanModifier(VanillaEntityProps.NO_HELD_TARGET, true));
    }
}
