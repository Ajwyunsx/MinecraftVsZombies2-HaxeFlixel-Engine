// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Animation/HumanoidAnimationBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.ParatroopBuff;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
using mvz2logic.contents.enemies.LogicEnemyExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.humanoidAnimation)
class HumanoidAnimationBehaviour extends EnemyAnimationBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function UpdateAnimationParameters(entity:Entity, state:Int):Void
    {
        var parameters = new AnimationParameters(false, WALK_STATE_NONE, ARM_STATE_IDLE, 0);
        switch (state)
        {
            case EnemyAnimationBehaviour.STATE_WALK, EnemyAnimationBehaviour.STATE_LEAVE:
                parameters.walkState = WALK_STATE_WALK;
            case EnemyAnimationBehaviour.STATE_MELEE_ATTACK:
                parameters.armState = ARM_STATE_ATTACK;
            case EnemyAnimationBehaviour.STATE_CAST:
                parameters.armState = ARM_STATE_CAST;
            case EnemyAnimationBehaviour.STATE_DEATH:
                parameters.dead = true;
            case EnemyAnimationBehaviour.STATE_RANGED_ATTACK:
                parameters.armState = ARM_STATE_NONE;
        }
        // PORT-NOTE: C# 的 ref 参数改为传入并返回 AnimationParameters。
        parameters = ModifyAnimationParameters(entity, state, parameters);
        entity.SetAnimationBool("Dead", parameters.dead);
        entity.SetAnimationInt("WalkState", parameters.walkState);
        entity.SetAnimationInt("ArmState", parameters.armState);
        entity.SetAnimationInt("SpecialState", parameters.specialState);
    }
    // PORT-NOTE: C# 的 ref 参数改为传入并返回 AnimationParameters。
    function ModifyAnimationParameters(entity:Entity, state:Int, parameters:AnimationParameters):AnimationParameters
    {
        if (ParatroopBuff.IsParachuting(entity))
        {
            parameters.armState = ARM_STATE_HANDS_UP;
        }
        var horse = entity.GetRidingEntity();
        var hasHorse = horse.ExistsAndAlive();
        if (hasHorse)
        {
            parameters.walkState = WALK_STATE_SIT;
        }
        return parameters;
    }
    public static inline var WALK_STATE_NONE:Int = 0;
    public static inline var WALK_STATE_WALK:Int = 1;
    public static inline var WALK_STATE_SIT:Int = 2;
    public static inline var ARM_STATE_NONE:Int = 0;
    public static inline var ARM_STATE_IDLE:Int = 1;
    public static inline var ARM_STATE_ATTACK:Int = 2;
    public static inline var ARM_STATE_CAST:Int = 3;
    public static inline var ARM_STATE_HANDS_UP:Int = 4;
    public static inline var ARM_STATE_SPECIAL_1:Int = 10000;
}
