// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter4/TalismanZombie.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEnemyStates;
import pvzengine.callbacks.CallbackResult;
import pvzengine.entities.Entity;
import tools.FrameTimer;
using mvz2.vanilla.enemies.VanillaEnemyProps;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.talismanZombie)
class TalismanZombie extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_ENTITY_TAKE_DAMAGE, PostEntityTakeDamageCallback);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetMoveTimer(entity, new FrameTimer(MOVE_INTERVAL));
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (entity.State == STATE_WALK)
        {
            JumpUpdate(entity);
        }
    }
    function JumpUpdate(enemy:Entity):Void
    {
        var timer = GetMoveTimer(enemy);
        if (timer.RunToExpiredAndNotNull())
        {
            if (enemy.IsOnGround)
            {
                timer.Reset();
                var vel = enemy.GetFacingDirection() * enemy.GetSpeed() * 1;
                vel.y = 5;
                enemy.Velocity += vel;
            }
        }
    }
    function PostEntityTakeDamageCallback(param:PostTakeDamageParams, callbackResult:CallbackResult):Void
    {
        var output = param.output;
        var level = output.Entity.Level;
        for (result in output.GetAllResults())
        {
            if (result == null)
                continue;
            if (!result.HasEffect(VanillaDamageEffects.ENEMY_MELEE))
                continue;
            var source = result.Source != null ? result.Source.GetEntity(level) : null;
            if (source == null)
                continue;
            if (!source.Definition.HasBehaviour(this))
                return;
            source.HealEffects(result.Amount, source);
        }
    }
    public static function SetMoveTimer(entity:Entity, timer:FrameTimer):Void
    {
        entity.SetBehaviourField(PROP_MOVE_TIMER, timer);
    }
    public static function GetMoveTimer(entity:Entity):Null<FrameTimer>
    {
        return entity.GetBehaviourField(PROP_MOVE_TIMER);
    }
    public static inline var MOVE_INTERVAL:Int = 30;
    public static inline var STATE_WALK:Int = LogicEnemyStates.WALK;
    public static var PROP_MOVE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("MoveTimer");
}
