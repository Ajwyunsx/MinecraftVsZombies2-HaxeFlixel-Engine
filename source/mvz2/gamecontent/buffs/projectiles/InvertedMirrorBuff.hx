// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Projectiles/Chapter3/InvertedMirrorBuff.cs
package mvz2.gamecontent.buffs.projectiles;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaFactions;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;

@:autoBuffDefinition(VanillaBuffNames.Projectile_invertedMirror)
class InvertedMirrorBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new IntModifier(EngineEntityProps.FACTION, IntegerOperator.Set, VanillaFactions.NEUTRAL));
    }
}
