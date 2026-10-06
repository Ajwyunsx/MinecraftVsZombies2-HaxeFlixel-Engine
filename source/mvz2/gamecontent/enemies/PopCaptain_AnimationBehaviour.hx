// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Animation/PopCaptain_AnimationBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.enemies.VanillaEnemyStates;
import mvz2.vanilla.models.VanillaAnimatorKeys;
import pvzengine.entities.Entity;
import mvz2.gamecontent.enemies.EnemyCommonAnimationBehaviour;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.popCaptain_Animation)
class PopCaptain_AnimationBehaviour extends EnemyCommonAnimationBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var noAnchor = PopCaptain.NoAnchor(entity);
        entity.SetModelProperty("NoAnchor", noAnchor);

        var animatorInterface = entity.GetAnimatorInterface(VanillaAnimatorKeys.main);
        if (animatorInterface != null)
        {
            var stateNumber = entity.State;
            var animationState = GetAnimationState(stateNumber);
            var holdingAnchor = !noAnchor && (animationState == EnemyCommonAnimationBehaviour.ANIMATION_STATE_WALK || animationState == EnemyCommonAnimationBehaviour.ANIMATION_STATE_IDLE);
            var targetWeight = holdingAnchor ? 1.0 : 0.0;
            var weight = animatorInterface.GetLayerWeight("AnchorArm");
            weight = weight * 0.5 + targetWeight * 0.5;
            animatorInterface.SetLayerWeight("AnchorArm", weight);
        }
    }
    public override function GetAnimationState(state:Int):Int
    {
        switch (state)
        {
            case STATE_SMASH_DOWN:
                return ANIMATION_STATE_SMASH_DOWN;
            case STATE_SMASH_UP:
                return ANIMATION_STATE_SMASH_UP;
        }
        return super.GetAnimationState(state);
    }
    public static inline var STATE_SMASH_DOWN:Int = VanillaEnemyStates.POP_CAPTAIN_SMASH_DOWN;
    public static inline var STATE_SMASH_UP:Int = VanillaEnemyStates.POP_CAPTAIN_SMASH_UP;

    public static inline var ANIMATION_STATE_SMASH_DOWN:Int = EnemyCommonAnimationBehaviour.ANIMATION_STATE_PRIVATE + 0;
    public static inline var ANIMATION_STATE_SMASH_UP:Int = EnemyCommonAnimationBehaviour.ANIMATION_STATE_PRIVATE + 1;
}
