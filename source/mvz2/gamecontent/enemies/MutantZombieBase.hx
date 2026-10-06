// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter12/MutantZombieBase.cs
// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter12/MutantZombieBase_States.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.MutantZombieDetector;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detection;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.enemies.VanillaEnemyStates;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2.vanilla.statemachine.EntityStateMachine;
import mvz2.vanilla.statemachine.EntityStateMachineState;
import mvz2logic.entities.LogicEnemyStates;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.PropertyRegions;
import pvzengine.collisions.IEntityCollider;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import unity.Vector3;
using mvz2.vanilla.enemies.VanillaEnemyExt;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEnemyProps;
using mvz2logic.entities.LogicEntityExt;

// PORT-NOTE: C# 的 partial class MutantZombieBase 由 MutantZombieBase.cs 与 MutantZombieBase_States.cs 合并为本文件。
// PORT-NOTE: C# 的嵌套状态类提升为模块级类，并加 MutantZombie_ 前缀以避免与包内其它状态类重名。
// abstract
class MutantZombieBase extends EnemyBehaviour
{
    // PORT-NOTE: C# 的 protected 构造函数在 Haxe 的包外子类中不可用，此处保持 public。
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        stateMachine.Init(entity);
        stateMachine.StartState(entity, STATE_IDLE);

        SetHasImp(entity, true);
        SetWeapon(entity, entity.RNG.Next(3));
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
        entity.SetModelProperty("NoImp", !HasImp(entity));
        entity.SetModelProperty("Weapon", entity.State == STATE_DEATH ? -1 : GetWeapon(entity));
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        if (entity.WillRemoveOnDeath(info))
            return;
        stateMachine.StartState(entity, STATE_DEATH);
    }
    public static function HasImp(entity:Entity):Bool return entity.GetBehaviourField(FIELD_HAS_IMP);
    public static function SetHasImp(entity:Entity, value:Bool):Void entity.SetBehaviourField(FIELD_HAS_IMP, value);
    public static function GetWeapon(entity:Entity):Int return entity.GetBehaviourField(FIELD_WEAPON);
    public static function SetWeapon(entity:Entity, value:Int):Void entity.SetBehaviourField(FIELD_WEAPON, value);

    @:entityPropertyRegistry(PROP_REGION)
    public static var FIELD_HAS_IMP:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("HasImp");
    @:entityPropertyRegistry(PROP_REGION)
    public static var FIELD_WEAPON:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("Weapon");

    static inline var PROP_REGION:String = "mutant_zombie_base";
    static var stateMachine:EntityStateMachine = new MutantZombieBaseStateMachine();
    static var attackDetector:Detector = new MutantZombieDetector(0);
    // PORT-NOTE: C# 中 hammerDetector 是 MutantZombieBase 的 private static 字段（partial class 的
    // MutantZombieBase_States.cs 部分在同一类内可直接访问）。Haxe 的 private 对同模块的其它类不可见，
    // 而 MutantZombie_AttackState 需要用它，故与 UpdateState 一样改为 public static。
    public static var hammerDetector:Detector = makeHammerDetector();

    static function makeHammerDetector():Detector
    {
        var d:Detector = new MutantZombieDetector(40);
        cast(d, MutantZombieDetector).canDetectInvisible = true;
        return d;
    }

    //region 状态机
    // PORT-NOTE: C# 中为 private static，因状态类无法访问私有成员，改为 public static。
    public static function UpdateState(zombie:Entity):Void
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
        else if (CheckThrow(zombie))
        {
            targetState = STATE_THROW;
        }
        else if (CheckAttackTarget(zombie))
        {
            targetState = STATE_SMASH;
        }
        if (zombie.State != targetState)
        {
            stateMachine.StartState(zombie, targetState);
        }
    }
    //endregion

    //region 攻击
    static function CheckAttackTarget(zombie:Entity):Bool
    {
        return attackDetector.DetectExists(DetectionParams.fromEntity(zombie));
    }
    //endregion

    //region 投掷
    static function CheckThrow(zombie:Entity):Bool
    {
        if (!HasImp(zombie))
            return false;
        if (zombie.Health >= zombie.GetMaxHealth() * 0.5)
            return false;
        var level = zombie.Level;
        var midColumn = Std.int(level.GetMaxColumnCount() / 2) + 1;
        // PORT-NOTE: C# 扩展方法 Entity.IsInTheRearOf(float x)；Haxe 无重载，
        // 同名的 (float,float,bool) 版本保留原名，Entity 版本改名为 IsInTheRearOfEntity。
        return Detection.IsInTheRearOfEntity(zombie, level.GetColumnX(midColumn));
    }
    //endregion

    public static inline var STATE_IDLE:Int = LogicEnemyStates.IDLE;
    public static inline var STATE_WALK:Int = LogicEnemyStates.WALK;
    public static inline var STATE_SMASH:Int = VanillaEnemyStates.MUTANT_ZOMBIE_SMASH;
    public static inline var STATE_THROW:Int = VanillaEnemyStates.MUTANT_ZOMBIE_THROW;
    public static inline var STATE_DEATH:Int = LogicEnemyStates.DEATH;

    public static inline var ANIMATION_STATE_IDLE:Int = EnemyCommonAnimationBehaviour.ANIMATION_STATE_IDLE;
    public static inline var ANIMATION_STATE_WALK:Int = EnemyCommonAnimationBehaviour.ANIMATION_STATE_WALK;
    public static inline var ANIMATION_STATE_DEATH:Int = EnemyCommonAnimationBehaviour.ANIMATION_STATE_DEATH;
    public static inline var ANIMATION_STATE_SMASH:Int = EnemyCommonAnimationBehaviour.ANIMATION_STATE_PRIVATE + 0;
    public static inline var ANIMATION_STATE_THROW:Int = EnemyCommonAnimationBehaviour.ANIMATION_STATE_PRIVATE + 1;
}

