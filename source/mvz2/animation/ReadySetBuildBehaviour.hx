package mvz2.animation;

import mvz2.ui.level.LevelUIPreset;
import unity.Animator;
import unity.AnimatorStateInfo;
import unity.StateMachineBehaviour;

// Ported from: Assets/Scripts/MVZ2/Animation/ReadySetBuildBehaviour.cs
class ReadySetBuildBehaviour extends StateMachineBehaviour {
    override public function OnStateExit(animator:Animator, stateInfo:AnimatorStateInfo, layerIndex:Int):Void {
        var preset = animator.GetComponent(LevelUIPreset);
        if (preset == null)
            return;
        preset.CallStartGame();
    }
}
