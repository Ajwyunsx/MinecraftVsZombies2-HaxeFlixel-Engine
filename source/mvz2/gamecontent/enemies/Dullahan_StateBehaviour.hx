// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/States/Dullahan_StateBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
import mvz2.gamecontent.enemies.EnemyStateBehaviour;
using mvz2logic.contents.enemies.LogicEnemyExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.dullahan_State)
class Dullahan_StateBehaviour extends EnemyStateBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function GetActiveState(enemy:Entity):Int
    {
        var baseState = super.GetActiveState(enemy);
        if (baseState == EnemyStateBehaviour.STATE_WALK)
        {
            var horse = enemy.GetRidingEntity();
            var hasHorse = horse.ExistsAndAlive();
            if (hasHorse)
            {
                return EnemyStateBehaviour.STATE_IDLE;
            }
        }
        return baseState;
    }
}