private class MutantZombieBaseStateMachine extends EntityStateMachine
{
    public function new()
    {
        super();
        AddState(new MutantZombie_IdleState());
        AddState(new MutantZombie_WalkState());
        AddState(new MutantZombie_AttackState());
        AddState(new MutantZombie_ThrowState());
        AddState(new MutantZombie_DeathState());
    }
}

//region 空闲
class MutantZombie_IdleState extends EntityStateMachineState
{
    public function new()
    {
        super(MutantZombieBase.STATE_IDLE, MutantZombieBase.ANIMATION_STATE_IDLE);
    }
    public override function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        MutantZombieBase.UpdateState(entity);
    }
}
//endregion

//region 行走
class MutantZombie_WalkState extends EntityStateMachineState
{
    public function new()
    {
        super(MutantZombieBase.STATE_WALK, MutantZombieBase.ANIMATION_STATE_WALK);
    }
    public override function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        entity.UpdateWalkVelocity();
        MutantZombieBase.UpdateState(entity);
    }
}
//endregion

//region 攻击
class MutantZombie_AttackState extends EntityStateMachineState
{
    public function new()
    {
        super(MutantZombieBase.STATE_SMASH, MutantZombieBase.ANIMATION_STATE_SMASH);
    }
    public override function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var subStateTimer = stateMachine.GetSubStateTimer(entity);
        if (subStateTimer != null)
            subStateTimer.ResetTime(40);
        entity.PlaySound(VanillaSoundID.mutantCry);
        entity.TriggerAnimation("AttackTrigger");
    }
    public override function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var subStateTimer = stateMachine.GetSubStateTimer(entity);
        var substate = stateMachine.GetSubState(entity);
        if (subStateTimer != null)
        {
            subStateTimer.Run(entity.GetAttackSpeed());
            switch (substate)
            {
                case SUBSTATE_START:
                    if (subStateTimer.Expired)
                    {
                        subStateTimer.ResetTime(20);
                        stateMachine.StartSubState(entity, SUBSTATE_ATTACKED);
                        Hammer(entity);
                    }
                case SUBSTATE_ATTACKED:
                    if (subStateTimer.Expired)
                    {
                        stateMachine.StartState(entity, MutantZombieBase.STATE_IDLE);
                    }
            }
        }
    }
    function Hammer(self:Entity):Void
    {
        var level = self.Level;
        if (self.Position.y <= self.GetRealGroundLimitY() + 5)
        {
            var x = self.Position.x + self.GetFacingX() * self.GetRange() * 0.5;
            var z = self.Position.z;
            var soundID = VanillaSoundID.thump;
            if (level.IsWaterAt(x, z))
            {
                soundID = VanillaSoundID.splashBig;
            }
            self.PlaySound(soundID);
            level.ShakeScreen(10, 0, 15);
        }

        detectBuffer = [];
        MutantZombieBase.hammerDetector.DetectMultiple(DetectionParams.fromEntity(self), detectBuffer);

        for (collider in detectBuffer)
        {
            var target = collider.Entity;
            if (target.IsOnWater())
            {
                var damageResult = collider.TakeDamage(target.GetTakenCrushDamage(), new DamageEffectList([VanillaDamageEffects.IMPACT, VanillaDamageEffects.REMOVE_ON_DEATH, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN]), self);

                // PORT-NOTE: C# 重载 PlaySplashEffect(Vector3 scale) 在 Haxe 中改名为 PlaySplashEffectWithScale。
                target.PlaySplashEffectWithScale(Vector3.one * 3);
            }
            else
            {
                var damageResult = collider.TakeDamage(target.GetTakenCrushDamage(), new DamageEffectList([VanillaDamageEffects.IMPACT, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN]), self);
                if (damageResult != null && damageResult.BodyResult != null && damageResult.BodyResult.Fatal && damageResult.BodyResult.Entity.Type == EntityTypes.PLANT)
                {
                    damageResult.Entity.PlaySound(VanillaSoundID.smash);
                }
            }
        }
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_ATTACKED:Int = 1;
    var detectBuffer:Array<IEntityCollider> = [];
}
//endregion

