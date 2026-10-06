// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter1/FrankensteinTransformerBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Enemy_frankensteinTransformer)
class FrankensteinTransformerBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(VanillaEntityProps.INVISIBLE, true));
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
    }
}
