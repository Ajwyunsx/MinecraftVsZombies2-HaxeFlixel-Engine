// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter5/PopCaptain.cs
// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter5/PopCaptain_States.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.PopCaptainDetector;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.enemies.VanillaEnemyStates;
import mvz2.vanilla.enemies.VanillaMass;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2.vanilla.statemachine.EntityStateMachine;
import mvz2.vanilla.statemachine.EntityStateMachineState;
import mvz2logic.entities.LogicEnemyStates;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import tools.Ticks;
using mvz2.vanilla.enemies.VanillaEnemyExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEnemyProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.shells.VanillaShellProps;

// PORT-NOTE: C# 的 partial class PopCaptain 由 PopCaptain.cs 与 PopCaptain_States.cs 合并为本文件。
// PORT-NOTE: 原 C# 的 `[AutoEntityBehaviourDefinition(VanillaEnemyNames.popCaptain)]` 在
// PopCaptain.cs 上（partial 的另一半 PopCaptain_States.cs 没有），合并本文件时被漏掉，
// 导致 mvz2:pop_captain 这个 behaviour 从未注册（boot-trace 里
// `Cannot find entity behaviour with ID mvz2:pop_captain`，来源 Assets/GameContent/Assets/mvz2/metas/entities.xml）。
@:autoEntityBehaviourDefinition(VanillaEnemyNames.popCaptain)
class PopCaptain extends EnemyBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        stateMachine.Init(entity);
        stateMachine.StartState(entity, STATE_IDLE);
        if (!entity.IsPreviewEnemy())
            entity.PlaySound(VanillaSoundID.chainsBreak);
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
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        if (entity.WillRemoveOnDeath(info))
            return;
        stateMachine.StartState(entity, STATE_DEATH);
    }
    public static function NoAnchor(entity:Entity):Bool return entity.GetBehaviourField(PROP_NO_ANCHOR);
    public static function SetNoAnchor(entity:Entity, value:Bool):Void entity.SetBehaviourField(PROP_NO_ANCHOR, value);
    public static function SmashUpwards(entity:Entity):Bool return entity.GetBehaviourField(PROP_SMASH_UPWARDS);
    public static function SetSmashUpwards(entity:Entity, value:Bool):Void entity.SetBehaviourField(PROP_SMASH_UPWARDS, value);

    public static var PROP_NO_ANCHOR:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("no_anchor");

    public static var PROP_SMASH_UPWARDS:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("smash_upwards");
    public static inline var STUN_SECONDS:Float = 3;
    // PORT-NOTE: C# 的嵌套私有状态机类提升为模块级私有类（Haxe 不支持嵌套类）。
    static var stateMachine:EntityStateMachine = new MutantZombieStateMachine();
    static var smashDetector:Detector = new PopCaptainDetector(0);
    static var damageDetector:Detector = makeDamageDetector();

    static function makeDamageDetector():Detector
    {
        var d:Detector = new PopCaptainDetector(60);
        cast(d, PopCaptainDetector).canDetectInvisible = true;
        return d;
    }

    //region 状态机
    // PORT-NOTE: C# 中为 private static，因状态类无法访问私有成员，改为 public static。
    public static function UpdateState(zombie:Entity, restart:Bool = false):Void
    {
        var targetState = STATE_WALK;
        if (zombie.IsDead)
        {
            targetState = STATE_DEATH;
        }
        else if (zombie.IsPreviewEnemy())
        {
            targetState = STATE_IDLE;
        }
        else if (CheckSmash(zombie))
        {
            var smashUpwards = SmashUpwards(zombie);
            targetState = smashUpwards ? STATE_SMASH_UP : STATE_SMASH_DOWN;
            SetSmashUpwards(zombie, !smashUpwards);
        }
        else if (CheckAttack(zombie))
        {
            targetState = STATE_MELEE_ATTACK;
        }
        if (stateMachine.GetStateNumber(zombie) != targetState || restart)
        {
            stateMachine.StartState(zombie, targetState);
        }
    }
    //endregion

    //region 攻击
    static function CheckAttack(zombie:Entity):Bool
    {
        if (!NoAnchor(zombie))
            return false;
        return EnemyMeleeBehaviour.HasMeleeTarget(zombie);
    }
    //endregion

    //region 下砸
    static function CheckSmash(zombie:Entity):Bool
    {
        if (NoAnchor(zombie))
            return false;
        return smashDetector.DetectExists(DetectionParams.fromEntity(zombie));
    }
    public static function Smash(entity:Entity, rowOffset:Int):Void
    {
        if (NoAnchor(entity))
            return;
        // 检测第一个目标。
        var center = entity.GetCenter();
        // PORT-NOTE: C# 用 Unity 的 Bounds.SqrDistance(Vector3) 作为排序键；unity.Bounds（unity 域）未提供该方法，
        // 这里按 Unity 语义就地计算：点到包围盒最近点的距离平方，点在盒内时为 0。
        var targetCollider = damageDetector.DetectWithTheLeast(DetectionParams.fromEntity(entity), c -> {
            var offset = c.GetBoundingBox().ClosestPoint(center) - center;
            return offset.sqrMagnitude;
        });
        // 对目标造成伤害。
        if (targetCollider == null)
            return;
        var damage = entity.GetDamage();
        var damageEffects = new DamageEffectList([VanillaDamageEffects.IMPACT]);
        var outOfBoundDamageEffects = new DamageEffectList([VanillaDamageEffects.OUT_OF_BOUND]);
        var damageOutput = targetCollider.TakeDamage(damage, damageEffects, entity);
        // 如果伤害有效：
        if (!damageOutput.HasDamageAmount())
            return;
        var target = targetCollider.Entity;
        for (result in damageOutput.GetAllResults())
        {
            var shell = result.ShellDefinition;
            if (shell != null && shell.BlocksSlice())
            {
                target.PlaySound(VanillaSoundID.anvil);
                break;
            }
        }

        // 如果受到伤害的是主碰撞器，并且目标还存活：
        if (!targetCollider.IsForMain() || !target.ExistsAndAlive())
            return;
        var thisLane = entity.GetLane();
        // 如果目标是怪物：
        if (target.Type == EntityTypes.ENEMY)
        {
            // 如果目标地格存在，直接使其换行。
            if (target.GetMass() <= VanillaMass.HEAVY)
            {
                var column = target.GetColumn();
                var grid = entity.Level.GetGrid(column, thisLane + rowOffset);
                if (grid != null)
                {
                    target.StartChangingLane(thisLane + rowOffset);
                }
            }
        }
        else if (target.Type == EntityTypes.PLANT)
        {
            // 如果目标是器械：
            var column = target.GetColumn();
            var targetGrid = entity.Level.GetGrid(column, thisLane + rowOffset);
            if (targetGrid == null)
            {
                // 如果目标地格不存在，直接秒杀器械。
                target.Die(outOfBoundDamageEffects, entity, damageOutput.BodyResult != null ? damageOutput.BodyResult.GetValues() : null);
            }
            else
            {
                // 移动器械到目标地格。
                target.StartChangingGrid(column, thisLane + rowOffset);
            }
        }
        // 将目标眩晕。
        if (target.CanDeactive())
        {
            target.Stun(Ticks.FromSeconds(STUN_SECONDS));
        }
    }
    //endregion

    public static inline var STATE_IDLE:Int = LogicEnemyStates.IDLE;
    public static inline var STATE_WALK:Int = LogicEnemyStates.WALK;
    public static inline var STATE_MELEE_ATTACK:Int = LogicEnemyStates.MELEE_ATTACK;
    public static inline var STATE_SMASH_DOWN:Int = VanillaEnemyStates.POP_CAPTAIN_SMASH_DOWN;
    public static inline var STATE_SMASH_UP:Int = VanillaEnemyStates.POP_CAPTAIN_SMASH_UP;
    public static inline var STATE_DEATH:Int = LogicEnemyStates.DEATH;
}