//region 投掷
class MutantZombie_ThrowState extends EntityStateMachineState
{
    public function new()
    {
        super(MutantZombieBase.STATE_THROW, MutantZombieBase.ANIMATION_STATE_THROW);
    }
    public override function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var subStateTimer = stateMachine.GetSubStateTimer(entity);
        if (subStateTimer != null)
            subStateTimer.ResetTime(35);
    }
    public override function OnUpdateAI(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateAI(stateMachine, entity);
        var subStateTimer = stateMachine.GetSubStateTimer(entity);
        var substate = stateMachine.GetSubState(entity);
        if (subStateTimer != null)
        {
            subStateTimer.Run(entity.GetAttackSpeed());
            switch (substate)
            {
                case SUBSTATE_START:
                    if (subStateTimer.Expired)
                    {
                        entity.PlaySound(VanillaSoundID.swing);
                        MutantZombieBase.SetHasImp(entity, false);

                        var impPos = entity.Position + new Vector3(entity.GetFacingX() * 24, 155, 0);
                        var impVel = new Vector3(entity.GetFacingX() * 20, 0, 0);
                        // C#: entity.SpawnWithParams(...)?.Let(e => { ... })
                        var e = entity.SpawnWithParams(VanillaEnemyID.imp, impPos);
                        if (e != null)
                        {
                            e.PlaySound(VanillaSoundID.impLaugh);
                            e.Velocity = impVel;
                        }

                        subStateTimer.ResetTime(10);
                        stateMachine.StartSubState(entity, SUBSTATE_THROWN);
                    }
                case SUBSTATE_THROWN:
                    if (subStateTimer.Expired)
                    {
                        stateMachine.StartState(entity, MutantZombieBase.STATE_IDLE);
                    }
            }
        }
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_THROWN:Int = 1;
}
//endregion

//region 死亡
class MutantZombie_DeathState extends EntityStateMachineState
{
    public function new()
    {
        super(MutantZombieBase.STATE_DEATH, MutantZombieBase.ANIMATION_STATE_DEATH);
    }
    public override function OnEnter(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnEnter(stateMachine, entity);
        var subStateTimer = stateMachine.GetSubStateTimer(entity);
        if (subStateTimer != null)
            subStateTimer.ResetTime(120);

        // C#: entity.Spawn(...)?.Let(e => { ... })
        var e = entity.Spawn(VanillaEffectID.mutantZombieWeapon, entity.Position + new Vector3(0, 71, 0));
        if (e != null)
        {
            e.SetModelProperty("Weapon", MutantZombieBase.GetWeapon(entity));
        }
    }
    public override function OnUpdateLogic(stateMachine:EntityStateMachine, entity:Entity):Void
    {
        super.OnUpdateLogic(stateMachine, entity);
        var subStateTimer = stateMachine.GetSubStateTimer(entity);
        var substate = stateMachine.GetSubState(entity);
        if (subStateTimer != null)
        {
            subStateTimer.Run();
            switch (substate)
            {
                case SUBSTATE_START:
                    if (subStateTimer.Expired)
                    {
                        entity.Level.ShakeScreen(10, 0, 10);
                        entity.PlaySound(VanillaSoundID.thump);
                        subStateTimer.ResetTime(30);
                        stateMachine.StartSubState(entity, SUBSTATE_DROP);
                    }
                case SUBSTATE_DROP:
                    if (subStateTimer.Expired)
                    {
                        entity.FaintRemove();
                    }
            }
        }
        if (!entity.IsDead)
        {
            stateMachine.StartState(entity, MutantZombieBase.STATE_IDLE);
        }
    }
    public static inline var SUBSTATE_START:Int = 0;
    public static inline var SUBSTATE_DROP:Int = 1;
}
//endregion
