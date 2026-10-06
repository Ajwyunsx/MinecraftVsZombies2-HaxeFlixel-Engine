// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/States/Spider_StateBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.enemies.VanillaEnemyStates;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.spider_State)
class Spider_StateBehaviour extends EnemyStateBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function GetActiveState(enemy:Entity):Int
    {
        if (Spider.IsClimbingVertically(enemy))
        {
            return STATE_CLIMB;
        }
        return super.GetActiveState(enemy);
    }
    public static inline var STATE_CLIMB:Int = VanillaEnemyStates.SPIDER_CLIMB;
}
