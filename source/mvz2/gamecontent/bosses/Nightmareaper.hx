// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/Nightmareaper.cs
// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/Nightmareaper_States.cs
// PORT-NOTE: the C# `partial class Nightmareaper` spans Nightmareaper.cs and Nightmareaper_States.cs;
// per PORTING.md partial classes are merged into a single Haxe module.
// PORT-NOTE: members accessed by the C# nested state classes are `public` here,
// because Haxe module types do not share class-level private visibility.
package mvz2.gamecontent.bosses;

import mvz2.gamecontent.buffs.bosses.NightmareaperFallBuff;
import mvz2.gamecontent.buffs.enemies.FlyBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.CrushingWalls;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.buffs.level.NightmareaperDarknessBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.bosses.VanillaBossStates;
import mvz2.vanilla.detection.Detection;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2.vanilla.shells.VanillaShellProps;
import mvz2.vanilla.statemachine.EntityStateMachine;
import mvz2.vanilla.statemachine.EntityStateMachineState;
import pvzengine.entities.EntityTypes;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LevelPositions;
import pvzengine.RandomGenerator;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.collisions.IEntityCollider;
import pvzengine.collisions.level.OverlapParams;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DamageOutput;
import pvzengine.damages.DamageResult;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import pvzengine.base.PropertyKey;
import tools.EnumerableExt;
import tools.FrameTimer;
import tools.VectorExt;
import unity.Mathf;
import unity.Quaternion;
import unity.Vector2;
import unity.Vector3;
using mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;
import mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaBossNames.nightmareaper)
class Nightmareaper extends BossBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostEnemyDeathCallback, EntityTypes.ENEMY);
    }

    // #region 生命周期
    override public function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetMoveRNG(entity, new RandomGenerator(entity.RNG.Next()));
        SetStateRNG(entity, new RandomGenerator(entity.RNG.Next()));
        SetSparkRNG(entity, new RandomGenerator(entity.RNG.Next()));
        SetMoveDirection(entity, Vector3.back);
        var flyBuff = entity.AddBuff(FlyBuff);
        flyBuff.SetProperty(FlyBuff.PROP_TARGET_HEIGHT, FLY_HEIGHT);

        stateMachine.Init(entity);

        CheckTimerAndWallsCreation(entity);
    }
    override public function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (entity.IsDead)
            return;
        stateMachine.UpdateAI(entity);
    }
    override public function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        stateMachine.UpdateLogic(entity);
    }
    override public function PostDeath(entity:Entity, deathInfo:DeathInfo):Void
    {
        super.PostDeath(entity, deathInfo);

        entity.PlaySound(VanillaSoundID.nightmareaperDeath);
        var particles = entity.Spawn(VanillaEffectID.darkMatterParticles, entity.Position);
        if (particles != null)
        {
            particles.SetParent(entity);
        }

        CancelDarkness(entity.Level);

        stateMachine.StartState(entity, STATE_DEATH);

        CheckTimerAndWallsDestruction(entity);
    }
    // #endregion

    private function PostEnemyDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var info = param.deathInfo;
        if (!VanillaEntityExt.IsAboveLand(entity))
            return;
        for (nightmareaper in entity.Level.FindEntities(VanillaBossID.nightmareaper))
        {
            AddCorpsePosition(nightmareaper, entity.Position);
        }
    }
    public static function AddCorpsePosition(entity:Entity, pos:Vector3):Void
    {
        var deathPositions = GetCorpsePositions(entity);
        if (deathPositions == null)
        {
            deathPositions = [];
            SetCorpsePositions(entity, deathPositions);
        }
        deathPositions.push(pos);
        while (deathPositions.length > MAX_REVIVE_COUNT)
        {
            deathPositions.shift();
        }
    }
    public static function Appear(entity:Entity):Void
    {
        stateMachine.StartState(entity, STATE_APPEAR);
    }
    public static function Enrage(entity:Entity):Void
    {
        stateMachine.StartState(entity, STATE_ENRAGE);
    }
    public static function SetDarknessTimeout(level:LevelEngine, timeout:Int):Void
    {
        var buffs = level.GetBuffs(NightmareaperDarknessBuff);
        if (buffs.length <= 0)
        {
            var buff = level.AddBuff(NightmareaperDarknessBuff);
            buff.SetProperty(NightmareaperDarknessBuff.PROP_TIMEOUT, timeout);
        }
        else
        {
            for (buff in level.GetBuffs(NightmareaperDarknessBuff))
            {
                buff.SetProperty(NightmareaperDarknessBuff.PROP_TIMEOUT, timeout);
            }
        }
    }
    public static function CancelDarkness(level:LevelEngine):Void
    {
        for (buff in level.GetBuffs(NightmareaperDarknessBuff))
        {
            NightmareaperDarknessBuff.CancelDarkness(buff);
        }
    }
    public static function CheckTimerAndWallsCreation(entity:Entity):Void
    {
        var level = entity.Level;
        if (!level.EntityExists(VanillaEffectID.nightmareaperTimer))
        {
            var pos = new Vector3(620, 0, 500);
            entity.Spawn(VanillaEffectID.nightmareaperTimer, pos);
        }
        if (!level.EntityExists(VanillaEffectID.crushingWalls))
        {
            entity.Spawn(VanillaEffectID.crushingWalls, CENTER_POSITION);
        }
    }
    public static function CheckTimerAndWallsDestruction(entity:Entity):Void
    {
        var level = entity.Level;
        var hasAliveReaper = level.EntityExists(function(e) return e != entity && e.IsEntityOf(VanillaBossID.nightmareaper) && !e.IsDead);
        if (!hasAliveReaper)
        {
            for (timer in level.FindEntities(VanillaEffectID.nightmareaperTimer))
            {
                timer.Remove();
            }
            for (walls in level.FindEntities(VanillaEffectID.crushingWalls))
            {
                walls.Remove();
            }
        }
    }

    // #region 属性
    private static function SetBehaviourProperty<T>(entity:Entity, name:PropertyKey<T>, value:Null<T>):Void
    {
        entity.SetBehaviourField(name, value);
    }
    private static function GetBehaviourProperty<T>(entity:Entity, name:PropertyKey<T>):Null<T>
    {
        return entity.GetBehaviourField(name);
    }

    public static function GetMoveDirection(entity:Entity):Vector3
    {
        return GetBehaviourProperty(entity, PROP_MOVE_DIRECTION);
    }
    public static function SetMoveDirection(entity:Entity, value:Vector3):Void
    {
        SetBehaviourProperty(entity, PROP_MOVE_DIRECTION, value);
    }

    public static function GetMoveRNG(entity:Entity):Null<RandomGenerator>
    {
        return GetBehaviourProperty(entity, PROP_MOVE_RNG);
    }
    public static function SetMoveRNG(entity:Entity, value:RandomGenerator):Void
    {
        SetBehaviourProperty(entity, PROP_MOVE_RNG, value);
    }

    public static function GetStateRNG(entity:Entity):Null<RandomGenerator>
    {
        return GetBehaviourProperty(entity, PROP_STATE_RNG);
    }
    public static function SetStateRNG(entity:Entity, value:RandomGenerator):Void
    {
        SetBehaviourProperty(entity, PROP_STATE_RNG, value);
    }

    public static function GetSparkRNG(entity:Entity):Null<RandomGenerator>
    {
        return GetBehaviourProperty(entity, PROP_SPARK_RNG);
    }
    public static function SetSparkRNG(entity:Entity, value:RandomGenerator):Void
    {
        SetBehaviourProperty(entity, PROP_SPARK_RNG, value);
    }

    public static function GetCorpsePositions(entity:Entity):Null<Array<Vector3>>
    {
        return GetBehaviourProperty(entity, PROP_CORPSE_POSITIONS);
    }
    public static function SetCorpsePositions(entity:Entity, value:Array<Vector3>):Void
    {
        SetBehaviourProperty(entity, PROP_CORPSE_POSITIONS, value);
    }
    // #endregion

    public static var PROP_MOVE_DIRECTION:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("MoveDirection");
    public static var PROP_MOVE_RNG:VanillaEntityPropertyMeta<RandomGenerator> = new VanillaEntityPropertyMeta<RandomGenerator>("MoveRNG");
    public static var PROP_STATE_RNG:VanillaEntityPropertyMeta<RandomGenerator> = new VanillaEntityPropertyMeta<RandomGenerator>("StateRNG");
    public static var PROP_SPARK_RNG:VanillaEntityPropertyMeta<RandomGenerator> = new VanillaEntityPropertyMeta<RandomGenerator>("SparkRNG");
    public static var PROP_CORPSE_POSITIONS:VanillaEntityPropertyMeta<Array<Vector3>> = new VanillaEntityPropertyMeta<Array<Vector3>>("CorpsePositions");

    public static inline var FLY_HEIGHT:Float = 20;

    public static var CENTER_POSITION:Vector3 = new Vector3(620, 0, 300);
    public static var APPEAR_POSITION:Vector3 = new Vector3(620, 300, 0);
    public static inline var SPIN_DAMAGE_INTERVAL:Int = 3;
    public static inline var SPIN_RADIUS:Float = 120;
    public static inline var SPIN_HEIGHT:Float = 50;
    public static inline var MAX_REVIVE_COUNT:Int = 10;

    public static var stateMachine:EntityStateMachine = new NightmareaperStateMachine();

    // #region 状态机
    public static function StopSpinSound(entity:Entity):Void
    {
        entity.Level.RemoveLoopSoundEntity(VanillaSoundID.wheelOfDeathLoop, entity.ID);
    }
    public static function GetOutbound(entity:Entity):Int
    {
        var leftX = LevelPositions.LEFT_BORDER + 40;
        var rightX = LevelPositions.RIGHT_BORDER - 40;
        var topY = entity.Level.GetGridTopZ();
        var bottomY = entity.Level.GetGridBottomZ();
        if (entity.Position.x <= leftX)
        {
            return 0;
        }
        else if (entity.Position.z <= bottomY)
        {
            return 1;
        }
        else if (entity.Position.x >= rightX)
        {
            return 2;
        }
        else if (entity.Position.z >= topY)
        {
            return 3;
        }
        return -1;
    }
    public static function IsInWheelRange(self:Entity, target:Entity):Bool
    {
        var pos = self.Position;
        var otherPos = target.Position;
        var vector = new Vector2(pos.x - otherPos.x, pos.z - otherPos.z);
        var selfBounds = self.GetBounds();
        var targetBounds = target.GetBounds();
        return vector.magnitude < SPIN_RADIUS && Detection.IsYCoincide(selfBounds.min.y, selfBounds.size.y, targetBounds.min.y, targetBounds.size.y);
    }
    public static function FindJabTarget(entity:Entity):Null<Entity>
    {
        targetBuffer = [];
        entity.Level.FindEntitiesNonAlloc(function(c) return LogicEntityExt.IsVulnerableEntity(c) && entity.IsHostile(c), targetBuffer);
        if (targetBuffer.length > 0)
        {
            var actRNG = GetStateRNG(entity);
            return actRNG != null ? EnumerableExt.Random(targetBuffer, actRNG) : EnumerableExt.FirstOrDefault(targetBuffer);
        }
        return null;
    }

    public static var targetBuffer:Array<Entity> = [];
    // #endregion

    public static var statePool:Array<Int> = [
        STATE_JAB,
        STATE_DARKNESS,
        STATE_SPIN,
        STATE_REVIVE
    ];
    public static inline var STATE_APPEAR:Int = VanillaBossStates.APPEAR;
    public static inline var STATE_IDLE:Int = VanillaBossStates.IDLE;
    public static inline var STATE_DEATH:Int = VanillaBossStates.DEATH;
    public static inline var STATE_JAB:Int = VanillaBossStates.NIGHTMAREAPER_JAB;
    public static inline var STATE_SPIN:Int = VanillaBossStates.NIGHTMAREAPER_SPIN;
    public static inline var STATE_DARKNESS:Int = VanillaBossStates.NIGHTMAREAPER_DARKNESS;
    public static inline var STATE_REVIVE:Int = VanillaBossStates.NIGHTMAREAPER_REVIVE;
    public static inline var STATE_ENRAGE:Int = VanillaBossStates.NIGHTMAREAPER_ENRAGE;

    public static inline var ANIMATION_STATE_IDLE:Int = 0;
    public static inline var ANIMATION_STATE_APPEAR:Int = 1;
    public static inline var ANIMATION_STATE_JAB:Int = 2;
    public static inline var ANIMATION_STATE_DEATH:Int = 3;
    public static inline var ANIMATION_STATE_SPIN:Int = 4;
    public static inline var ANIMATION_STATE_DARKNESS:Int = 5;
    public static inline var ANIMATION_STATE_REVIVE:Int = 6;
    public static inline var ANIMATION_STATE_ENRAGE:Int = 7;
}

