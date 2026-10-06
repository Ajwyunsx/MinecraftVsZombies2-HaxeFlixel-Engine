// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter1/Hoe.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.effects.VanillaEffectStates;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.callbacks.LogicLevelCallbacks;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbackParams;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.EntityTypes;
import tools.FrameTimer;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.hoe)
class Hoe extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LogicLevelCallbacks.POST_LEVEL_STOP, PostLevelStopCallback);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskHostile = EntityCollisionHelper.MASK_ENEMY;
        SetStateTimer(entity, new FrameTimer(5));
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        if (!collision.Collider.IsForMain() || !collision.OtherCollider.IsForMain())
            return;
        if (state == EntityCollisionHelper.STATE_EXIT)
            return;
        var other = collision.Other;
        if (other.Type != EntityTypes.ENEMY)
            return;
        var hoe = collision.Entity;
        if (hoe.State != STATE_IDLE)
            return;
        if (!hoe.IsHostile(other))
            return;
        hoe.State = STATE_TRIGGERED;
        hoe.SetAnimationBool("Triggered", true);
        hoe.PlaySound(VanillaSoundID.swing);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (entity.State == STATE_TRIGGERED)
        {
            var timer = GetStateTimer(entity);
            if (timer.RunToExpiredAndNotNull())
            {
                damageBuffer.resize(0);
                entity.GetCurrentCollisions(damageBuffer);
                for (collision in damageBuffer)
                {
                    var target = collision.Other;
                    if (target == null)
                        continue;
                    if (!entity.IsHostile(target) || target.Type != EntityTypes.ENEMY)
                        continue;
                    target.Die(entity);
                    entity.PlaySound(VanillaSoundID.bonk);
                }
                entity.State = STATE_DAMAGED;
                timer.ResetTime(30);
            }
        }
        else if (entity.State == STATE_DAMAGED)
        {
            var timer = GetStateTimer(entity);
            if (timer.RunToExpiredAndNotNull())
            {
                var smoke = entity.Level.Spawn(VanillaEffectID.smoke, entity.Position, null);
                if (smoke != null)
                {
                    smoke.SetSize(entity.GetSize());
                }
                entity.Remove();
            }
        }
    }
    // #endregion
    private function PostLevelStopCallback(param:LevelCallbackParams, result:CallbackResult):Void
    {
        var level = param.level;
        for (hoe in level.FindEntities(e -> e.IsEntityOf(VanillaEffectID.hoe)))
        {
            hoe.Remove();
        }
    }
    public static function SetStateTimer(entity:Entity, timer:FrameTimer):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_STATE_TIMER, timer);
    }
    public static function GetStateTimer(entity:Entity):Null<FrameTimer>
    {
        return entity.GetBehaviourFieldNS(ID, PROP_STATE_TIMER);
    }

    public static var ID:NamespaceID = VanillaEffectID.hoe;
    public static inline var STATE_IDLE:Int = VanillaEffectStates.IDLE;
    public static inline var STATE_TRIGGERED:Int = VanillaEffectStates.HOE_TRIGGERED;
    public static inline var STATE_DAMAGED:Int = VanillaEffectStates.HOE_DAMAGED;
    public static var PROP_STATE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("StateTimer");
    private var damageBuffer:Array<EntityCollision> = [];
}
