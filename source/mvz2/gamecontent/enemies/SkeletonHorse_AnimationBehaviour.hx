// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Animation/SkeletonHorse_AnimationBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.enemies.VanillaEnemyStates;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.skeletonHorse_Animation)
class SkeletonHorse_AnimationBehaviour extends EnemyCommonAnimationBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function GetAnimationState(state:Int):Int
    {
        switch (state)
        {
            case STATE_JUMP:
                return ANIMATION_STATE_JUMP;
            case STATE_GALLOP:
                return ANIMATION_STATE_GALLOP;
            case STATE_LAND:
                return ANIMATION_STATE_LAND;
        }
        return super.GetAnimationState(state);
    }
    public static inline var STATE_GALLOP:Int = VanillaEnemyStates.SKELETON_HORSE_GALLOP;
    public static inline var STATE_JUMP:Int = VanillaEnemyStates.SKELETON_HORSE_JUMP;
    public static inline var STATE_LAND:Int = VanillaEnemyStates.SKELETON_HORSE_LAND;
    public static inline var ANIMATION_STATE_JUMP:Int = EnemyCommonAnimationBehaviour.ANIMATION_STATE_PRIVATE + 0;
    public static inline var ANIMATION_STATE_GALLOP:Int = EnemyCommonAnimationBehaviour.ANIMATION_STATE_PRIVATE + 1;
    public static inline var ANIMATION_STATE_LAND:Int = EnemyCommonAnimationBehaviour.ANIMATION_STATE_PRIVATE + 2;
}
