// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/States/ReverseSatellite_StateBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import pvzengine.entities.Entity;
import mvz2.gamecontent.enemies.EnemyStateBehaviour;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.reverseSatellite_State)
class ReverseSatellite_StateBehaviour extends EnemyStateBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function GetActiveState(enemy:Entity):Int
    {
        if (ReverseSatellite.IsLeft(enemy))
        {
            return EnemyStateBehaviour.STATE_LEAVE;
        }
        return EnemyStateBehaviour.STATE_WALK;
    }
}
