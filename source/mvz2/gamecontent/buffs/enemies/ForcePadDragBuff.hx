// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter2/ForcePadDragBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.modifiers.VanillaModifierPriorities;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Enemy_forcePadDrag)
class ForcePadDragBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(EngineEntityProps.VELOCITY_DAMPEN, NumberOperator.Set, Vector3.one, VanillaModifierPriorities.FORCE));
        AddModifier(new FloatModifier(EngineEntityProps.GRAVITY, NumberOperator.Set, 0, VanillaModifierPriorities.FORCE));
    }
}
