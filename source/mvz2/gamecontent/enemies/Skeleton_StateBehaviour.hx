// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/States/Skeleton_StateBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
import mvz2.gamecontent.enemies.EnemyStateBehaviour;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.skeleton_State)
class Skeleton_StateBehaviour extends EnemyStateBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function GetActiveState(enemy:Entity):Int
    {
        if (enemy.Target.ExistsAndAlive())
        {
            return EnemyStateBehaviour.STATE_RANGED_ATTACK;
        }
        return super.GetActiveState(enemy);
    }
}
