// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter4/WickedHermitWarppedBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Enemy_wickedHermitWarpped)
class WickedHermitWarppedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(EngineEntityProps.FLIP_X, true));
    }
}
