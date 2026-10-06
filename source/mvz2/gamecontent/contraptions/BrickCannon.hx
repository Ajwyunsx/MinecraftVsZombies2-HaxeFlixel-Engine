// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Upgrades/BrickCannon.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.gamecontent.projectiles.CannonMissile;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.contraptions.VanillaContraptionStates;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2.vanilla.statemachine.EntityStateMachine;
import mvz2.vanilla.statemachine.EntityStateMachineState;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.brickCannon)
class BrickCannon extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetNoMissile(entity, true);

        stateMachine.Init(entity);
        stateMachine.StartState(entity, STATE_IDLE);
        var timer = stateMachine.GetStateTimer(entity);
        timer.SetSeconds(START_RELOAD_TIME_SECONDS);
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        stateMachine.UpdateAI(entity);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        stateMachine.UpdateLogic(entity);

        var animationSpeed = entity.IsAIFrozen() ? 0 : 1;
        entity.SetModelProperty("NoMissile", HasNoMissile(entity));
        entity.SetAnimationBool("Danger", IsDanger(entity));
        entity.SetAnimationInt("BodyState", GetAnimationBodyState(entity));
        entity.SetAnimationFloat("AnimationSpeed", animationSpeed);
        entity.SetAnimationFloat("AnimationAttackSpeed", animationSpeed * entity.GetAttackSpeed());
    }
    public function GetAnimationBodyState(entity:Entity):Int
    {
        switch (entity.State)
        {
            case STATE_RELOAD:
                return 1;
            case STATE_LAUNCH:
                return 2;
        }
        return 0;
    }
    public static function Launch(entity:Entity, target:Vector3):Void
    {
        stateMachine.StartState(entity, STATE_LAUNCH);
        SetTargetPosition(entity, target);
    }
    public static function ReloadImmediate(entity:Entity):Void
    {
        if (!HasNoMissile(entity) || entity.State != STATE_IDLE)
            return;
        var timer = stateMachine.GetStateTimer(entity);
        timer.SetSeconds(0);
    }
    public static function IsDanger(entity:Entity):Bool return entity.GetProperty(PROP_DANGER);
    public static function SetDanger(entity:Entity, value:Bool):Void entity.SetProperty(PROP_DANGER, value);
    public static function HasNoMissile(entity:Entity):Bool return entity.GetProperty(PROP_NO_MISSILE);
    public static function SetNoMissile(entity:Entity, value:Bool):Void entity.SetProperty(PROP_NO_MISSILE, value);
    public static function GetTargetPosition(entity:Entity):Vector3 return entity.GetProperty(PROP_TARGET_POSITION);
    public static function SetTargetPosition(entity:Entity, value:Vector3):Void entity.SetProperty(PROP_TARGET_POSITION, value);
    public static inline var STATE_IDLE:Int = VanillaContraptionStates.IDLE;
    public static inline var STATE_RELOAD:Int = VanillaContraptionStates.BRICK_CANNON_RELOAD;
    public static inline var STATE_LAUNCH:Int = VanillaContraptionStates.BRICK_CANNON_LAUNCH;
    public static inline var START_RELOAD_TIME_SECONDS:Float = 5;
    public static var PROP_DANGER:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("danger");
    public static var PROP_NO_MISSILE:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("no_missile");
    public static var PROP_TARGET_POSITION:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("target_position");
    // PORT-NOTE: C# 的嵌套私有状态机类提升为模块级私有类（Haxe 不支持嵌套类）。
    static var stateMachine:EntityStateMachine = new BrickCannonStateMachine();
}

private class BrickCannonStateMachine extends EntityStateMachine
{
    public function new()
    {
        super();
        AddState(new IdleState());
        AddState(new ReloadState());
        AddState(new LaunchState());
    }
}

private class IdleState extends EntityStateMachineState
{
    public function new()
    {
        super(BrickCannon.STATE_IDLE);
    }

    public override function OnEnter(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(machine, entity);
        var stateTimer = machine.GetStateTimer(entity);
        stateTimer.ResetSeconds(RELOAD_TIME_SECONDS);
    }

    public override function OnUpdateAI(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(machine, entity);
        if (!BrickCannon.HasNoMissile(entity))
            return;
        var timer = machine.GetStateTimer(entity);
        if (timer.RunToExpired(entity.GetAttackSpeed()))
        {
            machine.StartState(entity, BrickCannon.STATE_RELOAD);
        }
    }
    public static inline var RELOAD_TIME_SECONDS:Float = 30;
}

private class ReloadState extends EntityStateMachineState
{
    public function new()
    {
        super(BrickCannon.STATE_RELOAD);
    }

    public override function OnEnter(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(machine, entity);
        var substateTimer = machine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(POP_TIME_SECONDS);
    }

    public override function OnUpdateAI(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(machine, entity);
        var substateTimer = machine.GetSubStateTimer(entity);
        var substate = machine.GetSubState(entity);
        switch (substate)
        {
            case SUBSTATE_START:
                if (substateTimer.RunToExpired(entity.GetAttackSpeed()))
                {
                    entity.PlaySound(VanillaSoundID.gunReload, 0.75);
                    BrickCannon.SetNoMissile(entity, false);
                    machine.StartSubState(entity, SUBSTATE_POP);
                    substateTimer.ResetSeconds(FINISH_TIME_SECONDS);
                }
            case SUBSTATE_POP:
                if (substateTimer.RunToExpired(entity.GetAttackSpeed()))
                {
                    machine.StartState(entity, BrickCannon.STATE_IDLE);
                }
        }
    }
    public static inline var POP_TIME_SECONDS:Float = 1;
    public static inline var FINISH_TIME_SECONDS:Float = 0.5;
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_POP:Int = 1;
}

private class LaunchState extends EntityStateMachineState
{
    public function new()
    {
        super(BrickCannon.STATE_LAUNCH);
    }

    public override function OnEnter(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(machine, entity);
        var substateTimer = machine.GetSubStateTimer(entity);
        substateTimer.ResetSeconds(LAUNCH_TIME_SECONDS);
    }

    public override function OnUpdateAI(machine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(machine, entity);
        var substateTimer = machine.GetSubStateTimer(entity);
        var substate = machine.GetSubState(entity);
        switch (substate)
        {
            case SUBSTATE_START:
                if (substateTimer.RunToExpired(entity.GetAttackSpeed()))
                {
                    LaunchMissile(entity);
                    BrickCannon.SetNoMissile(entity, true);
                    BrickCannon.SetDanger(entity, false);
                    machine.StartSubState(entity, SUBSTATE_LAUNCHED);
                    substateTimer.ResetSeconds(FINISH_TIME_SECONDS);
                }
            case SUBSTATE_LAUNCHED:
                if (substateTimer.RunToExpired(entity.GetAttackSpeed()))
                {
                    machine.StartState(entity, BrickCannon.STATE_IDLE);
                }
        }
    }
    public function LaunchMissile(entity:Entity):Null<Entity>
    {
        var danger = BrickCannon.IsDanger(entity);
        var param = entity.GetShootParams();
        param.spawnParam.SetProperty(CannonMissile.PROP_TARGET_POSITION, BrickCannon.GetTargetPosition(entity));
        param.spawnParam.SetProperty(LogicEntityProps.VARIANT, danger ? CannonMissile.VARIANT_DANGER : CannonMissile.VARIANT_NORMAL);
        return entity.ShootProjectile(param);
    }
    public static inline var LAUNCH_TIME_SECONDS:Float = 1.333333333;
    public static inline var FINISH_TIME_SECONDS:Float = 1;
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_LAUNCHED:Int = 1;
}
