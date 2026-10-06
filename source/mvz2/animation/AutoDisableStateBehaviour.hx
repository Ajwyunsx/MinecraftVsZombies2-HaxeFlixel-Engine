package mvz2.animation;

import unity.Animator;
import unity.AnimatorStateInfo;
import unity.StateMachineBehaviour;

// Ported from: Assets/Scripts/MVZ2/Animation/AutoDisableStateBehaviour.cs
class AutoDisableStateBehaviour extends StateMachineBehaviour {
    // OnStateExit is called when a transition ends and the state machine finishes evaluating this state
    override public function OnStateExit(animator:Animator, stateInfo:AnimatorStateInfo, layerIndex:Int):Void {
        animator.gameObject.SetActive(false);
    }
}