private class NightmareaperStateMachine extends EntityStateMachine
{
    public function new()
    {
        super();
        AddState(new NightmareaperAppearState());
        AddState(new NightmareaperIdleState());
        AddState(new JabState());
        AddState(new SpinState());
        AddState(new DarknessState());
        AddState(new ResurrectState());
        AddState(new EnragedState());
        AddState(new NightmareaperDeathState());
    }
}

// #region 出现
private class NightmareaperAppearState extends EntityStateMachineState
{
    public function new()
    {
        super(Nightmareaper.STATE_APPEAR, Nightmareaper.ANIMATION_STATE_APPEAR);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        entity.Position = Nightmareaper.APPEAR_POSITION;
        var stateTimer = stateMachine.GetStateTimer(entity);
        if (stateTimer != null)
            stateTimer.ResetTime(72);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var stateTimer = stateMachine.GetStateTimer(entity);
        if (stateTimer != null)
        {
            stateTimer.Run();
            var t = (stateTimer.Frame / 30) - 0.25;
            entity.Position = Vector3.Lerp(Nightmareaper.APPEAR_POSITION, Nightmareaper.CENTER_POSITION, t);
        }
        stateMachine.StartState(entity, Nightmareaper.STATE_IDLE);
    }
}
// #endregion

// #region 空闲
private class NightmareaperIdleState extends EntityStateMachineState
{
    public function new()
    {
        super(Nightmareaper.STATE_IDLE, Nightmareaper.ANIMATION_STATE_IDLE);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var stateTimer = stateMachine.GetStateTimer(entity);
        if (stateTimer != null)
            stateTimer.ResetTime(150);
        entity.SetAnimationBool("FlapWing", true);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var stateTimer = stateMachine.GetStateTimer(entity);
        if (stateTimer.RunToExpiredAndNotNull())
        {
            SwitchState(stateMachine, entity);
        }
        UpdateMoveDirection(entity);
        Nightmareaper.StopSpinSound(entity);
    }
    public function SwitchState(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        var lastState = stateMachine.GetPreviousState(entity);
        var lastStateIndex = Nightmareaper.statePool.indexOf(lastState);
        var currentStateIndex = lastStateIndex;
        for (i in 1...(Nightmareaper.statePool.length * 2))
        {
            currentStateIndex = (currentStateIndex + 1) % Nightmareaper.statePool.length;
            var currentState = Nightmareaper.statePool[currentStateIndex];
            switch (currentState)
            {
                case Nightmareaper.STATE_JAB:
                    var jabTarget = Nightmareaper.FindJabTarget(entity);
                    entity.Target = jabTarget;
                    if (jabTarget != null)
                    {
                        stateMachine.StartState(entity, currentState);
                        stateMachine.SetPreviousState(entity, currentState);
                        return;
                    }
                case Nightmareaper.STATE_DARKNESS, Nightmareaper.STATE_SPIN:
                    stateMachine.StartState(entity, currentState);
                    stateMachine.SetPreviousState(entity, currentState);
                    return;
                case Nightmareaper.STATE_REVIVE:
                    var corpsePositions = Nightmareaper.GetCorpsePositions(entity);
                    if (corpsePositions != null && corpsePositions.length > 0)
                    {
                        stateMachine.StartState(entity, currentState);
                        stateMachine.SetPreviousState(entity, currentState);
                        return;
                    }
            }
        }
    }
    private function UpdateMoveDirection(entity:Entity):Void
    {
        var moveDirection = Nightmareaper.GetMoveDirection(entity);

        var velocity = entity.Velocity;
        var magnitude = velocity.magnitude;
        if (magnitude < 4)
        {
            magnitude += 0.05;
        }
        velocity = moveDirection * magnitude;
        velocity.y = entity.Velocity.y;
        entity.Velocity = velocity;

        var leftX = Nightmareaper.CENTER_POSITION.x + 40;
        var rightX = LevelPositions.RIGHT_BORDER - 40;
        var topY = entity.Level.GetGridTopZ();
        var bottomY = entity.Level.GetGridBottomZ();
        var outOfRightRegion = entity.Position.x <= leftX || entity.Position.z <= bottomY || entity.Position.x >= rightX || entity.Position.z >= topY;
        if (outOfRightRegion)
        {
            var center = new Vector3((leftX + rightX) * 0.5, 0, (topY + bottomY) * 0.5);
            moveDirection = (center - entity.Position).normalized;
        }
        else
        {
            var moveRNG = Nightmareaper.GetMoveRNG(entity);
            var dir:Float = moveRNG != null ? moveRNG.Next(-1, 1) : 0;
            var angle = dir * 10;
            var axis = Vector3.up * angle;
            var rotation = Quaternion.Euler(axis.x, axis.y, axis.z);
            moveDirection = (rotation * moveDirection).normalized;

            // Fix z to fit current lane.
            var laneZ = entity.Level.GetEntityLaneZ(entity.GetLane());
            var laneFix = (laneZ - entity.Position.z) * 0.133 * Vector3.forward;
            entity.Position += laneFix;
        }
        Nightmareaper.SetMoveDirection(entity, moveDirection);
    }
}
// #endregion