private class MutantZombieStateMachine extends EntityStateMachine
{
    public function new()
    {
        super();
        AddState(new IdleState());
        AddState(new WalkState());
        AddState(new AttackState());
        AddState(new SmashDownState());
        AddState(new SmashUpState());
        AddState(new DeathState());
    }
}

//region 空闲
class IdleState extends EntityStateMachineState
{
    public function new()
    {
        super(PopCaptain.STATE_IDLE);
    }
    public override function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        PopCaptain.UpdateState(entity);
    }
}
//endregion

//region 行走
class WalkState extends EntityStateMachineState
{
    public function new()
    {
        super(PopCaptain.STATE_WALK);
    }
    public override function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        entity.UpdateWalkVelocity();
        PopCaptain.UpdateState(entity);
    }
}
//endregion

//region 攻击
class AttackState extends EntityStateMachineState
{
    public function new()
    {
        super(PopCaptain.STATE_MELEE_ATTACK);
    }
    public override function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        PopCaptain.UpdateState(entity);
    }
}
//endregion

//region 下砸
class SmashDownState extends EntityStateMachineState
{
    public function new()
    {
        super(PopCaptain.STATE_SMASH_DOWN);
    }
    public override function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        entity.TriggerAnimation("SmashTrigger");
        var subStateTimer = stateMachine.GetSubStateTimer(entity);
        subStateTimer.ResetSeconds(SUBSTATE_START_SECONDS);
    }
    public override function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var subStateTimer = stateMachine.GetSubStateTimer(entity);
        var substate = stateMachine.GetSubState(entity);
        subStateTimer.Run(entity.GetAttackSpeed());

        switch (substate)
        {
            case SUBSTATE_START:
                if (subStateTimer.Expired)
                {
                    entity.PlaySound(VanillaSoundID.fling);
                    PopCaptain.Smash(entity, 1);

                    subStateTimer.ResetSeconds(SUBSTATE_RESTORE_SECONDS);
                    stateMachine.StartSubState(entity, SUBSTATE_RESTORE);
                }
            case SUBSTATE_RESTORE:
                if (subStateTimer.Expired)
                {
                    PopCaptain.UpdateState(entity, true);
                }
        }
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_RESTORE:Int = 1;
    public static inline var SUBSTATE_START_SECONDS:Float = 1;
    public static inline var SUBSTATE_RESTORE_SECONDS:Float = 2.5;
}

