// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Boss/Chapter6/LockedChestInvincibleBuff.cs
package mvz2.gamecontent.buffs.bosses;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;

@:autoBuffDefinition(VanillaBuffNames.Boss_lockedChestInvincible)
class LockedChestInvincibleBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new IntModifier(EngineEntityProps.COLLISION_DETECTION, IntegerOperator.BitOr, EntityCollisionHelper.DETECTION_NO_COLLISION));
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
        AddModifier(new BooleanModifier(VanillaEntityProps.INVISIBLE, true));
    }
}
