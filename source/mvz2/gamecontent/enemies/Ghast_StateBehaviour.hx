// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/States/Ghast_StateBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
import mvz2.gamecontent.enemies.EnemyStateBehaviour;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.ghast_State)
class Ghast_StateBehaviour extends EnemyStateBehaviour
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
