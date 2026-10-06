// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Effects/Chapter2/BreakoutBoardUpgradeBuff.cs
package mvz2.gamecontent.buffs.effects;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Effect_breakoutBoardUpgrade)
class BreakoutBoardUpgradeBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(EngineEntityProps.SIZE, NumberOperator.Add, new Vector3(0, 0, 80)));
        AddModifier(new Vector3Modifier(LogicEntityProps.SHADOW_SCALE, NumberOperator.Add, new Vector3(0, 1, 0)));
    }
}
