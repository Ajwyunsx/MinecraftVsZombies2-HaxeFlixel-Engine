// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Animation/Spider_AnimationBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.enemies.VanillaEnemyStates;
import mvz2.gamecontent.enemies.EnemyCommonAnimationBehaviour;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.spider_Animation)
class Spider_AnimationBehaviour extends EnemyCommonAnimationBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function GetAnimationState(state:Int):Int
    {
        switch (state)
        {
            case STATE_CLIMB:
                return EnemyCommonAnimationBehaviour.ANIMATION_STATE_IDLE;
        }
        return super.GetAnimationState(state);
    }
    public static inline var STATE_CLIMB:Int = VanillaEnemyStates.SPIDER_CLIMB;
}
