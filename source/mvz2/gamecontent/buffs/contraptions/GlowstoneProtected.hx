// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter1/GlowstoneProtected.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Contraption_glowstoneProtected)
class GlowstoneProtected extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(VanillaEntityProps.LOYAL, true));
    }
}
