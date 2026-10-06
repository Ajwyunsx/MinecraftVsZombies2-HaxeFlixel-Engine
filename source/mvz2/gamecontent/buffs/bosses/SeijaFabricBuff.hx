// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Boss/Chapter3/SeijaFabricBuff.cs
package mvz2.gamecontent.buffs.bosses;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.modifiers.VanillaModifierPriorities;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Boss_seijaFabric)
class SeijaFabricBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new IntModifier(EngineEntityProps.COLLISION_DETECTION, IntegerOperator.BitOr, EntityCollisionHelper.DETECTION_NO_COLLISION, VanillaModifierPriorities.FORCE));
        AddModifier(new Vector3Modifier(EngineEntityProps.VELOCITY_DAMPEN, NumberOperator.Set, Vector3.one, VanillaModifierPriorities.FORCE));
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
    }
}
