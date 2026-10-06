// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Animation/EnemyAnimationBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2logic.entities.IEnemyAnimationBehaviour;
import mvz2logic.entities.LogicEnemyStates;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

// abstract
class EnemyAnimationBehaviour extends EntityBehaviourDefinition implements IEnemyAnimationBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        UpdateAnimationParameters(entity, entity.State);
    }
    public function UpdateAnimationParameters(entity:Entity, state:Int):Void throw "abstract"; // abstract
    public static inline var STATE_IDLE:Int = LogicEnemyStates.IDLE;
    public static inline var STATE_WALK:Int = LogicEnemyStates.WALK;
    public static inline var STATE_MELEE_ATTACK:Int = LogicEnemyStates.MELEE_ATTACK;
    public static inline var STATE_CAST:Int = LogicEnemyStates.CAST;
    public static inline var STATE_DEATH:Int = LogicEnemyStates.DEATH;
    public static inline var STATE_RANGED_ATTACK:Int = LogicEnemyStates.RANGED_ATTACK;
    public static inline var STATE_LEAVE:Int = LogicEnemyStates.LEAVE;
}
