// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/States/EnemyStateBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEnemyStates;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.enemies.VanillaEnemyProps;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEnemyProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.enemyState)
class EnemyStateBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    // C#: public override sealed void Update(Entity entity)
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var passiveState = GetPassiveState(entity);
        if (passiveState >= 0)
        {
            entity.State = passiveState;
            return;
        }
        var over = entity.GetStateOverride();
        if (over >= 0)
        {
            entity.State = passiveState;
            return;
        }
        if (!entity.IsAIFrozen())
        {
            entity.State = GetActiveState(entity);
            return;
        }
        if (entity.State == STATE_DEATH && !entity.IsDead) // 复活后重置状态
        {
            entity.State = GetActiveState(entity);
            return;
        }
    }
    function GetPassiveState(enemy:Entity):Int
    {
        if (enemy.IsDead)
        {
            return STATE_DEATH;
        }
        else if (enemy.IsPreviewEnemy())
        {
            return STATE_IDLE;
        }
        return -1;
    }
    function GetActiveState(enemy:Entity):Int
    {
        if (EnemyMeleeBehaviour.HasMeleeTarget(enemy))
        {
            return STATE_MELEE_ATTACK;
        }
        else if (enemy.IsCasting())
        {
            return STATE_CAST;
        }
        else
        {
            return STATE_WALK;
        }
    }
    public static inline var STATE_IDLE:Int = LogicEnemyStates.IDLE;
    public static inline var STATE_WALK:Int = LogicEnemyStates.WALK;
    public static inline var STATE_MELEE_ATTACK:Int = LogicEnemyStates.MELEE_ATTACK;
    public static inline var STATE_CAST:Int = LogicEnemyStates.CAST;
    public static inline var STATE_DEATH:Int = LogicEnemyStates.DEATH;
    public static inline var STATE_RANGED_ATTACK:Int = LogicEnemyStates.RANGED_ATTACK;
    public static inline var STATE_LEAVE:Int = LogicEnemyStates.LEAVE;
}
