// Ported from: Assets/Scripts/Vanilla/Frameworks/StateMachine/EntityStateMachine.cs
package mvz2.vanilla.statemachine;

import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.entities.Entity;
import tools.FrameTimer;

class EntityStateMachine
{
    public function new()
    {
    }

    // #region 事件
    public function Init(entity:Entity):Void
    {
        EnterState(entity, entity.State);
    }
    public function UpdateAI(entity:Entity):Void
    {
        var state = GetState(entity.State);
        if (state == null)
            return;
        state.OnUpdateAI(this, entity);
    }
    public function UpdateLogic(entity:Entity):Void
    {
        var state = GetState(entity.State);
        if (state == null)
            return;
        state.OnUpdateLogic(this, entity);
    }
    // virtual
    public function OnEnterState(entity:Entity, state:Int):Void { }
    // virtual
    public function OnExitState(entity:Entity, state:Int):Void { }
    // #endregion

    // #region 状态方法
    public function AddState(state:EntityStateMachineState):Void
    {
        states.push(state);
    }
    public function GetState(stateNumber:Int):Null<EntityStateMachineState>
    {
        for (state in states)
        {
            if (state.state == stateNumber)
                return state;
        }
        return null;
    }
    // #endregion

    // #region 实体状态
    public function StartState(entity:Entity, state:Int):Void
    {
        ExitState(entity, GetStateNumber(entity));
        EnterState(entity, state);
    }
    private function EnterState(entity:Entity, stateNum:Int):Void
    {
        var state = GetState(stateNum);
        if (state == null)
            return;

        SetSubState(entity, 0);
        entity.State = stateNum;

        var substateTimer = GetSubStateTimer(entity);
        var nextStateTimer = GetStateTimer(entity);

        substateTimer.Stop();
        nextStateTimer.Stop();

        entity.SetAnimationInt("State", stateNum);
        entity.SetAnimationInt("SubState", 0);
        var animationState = state.GetAnimationState(0);
        if (animationState >= 0)
        {
            entity.SetAnimationInt("AnimationState", animationState);
        }
        entity.SetAnimationInt("AnimationSubstate", state.GetAnimationSubstate(0));

        state.OnEnter(this, entity);
        OnEnterState(entity, stateNum);
    }
    private function ExitState(entity:Entity, stateNum:Int):Void
    {
        var state = GetState(stateNum);
        if (state == null)
            return;
        state.OnExit(this, entity);
        OnExitState(entity, stateNum);
    }
    public function GetStateNumber(entity:Entity):Int
    {
        return entity.State;
    }
    // #endregion

    // #region 子状态
    public function StartSubState(entity:Entity, value:Int):Void
    {
        SetSubState(entity, value);
        UpdateSubstateAnimation(entity);
    }
    // #endregion

    // #region 攻击速度
    // virtual
    public function GetSpeed(entity:Entity):Float
    {
        return 1;
    }
    // #endregion

    // #region 属性
    public function GetSubState(entity:Entity):Int
    {
        return entity.GetBehaviourField(PROP_SUBSTATE);
    }
    public function SetSubState(entity:Entity, value:Int):Void
    {
        entity.SetBehaviourField(PROP_SUBSTATE, value);
    }
    public function GetPreviousState(boss:Entity):Int
    {
        return boss.GetBehaviourField(PROP_PREVIOUS_STATE);
    }
    public function SetPreviousState(boss:Entity, value:Int):Void
    {
        boss.SetBehaviourField(PROP_PREVIOUS_STATE, value);
    }
    public function GetNextStateIndex(boss:Entity):Int
    {
        return boss.GetBehaviourField(PROP_NEXT_STATE_INDEX);
    }
    public function SetNextStateIndex(boss:Entity, value:Int):Void
    {
        boss.SetBehaviourField(PROP_NEXT_STATE_INDEX, value);
    }
    public function GetStateTimer(entity:Entity):FrameTimer
    {
        var timer = entity.GetBehaviourField(PROP_STATE_TIMER);
        if (timer == null)
        {
            timer = new FrameTimer();
            entity.SetBehaviourField(PROP_STATE_TIMER, timer);
        }
        return timer;
    }
    public function GetSubStateTimer(entity:Entity):FrameTimer
    {
        var timer = entity.GetBehaviourField(PROP_SUBSTATE_TIMER);
        if (timer == null)
        {
            timer = new FrameTimer();
            entity.SetBehaviourField(PROP_SUBSTATE_TIMER, timer);
        }
        return timer;
    }
    // #endregion

    // #region 动画
    private function UpdateSubstateAnimation(entity:Entity):Void
    {
        var substate = GetSubState(entity);
        entity.SetAnimationInt("SubState", substate);
        var state = GetState(GetStateNumber(entity));
        if (state != null)
        {
            var animationState = state.GetAnimationState(substate);
            if (animationState >= 0)
            {
                entity.SetAnimationInt("AnimationState", animationState);
            }
            entity.SetAnimationInt("AnimationSubstate", state.GetAnimationSubstate(substate));
        }
    }
    public function GetAnimationState(stateNum:Int, substate:Int):Int
    {
        var state = GetState(stateNum);
        if (state == null)
            return 0;
        return state.GetAnimationState(substate);
    }
    // #endregion

    private var states:Array<EntityStateMachineState> = [];

    @:entityPropertyRegistry(PROP_REGION)
    private static var PROP_SUBSTATE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("SubState");
    @:entityPropertyRegistry(PROP_REGION)
    private static var PROP_PREVIOUS_STATE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("PreviousState");
    @:entityPropertyRegistry(PROP_REGION)
    private static var PROP_NEXT_STATE_INDEX:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("next_state_index");
    @:entityPropertyRegistry(PROP_REGION)
    private static var PROP_STATE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("StateTimer");
    @:entityPropertyRegistry(PROP_REGION)
    private static var PROP_SUBSTATE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("SubStateTimer");
    public static inline var PROP_REGION:String = "state_machine";
}
