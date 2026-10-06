package mvz2.animation;

import unity.Animator;
import unity.AnimatorStateInfo;
import unity.StateMachineBehaviour;
import unity.UnityObject;

// Ported from: Assets/Scripts/MVZ2/Animation/AutoDestroyStateBehaviour.cs
class AutoDestroyStateBehaviour extends StateMachineBehaviour {
    // OnStateExit is called when a transition ends and the state machine finishes evaluating this state
    override public function OnStateExit(animator:Animator, stateInfo:AnimatorStateInfo, layerIndex:Int):Void {
        UnityObject.destroy(animator.gameObject);
    }
}
