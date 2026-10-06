// Ported from: Assets/Scripts/Vanilla/Frameworks/StateMachine/EntityStateMachineState.cs
package mvz2.vanilla.statemachine;

import pvzengine.entities.Entity;

class EntityStateMachineState
{
    public function new(state:Int, animationState:Int = -1)
    {
        this.state = state;
        this.animationState = animationState;
    }
    public var state:Int;
    public var animationState:Int = -1;
    public function OnEnter(machine:EntityStateMachine, entity:Entity):Void { }
    public function OnUpdateAI(machine:EntityStateMachine, entity:Entity):Void { }
    public function OnUpdateLogic(machine:EntityStateMachine, entity:Entity):Void { }
    public function OnExit(machine:EntityStateMachine, entity:Entity):Void { }
    public function GetAnimationState(substate:Int):Int { return animationState; }
    public function GetAnimationSubstate(substate:Int):Int { return 0; }
}
