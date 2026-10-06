package unity;

// Minimal UnityEngine.StateMachineBehaviour shim.
class StateMachineBehaviour extends UnityObject {
    public function new() {
        super();
    }

    public function OnStateEnter(animator:Animator, stateInfo:AnimatorStateInfo, layerIndex:Int):Void {}
    public function OnStateUpdate(animator:Animator, stateInfo:AnimatorStateInfo, layerIndex:Int):Void {}
    public function OnStateExit(animator:Animator, stateInfo:AnimatorStateInfo, layerIndex:Int):Void {}
    public function OnStateMove(animator:Animator, stateInfo:AnimatorStateInfo, layerIndex:Int):Void {}
    public function OnStateIK(animator:Animator, stateInfo:AnimatorStateInfo, layerIndex:Int):Void {}
}
