// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Common/StateEnemy.cs
package mvz2.vanilla.enemies;

import mvz2.gamecontent.enemies.EnemyBehaviour;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.enemies.VanillaEnemyExt;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEnemyProps;
import mvz2logic.entities.LogicEnemyStates;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.PropertyRegions;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import tools.FrameTimer;

// PORT-NOTE: C# 的扩展方法在本移植中为静态方法；调用点沿用扩展方法风格，故以 `using` 引入对应模块。
using mvz2.vanilla.enemies.VanillaEnemyExt;
using mvz2.vanilla.enemies.VanillaEnemyProps;
using mvz2logic.entities.LogicEnemyProps;

// [Obsolete]
// abstract
class StateEnemy extends EnemyBehaviour
{
    // PORT-NOTE: C# 的 protected 构造函数在 Haxe 的包外子类中不可用，此处保持 public。
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        entity.State = GetActionState(entity);
        UpdateActionState(entity, entity.State);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        if (entity.State == STATE_DEATH)
        {
            UpdateStateDead(entity);
        }
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        SetDeathTimer(entity, new FrameTimer(30));
    }
    public static function GetDeathTimer(entity:Entity):Null<FrameTimer>
    {
        return entity.GetBehaviourField(PROP_DEATH_TIMER);
    }
    public static function SetDeathTimer(entity:Entity, frameTimer:FrameTimer):Void
    {
        entity.SetBehaviourField(PROP_DEATH_TIMER, frameTimer);
    }
    function GetActionState(enemy:Entity):Int
    {
        if (enemy.IsDead)
        {
            return STATE_DEATH;
        }
        else if (enemy.IsPreviewEnemy())
        {
            return STATE_IDLE;
        }
        else
        {
            var over = enemy.GetStateOverride();
            if (over >= 0)
            {
                return over;
            }
            else if (enemy.Target != null)
            {
                return STATE_MELEE_ATTACK;
            }
            else
            {
                return STATE_WALK;
            }
        }
    }
    function UpdateActionState(enemy:Entity, state:Int):Void
    {
        enemy.SetAnimationInt("State", state);
        switch (state)
        {
            case STATE_WALK:
                UpdateStateWalk(enemy);
            case STATE_MELEE_ATTACK:
                UpdateStateAttack(enemy);
            case STATE_CAST:
                UpdateStateCast(enemy);
            case STATE_IDLE:
                UpdateStateIdle(enemy);
        }
    }
    function WalkUpdate(enemy:Entity):Void
    {
        enemy.UpdateWalkVelocity();
    }
    function UpdateStateWalk(enemy:Entity):Void
    {
        WalkUpdate(enemy);
    }
    function UpdateStateDead(enemy:Entity):Void
    {
        var deathTimer = GetDeathTimer(enemy);
        if (deathTimer == null)
        {
            deathTimer = new FrameTimer(30);
            SetDeathTimer(enemy, deathTimer);
        }
        deathTimer.Run();
        if (deathTimer.Expired)
        {
            enemy.FaintRemove();
        }
    }
    function UpdateStateAttack(enemy:Entity):Void
    {
    }
    function UpdateStateCast(enemy:Entity):Void
    {
    }
    function UpdateStateIdle(enemy:Entity):Void
    {
    }
    static inline var PROP_REGION:String = "state_enemy";
    public static inline var STATE_IDLE:Int = LogicEnemyStates.IDLE;
    public static inline var STATE_WALK:Int = LogicEnemyStates.WALK;
    public static inline var STATE_MELEE_ATTACK:Int = LogicEnemyStates.MELEE_ATTACK;
    public static inline var STATE_CAST:Int = LogicEnemyStates.CAST;
    public static inline var STATE_DEATH:Int = LogicEnemyStates.DEATH;
    @:entityPropertyRegistry(PROP_REGION)
    public static var PROP_DEATH_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("DeathTimer");
}
