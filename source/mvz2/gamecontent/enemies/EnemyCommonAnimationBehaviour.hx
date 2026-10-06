// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Animation/EnemyCommonAnimationBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.enemyCommonAnimation)
class EnemyCommonAnimationBehaviour extends EnemyAnimationBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function UpdateAnimationParameters(entity:Entity, state:Int):Void
    {
        entity.SetAnimationInt("State", entity.State);
        entity.SetAnimationInt("AnimationState", GetAnimationState(entity.State));
    }
    public function GetAnimationState(state:Int):Int
    {
        return state;
    }
    public static inline var ANIMATION_STATE_IDLE:Int = 0;
    public static inline var ANIMATION_STATE_WALK:Int = 1;
    public static inline var ANIMATION_STATE_ATTACK:Int = 2;
    public static inline var ANIMATION_STATE_CAST:Int = 3;
    public static inline var ANIMATION_STATE_DEATH:Int = 4;
    public static inline var ANIMATION_STATE_PRIVATE:Int = 10000;
}
