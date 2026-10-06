// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter3/MiracleMalletReplicaDamageBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaBuffNames.Contraption_miracleMalletReplicaDamage)
class MiracleMalletReplicaDamageBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEntityProps.DAMAGE, NumberOperator.AddMultiple, 0.15));
    }
}