// #region 戳刺
private class JabState extends EntityStateMachineState
{
    public function new()
    {
        super(Nightmareaper.STATE_JAB, Nightmareaper.ANIMATION_STATE_JAB);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        entity.TriggerAnimation("Jab");
        var subStateTimer = stateMachine.GetSubStateTimer(entity);
        if (subStateTimer != null)
            subStateTimer.ResetTime(21);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer.RunToExpiredAndNotNull(stateMachine.GetSpeed(entity)))
        {
            var substate = stateMachine.GetSubState(entity);
            switch (substate)
            {
                case SUBSTATE_READY_1, SUBSTATE_READY_2, SUBSTATE_READY_3:
                    if (entity.Target != null)
                        Jab(entity, entity.Target);
                    stateMachine.StartSubState(entity, substate + 1);
                    substateTimer.ResetTime(9);

                case SUBSTATE_JAB_1, SUBSTATE_JAB_2:
                    var jabTarget = Nightmareaper.FindJabTarget(entity);
                    entity.Target = jabTarget;
                    if (jabTarget != null)
                    {
                        entity.TriggerAnimation("Jab");
                        stateMachine.StartSubState(entity, substate + 1);
                        substateTimer.ResetTime(21);
                    }
                    else
                    {
                        stateMachine.StartState(entity, Nightmareaper.STATE_IDLE);
                    }

                case SUBSTATE_JAB_3:
                    stateMachine.StartState(entity, Nightmareaper.STATE_IDLE);
            }
        }
    }

    private function Jab(entity:Entity, target:Entity):Void
    {
        var beforePos = entity.Position;
        entity.Position = target.GetCenter() + Vector3.up * 40;
        entity.Velocity = Vector3.zero;
        // Create shadow trails.
        var distance = entity.Position - beforePos;
        var magnitude = distance.magnitude;
        var normalized = distance.normalized;
        var i:Float = 0;
        while (i < magnitude)
        {
            var pos = beforePos + normalized * i;
            var shadow = entity.Spawn(VanillaEffectID.nightmareaperShadow, pos);
            if (shadow != null)
            {
                shadow.Timeout = Mathf.CeilToInt(i / magnitude * 30);
            }
            i += 16;
        }
        // Jab.
        var jabbed = false;
        var overlapParam = OverlapParams.Hostile(entity.GetFaction(), EntityCollisionHelper.MASK_VULNERABLE);
        for (collider in entity.Level.OverlapBox(target.GetCenter(), Vector3.one * 40, overlapParam))
        {
            var damage = VanillaEntityProps.GetTakenCrushDamage(collider.Entity);
            var damageOutput = collider.TakeDamage(damage, new DamageEffectList([VanillaDamageEffects.SLICE]), entity);
            if (damageOutput.HasAnyFatal())
            {
                jabbed = true;
            }
        }
        if (jabbed)
        {
            entity.PlaySound(VanillaSoundID.smash);
            entity.Level.ShakeScreen(5, 0, 9);
        }
    }

    public static inline var SUBSTATE_READY_1:Int = 0;
    public static inline var SUBSTATE_JAB_1:Int = 1;
    public static inline var SUBSTATE_READY_2:Int = 2;
    public static inline var SUBSTATE_JAB_2:Int = 3;
    public static inline var SUBSTATE_READY_3:Int = 4;
    public static inline var SUBSTATE_JAB_3:Int = 5;
}
// #endregion

