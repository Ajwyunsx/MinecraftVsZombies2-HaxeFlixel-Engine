// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Animation/Napstablook_AnimationBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.enemies.VanillaEnemyStates;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.napstablook_Animation)
class Napstablook_AnimationBehaviour extends EnemyCommonAnimationBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function GetAnimationState(state:Int):Int
    {
        switch (state)
        {
            case STATE_ANGRY:
                return ANIMATION_STATE_ANGRY;
        }
        return super.GetAnimationState(state);
    }
    public static inline var STATE_ANGRY:Int = VanillaEnemyStates.NAPSTABLOOK_ANGRY;
    public static inline var ANIMATION_STATE_ANGRY:Int = EnemyCommonAnimationBehaviour.ANIMATION_STATE_PRIVATE + 0;
}
