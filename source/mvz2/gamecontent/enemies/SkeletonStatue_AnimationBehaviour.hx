// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Animation/SkeletonStatue_AnimationBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.enemies.VanillaEnemyStates;
import pvzengine.entities.Entity;
import mvz2.gamecontent.enemies.EnemyAnimationBehaviour;
import mvz2.gamecontent.enemies.HumanoidAnimationBehaviour;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.skeletonStatue_Animation)
class SkeletonStatue_AnimationBehaviour extends HumanoidAnimationBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function ModifyAnimationParameters(entity:Entity, state:Int, parameters:AnimationParameters):AnimationParameters
    {
        parameters = super.ModifyAnimationParameters(entity, state, parameters);
        if (state == STATE_REVIVING || state == EnemyAnimationBehaviour.STATE_DEATH)
        {
            parameters.walkState = HumanoidAnimationBehaviour.WALK_STATE_NONE;
            parameters.armState = HumanoidAnimationBehaviour.ARM_STATE_NONE;
            parameters.specialState = SPECIAL_STATE_REVIVING;
        }
        return parameters;
    }
    public static inline var STATE_REVIVING:Int = VanillaEnemyStates.SKELETON_STATUE_REVIVING;
    public static inline var SPECIAL_STATE_REVIVING:Int = 1;
}