// #region 旋转
private class SpinState extends EntityStateMachineState
{
    public function new()
    {
        super(Nightmareaper.STATE_SPIN, Nightmareaper.ANIMATION_STATE_SPIN);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var subStateTimer = stateMachine.GetSubStateTimer(entity);
        if (subStateTimer != null)
            subStateTimer.ResetTime(30);
        entity.SetAnimationBool("FlapWing", false);
        entity.PlaySound(VanillaSoundID.wheelOfDeathStart);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer == null)
            return;
        substateTimer.Run(stateMachine.GetSpeed(entity));

        var substate = stateMachine.GetSubState(entity);
        switch (substate)
        {
            case SUBSTATE_START:
                StartOrEndUpdate(entity);
                if (substateTimer.Expired)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_LOOP);
                    substateTimer.ResetTime(210);
                }

            case SUBSTATE_LOOP:
                LoopUpdate(entity);
                if (substateTimer.Expired && Nightmareaper.GetOutbound(entity) < 0)
                {
                    stateMachine.StartSubState(entity, SUBSTATE_END);
                    substateTimer.ResetTime(30);
                }

            case SUBSTATE_END:
                StartOrEndUpdate(entity);
                if (substateTimer.Expired)
                {
                    stateMachine.StartState(entity, Nightmareaper.STATE_IDLE);
                }
        }
    }
    override public function OnExit(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnExit(stateMachine, entity);
        Nightmareaper.StopSpinSound(entity);
    }
    private function SetSpinVelocity(entity:Entity):Void
    {
        var angelicSpeed:Float = 10;
        var targetRadius:Float = 240;


        var center2D = new Vector2(Nightmareaper.CENTER_POSITION.x, Nightmareaper.CENTER_POSITION.z);
        var pos2D = new Vector2(entity.Position.x, entity.Position.z);
        var velocity2D = new Vector2(entity.Velocity.x, entity.Velocity.z);

        var pos2Center2D = pos2D - center2D;
        var radius = pos2Center2D.magnitude;
        var direction = pos2Center2D.normalized;

        radius = radius * 0.5 + targetRadius * 0.5;
        var nextPosition = center2D + VectorExt.RotateClockwise(direction, angelicSpeed) * radius;
        var targetVelocity = nextPosition - pos2D;
        velocity2D = velocity2D * 0.5 + targetVelocity * 0.5;

        var velocity = new Vector3(velocity2D.x, 0, velocity2D.y);
        entity.Velocity = velocity;
    }
    private function StartOrEndUpdate(entity:Entity):Void
    {
        var magnitude = entity.Velocity.magnitude;
        var acc:Float = 3.333;
        if (magnitude * (magnitude - acc) <= 0)
        {
            entity.Velocity = Vector3.zero;
        }
        else
        {
            entity.Velocity -= entity.Velocity.normalized * acc;
        }
    }
    private function LoopUpdate(entity:Entity):Void
    {
        SetSpinVelocity(entity);

        var level = entity.Level;
        if (entity.IsTimeInterval(Nightmareaper.SPIN_DAMAGE_INTERVAL))
        {
            var rng = Nightmareaper.GetStateRNG(entity);
            detectBuffer = [];

            var point0 = entity.GetCenter() + Vector3.up * Nightmareaper.SPIN_HEIGHT * 0.5;
            var point1 = entity.GetCenter() + Vector3.down * Nightmareaper.SPIN_HEIGHT * 0.5;
            var overlapParam = OverlapParams.Hostile(entity.GetFaction(), EntityCollisionHelper.MASK_VULNERABLE);
            level.OverlapCapsuleNonAlloc(point0, point1, Nightmareaper.SPIN_RADIUS, overlapParam, detectBuffer);
            for (collider in detectBuffer)
            {
                var target = collider.Entity;
                var colliderReference = collider.ToReference();
                var damage = level.GetNightmareaperSpinDamage();
                var damageOutput = collider.TakeDamage(damage, new DamageEffectList([VanillaDamageEffects.SLICE]), entity);
                PostSpinDamage(entity, damageOutput);
            }
        }
        if (!level.HasLoopSoundEntity(VanillaSoundID.wheelOfDeathLoop, entity.ID))
        {
            level.AddLoopSoundEntity(VanillaSoundID.wheelOfDeathLoop, entity.ID);
        }
    }
    private function PostSpinDamage(entity:Entity, damage:DamageOutput):Void
    {
        if (damage == null)
            return;
        if (damage.ShieldResult != null)
        {
            PostSpinDamageByResult(entity, damage.ShieldResult);
        }
        if (damage.ArmorResult != null)
        {
            PostSpinDamageByResult(entity, damage.ArmorResult);
        }
        if (damage.BodyResult != null)
        {
            PostSpinDamageByResult(entity, damage.BodyResult);
        }
    }
    private function PostSpinDamageByResult(entity:Entity, result:DamageResult):Void
    {
        var targetShell = result.ShellDefinition;
        if (targetShell == null || !VanillaShellProps.BlocksSlice(targetShell))
            return;
        // Create Particle.
        var relativePos = result.GetPosition() - entity.Position;
        var particlePos = entity.Position + relativePos.normalized * Nightmareaper.SPIN_RADIUS;
        var spark = entity.Spawn(VanillaEffectID.sliceSpark, particlePos);
        if (spark != null)
        {
            // Set Particle Angles.
            var angle = Vector2.SignedAngle(Vector2.left, new Vector2(relativePos.x, relativePos.z));
            var euler = new Vector3(0, 0, angle);
            spark.RenderRotation = euler;
        }

        // Create Sound.
        var rng = Nightmareaper.GetSparkRNG(entity);
        entity.PlaySound(VanillaSoundID.anvil, rng != null ? rng.Next(1.5, 2.5) : 2);
    }

    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_LOOP:Int = 1;
    public static inline var SUBSTATE_END:Int = 2;
    private var detectBuffer:Array<IEntityCollider> = [];
}
// #endregion