class SmashUpState extends EntityStateMachineState
{
    public function new()
    {
        super(PopCaptain.STATE_SMASH_UP);
    }
    public override function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        entity.TriggerAnimation("SmashTrigger");
        var subStateTimer = stateMachine.GetSubStateTimer(entity);
        subStateTimer.ResetSeconds(SUBSTATE_START_SECONDS);
    }
    public override function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var subStateTimer = stateMachine.GetSubStateTimer(entity);
        var substate = stateMachine.GetSubState(entity);
        subStateTimer.Run(entity.GetAttackSpeed());

        switch (substate)
        {
            case SUBSTATE_START:
                if (subStateTimer.Expired)
                {
                    entity.PlaySound(VanillaSoundID.fling);
                    PopCaptain.Smash(entity, -1);

                    subStateTimer.ResetSeconds(SUBSTATE_RESTORE_SECONDS);
                    stateMachine.StartSubState(entity, SUBSTATE_RESTORE);
                }
            case SUBSTATE_RESTORE:
                if (subStateTimer.Expired)
                {
                    PopCaptain.UpdateState(entity, true);
                }
        }
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_RESTORE:Int = 1;
    public static inline var SUBSTATE_START_SECONDS:Float = 1;
    public static inline var SUBSTATE_RESTORE_SECONDS:Float = 2.5;
}
//endregion

//region 死亡
class DeathState extends EntityStateMachineState
{
    public function new()
    {
        super(PopCaptain.STATE_DEATH);
    }
    public override function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var stateTimer = stateMachine.GetStateTimer(entity);
        stateTimer.ResetSeconds(DEATH_SECONDS);
    }
    public override function OnUpdateLogic(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(stateMachine, entity);
        var stateTimer = stateMachine.GetStateTimer(entity);
        stateTimer.Run();
        if (stateTimer.Expired)
        {
            entity.FaintRemove();
        }
        if (!entity.IsDead)
        {
            PopCaptain.UpdateState(entity, true);
        }
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_DROP:Int = 1;
    public static inline var DEATH_SECONDS:Float = 2.5;
}
//endregion
