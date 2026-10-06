// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Motion/EnemyWalkBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEnemyStates;
import pvzengine.entities.Entity;
using mvz2.vanilla.enemies.VanillaEnemyExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.enemyWalk)
class EnemyWalkBehaviour extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (entity.State == STATE_WALK)
        {
            entity.UpdateWalkVelocity();
        }
    }
    public static inline var STATE_WALK:Int = LogicEnemyStates.WALK;
}