// #region 黑暗
private class DarknessState extends EntityStateMachineState
{
    public function new()
    {
        super(Nightmareaper.STATE_DARKNESS, Nightmareaper.ANIMATION_STATE_DARKNESS);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        entity.TriggerAnimation("Cast");
        entity.PlaySound(VanillaSoundID.reverseVampire);
        entity.PlaySound(VanillaSoundID.confuse);

        Nightmareaper.SetDarknessTimeout(entity.Level, 480);

        var stateTimer = stateMachine.GetStateTimer(entity);
        if (stateTimer != null)
            stateTimer.ResetTime(30);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var stateTimer = stateMachine.GetStateTimer(entity);
        if (stateTimer.RunToExpiredAndNotNull(stateMachine.GetSpeed(entity)))
        {
            stateMachine.StartState(entity, Nightmareaper.STATE_IDLE);
        }
    }
}
// #endregion

// #region 复活
private class ResurrectState extends EntityStateMachineState
{
    public function new()
    {
        super(Nightmareaper.STATE_REVIVE, Nightmareaper.ANIMATION_STATE_REVIVE);
    }

    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        Resurrect(entity);
        var stateTimer = stateMachine.GetStateTimer(entity);
        if (stateTimer != null)
            stateTimer.ResetTime(30);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var stateTimer = stateMachine.GetStateTimer(entity);
        if (stateTimer.RunToExpiredAndNotNull(stateMachine.GetSpeed(entity)))
        {
            stateMachine.StartState(entity, Nightmareaper.STATE_IDLE);
        }
    }
    private function Resurrect(entity:Entity):Void
    {
        var corpsePositions = Nightmareaper.GetCorpsePositions(entity);
        if (corpsePositions != null)
        {
            for (position in corpsePositions)
            {
                var pos = position;
                pos.y = entity.Level.GetGroundY(pos.x, pos.z);
                var skeleton = entity.SpawnWithParams(VanillaEnemyID.skeleton, pos);
                if (skeleton != null)
                {
                    entity.Spawn(VanillaEffectID.boneParticles, skeleton.GetCenter());
                }
                entity.PlaySound(VanillaSoundID.boneWallBuild);
            }
            corpsePositions.resize(0);
        }

        entity.TriggerAnimation("Cast");
        entity.PlaySound(VanillaSoundID.reviveCast);
        entity.PlaySound(VanillaSoundID.revived);
    }
}
// #endregion

