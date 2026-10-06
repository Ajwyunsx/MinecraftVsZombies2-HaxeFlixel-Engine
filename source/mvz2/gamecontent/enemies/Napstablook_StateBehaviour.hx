// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/States/Napstablook_StateBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.enemies.VanillaEnemyStates;
import pvzengine.entities.Entity;
import mvz2.gamecontent.enemies.EnemyStateBehaviour;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.napstablook_State)
class Napstablook_StateBehaviour extends EnemyStateBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function GetActiveState(enemy:Entity):Int
    {
        if (Napstablook.IsAngry(enemy))
        {
            return STATE_ANGRY;
        }
        return EnemyStateBehaviour.STATE_WALK;
    }
    public static inline var STATE_ANGRY:Int = VanillaEnemyStates.NAPSTABLOOK_ANGRY;
}
