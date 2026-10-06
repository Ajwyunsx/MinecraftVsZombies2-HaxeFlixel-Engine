// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Boss/Chapter4/TheGiantSnakeBuff.cs
package mvz2.gamecontent.buffs.bosses;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Boss_theGiantSnake)
class TheGiantSnakeBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(EngineEntityProps.SIZE, NumberOperator.Set, Vector3.one * 80));
        AddModifier(new Vector3Modifier(LogicEntityProps.SHADOW_OFFSET, NumberOperator.Set, Vector3.zero));
        AddModifier(new Vector3Modifier(LogicEntityProps.SHADOW_SCALE, NumberOperator.Set, Vector3.one * 2));
    }
}