// #region 激怒
private class EnragedState extends EntityStateMachineState
{
    public function new()
    {
        super(Nightmareaper.STATE_ENRAGE, Nightmareaper.ANIMATION_STATE_ENRAGE);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var substateTimer = stateMachine.GetSubStateTimer(entity);
        if (substateTimer != null)
            substateTimer.ResetTime(30);

        entity.PlaySound(VanillaSoundID.nightmareaperRage);
        entity.SetAnimationBool("FlapWing", false);
        entity.SetAnimationBool("Shake", true);
        entity.SetModelProperty("RageState", 0);

        for (wall in entity.Level.FindEntities(VanillaEffectID.crushingWalls))
        {
            CrushingWalls.Enrage(wall);
        }

        Nightmareaper.CancelDarkness(entity.Level);
    }
    override public function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);

        entity.Position = (entity.Position - Nightmareaper.CENTER_POSITION) * 0.9 + Nightmareaper.CENTER_POSITION;

        var subStateTimer = stateMachine.GetSubStateTimer(entity);
        if (subStateTimer == null)
            return;
        subStateTimer.Run(stateMachine.GetSpeed(entity));

        var substate = stateMachine.GetSubState(entity);

        switch (substate)
        {
            case SUBSTATE_START:
                if (subStateTimer.Expired)
                {
                    entity.SetModelProperty("RageState", 1);
                    entity.SetModelProperty("RageProgress", 0);
                    entity.SetAnimationBool("Shake", false);
                    stateMachine.StartSubState(entity, SUBSTATE_EXTEND);
                    subStateTimer.ResetTime(15);
                }
            case SUBSTATE_EXTEND:

                entity.SetModelProperty("RageProgress", 1 - (subStateTimer.Frame / 15));

                if (subStateTimer.Expired)
                {
                    entity.Level.ShakeScreen(20, 0, 15);

                    for (wall in entity.Level.FindEntities(VanillaEffectID.crushingWalls))
                    {
                        CrushingWalls.Shake(wall, 20, 0, 15);
                    }
                    entity.PlaySound(VanillaSoundID.smash);
                    subStateTimer.ResetTime(15);
                    stateMachine.StartSubState(entity, SUBSTATE_INSERT);
                }
            case SUBSTATE_INSERT:
                entity.SetModelProperty("RageProgress", 1);

                if (subStateTimer.Expired)
                {
                    entity.SetModelProperty("RageState", 2);
                    entity.SetModelProperty("RageProgress", 0);
                    for (wall in entity.Level.FindEntities(VanillaEffectID.crushingWalls))
                    {
                        CrushingWalls.Close(wall);
                    }
                    subStateTimer.ResetTime(15);
                    stateMachine.StartSubState(entity, SUBSTATE_PULL);
                }
            case SUBSTATE_PULL:
                entity.SetModelProperty("RageProgress", 1 - (subStateTimer.Frame / 15));
        }
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_EXTEND:Int = 1;
    public static inline var SUBSTATE_INSERT:Int = 2;
    public static inline var SUBSTATE_PULL:Int = 3;
}
// #endregion

