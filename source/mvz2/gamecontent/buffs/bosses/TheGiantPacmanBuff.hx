// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Boss/Chapter4/TheGiantPacmanBuff.cs
package mvz2.gamecontent.buffs.bosses;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Boss_theGiantPacman)
class TheGiantPacmanBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(EngineEntityProps.SIZE, NumberOperator.Set, Vector3.one * 240));
    }
}
