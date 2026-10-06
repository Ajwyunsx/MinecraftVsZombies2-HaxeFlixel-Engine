// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter5/FireworkDispenserEvokedBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NamespaceIDModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.SetOperator;

@:autoBuffDefinition(VanillaBuffNames.Contraption_fireworkDispenserEvoked)
class FireworkDispenserEvokedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEntityProps.RANGE, NumberOperator.Add, 80));
        AddModifier(new NamespaceIDModifier(VanillaEntityProps.PROJECTILE_ID, SetOperator.Set, VanillaProjectileID.fireworkBig));
    }
}