// #region 死亡
private class NightmareaperDeathState extends EntityStateMachineState
{
    public function new()
    {
        super(Nightmareaper.STATE_DEATH, Nightmareaper.ANIMATION_STATE_DEATH);
    }
    override public function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        entity.SetAnimationBool("Shake", true);
        entity.SetAnimationBool("FlapWing", false);
        var subStateTimer = stateMachine.GetSubStateTimer(entity);
        if (subStateTimer != null)
            subStateTimer.ResetTime(159);
        entity.RemoveBuffs(FlyBuff);
        Nightmareaper.StopSpinSound(entity);
    }
    override public function OnUpdateLogic(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(stateMachine, entity);

        var subStateTimer = stateMachine.GetSubStateTimer(entity);
        var substate = stateMachine.GetSubState(entity);

        if (substate != SUBSTATE_DROP)
        {
            entity.Velocity = Vector3.zero;
            var center = Nightmareaper.CENTER_POSITION;
            center.y = 100;
            if ((center - entity.Position).magnitude > 20)
            {
                entity.Position += (center - entity.Position).normalized * 3;
            }
        }

        if (subStateTimer == null)
            return;
        subStateTimer.Run();
        switch (substate)
        {
            case SUBSTATE_START:
                if (subStateTimer.Expired)
                {
                    entity.SetAnimationBool("Shake", false);
                    subStateTimer.ResetTime(21);
                    stateMachine.StartSubState(entity, SUBSTATE_FAINT);
                }
            case SUBSTATE_FAINT:
                if (subStateTimer.Expired)
                {
                    entity.AddBuff(NightmareaperFallBuff);
                    subStateTimer.ResetTime(60);
                    stateMachine.StartSubState(entity, SUBSTATE_DROP);
                }
            case SUBSTATE_DROP:
                if (subStateTimer.Expired)
                {
                    entity.Remove();
                }
        }
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_FAINT:Int = 1;
    public static inline var SUBSTATE_DROP:Int = 2;
}
// #endregion
