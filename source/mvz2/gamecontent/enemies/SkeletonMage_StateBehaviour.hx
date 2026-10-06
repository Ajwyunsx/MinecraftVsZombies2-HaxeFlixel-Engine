// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/States/SkeletonMage_StateBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
import mvz2.gamecontent.enemies.EnemyStateBehaviour;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.skeletonMage_State)
class SkeletonMage_StateBehaviour extends EnemyStateBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function GetActiveState(enemy:Entity):Int
    {
        var state = super.GetActiveState(enemy);
        if (enemy.Target.ExistsAndAlive())
        {
            var attackState = SkeletonMage.GetAttackState(enemy);
            if (attackState == SkeletonMage.ATTACK_STATE_CAST)
            {
                state = EnemyStateBehaviour.STATE_CAST;
            }
            else
            {
                state = EnemyStateBehaviour.STATE_RANGED_ATTACK;
            }
        }
        return state;
    }
}
