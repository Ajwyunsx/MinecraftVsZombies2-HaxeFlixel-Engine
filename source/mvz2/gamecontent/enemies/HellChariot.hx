// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter3/HellChariot.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.Explosion;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.IDestroyBySpikesEntityBehaviour;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VehicleInteraction;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.IDeathEffectsBehaviour;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.collisions.IEntityCollider;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.EntityTypes;
import tools.FrameTimer;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.entities.LogicEnemyProps;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.hellChariot)
class HellChariot extends AIEntityBehaviour implements IDestroyBySpikesEntityBehaviour implements IDeathEffectsBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    //region 回调
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetPunctureTimer(entity, new FrameTimer(PUNCTURE_TIME));
        if (!entity.IsPreviewEnemy())
        {
            entity.PlaySound(VanillaSoundID.trainWhistle);
            entity.Level.AddLoopSoundEntity(VanillaSoundID.trainTravel, entity.ID);
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);

        var broken = entity.Health <= BROKEN_THRESOLD;
        if (!entity.IsDead && broken)
        {
            entity.Health -= 2;
            if (entity.Health <= 0)
            {
                entity.Die();
            }
        }
        // 设置血量状态。
        var punctured = IsPunctured(entity);
        var hp = entity.Health;
        if (punctured)
        {
            var timer = GetPunctureTimer(entity);
            if (timer != null)
            {
                if (timer.RunToExpired())
                {
                    entity.Die();
                }
                else
                {
                    hp *= timer.Frame / timer.MaxFrame;
                }
            }
            entity.PlaySound(VanillaSoundID.shieldHit);
        }
        VanillaEntityExt.SetModelDamagePercentWithHealth(entity, hp, entity.GetMaxHealth());
        entity.SetAnimationBool("Shaking", broken || punctured);
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        if (state == EntityCollisionHelper.STATE_EXIT)
            return;
        if (!collision.Collider.IsForMain())
            return;
        var other = collision.Other;
        if (!other.IsVulnerableEntity())
            return;
        var chariot = collision.Entity;
        if (IsPunctured(chariot) || !chariot.IsHostile(other))
            return;

        Crush(chariot, collision.OtherCollider);
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        if (!entity.WillRemoveOnDeath(info))
        {
            Explosion.SpawnWithSize(entity, entity.GetCenter(), entity.GetScaledSize());
        }
    }
    public function DeathEffects(entity:Entity, info:DeathInfo):Void
    {
        var anubisandOffset = ANUBISAND_OFFSET;
        anubisandOffset.x *= entity.GetFacingX();
        var anubisand = entity.SpawnWithParams(VanillaEnemyID.anubisand, entity.Position + anubisandOffset);
        entity.Remove();
    }
    //endregion

    public function CanBeDestroyedBySpikes(entity:Entity, source:Entity):Bool
    {
        return !IsPunctured(entity);
    }
    public function DestroyBySpikes(entity:Entity, source:Entity):Void
    {
        Puncture(entity);
    }
    public static function Puncture(entity:Entity):Void
    {
        if (IsPunctured(entity))
            return;
        SetPunctured(entity, true);
        var timer = GetPunctureTimer(entity);
        if (timer != null)
            timer.Reset();
    }
    public static function Crush(chariot:Entity, otherCollider:IEntityCollider):Void
    {
        var other = otherCollider.Entity;
        var damage = other.GetTakenCrushDamage();
        var vehicleInteraction = other.GetVehicleInteraction();
        switch (vehicleInteraction)
        {
            case VehicleInteraction.BLOCK:
                damage = chariot.GetDamage() * 0.1;
            case VehicleInteraction.IGNORE:
                return;
        }

        if (!other.IsDead)
        {
            if (vehicleInteraction == VehicleInteraction.BLOCK || other.IsInvincible())
            {
                var vel = chariot.Velocity;
                if (vel.x * chariot.GetFacingX() > 0)
                {
                    vel.x = 0;
                }
                chariot.Velocity = vel;
            }
            var damageEffects = new DamageEffectList([VanillaDamageEffects.GRIND, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN]);
            // C#: otherCollider.TakeDamage(...)?.Let(o => { ... })
            var o = otherCollider.TakeDamage(damage, damageEffects, chariot);
            if (o != null)
            {
                if (o.BodyResult != null && o.BodyResult.Fatal)
                {
                    if (other.Type == EntityTypes.PLANT || other.Type == EntityTypes.OBSTACLE)
                    {
                        other.PlaySound(VanillaSoundID.smash);
                    }
                    else if (other.Type == EntityTypes.ENEMY)
                    {
                        other.PlaySound(VanillaSoundID.grind);
                    }
                }
            }
        }
    }

    //region 字段
    public static function IsPunctured(entity:Entity):Bool return entity.GetBehaviourFieldNS(ID, FIELD_PUNCTURED);
    public static function SetPunctured(entity:Entity, value:Bool):Void entity.SetBehaviourFieldNS(ID, FIELD_PUNCTURED, value);

    public static function GetPunctureTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourFieldNS(ID, FIELD_PUNCTURE_TIMER);
    public static function SetPunctureTimer(entity:Entity, value:FrameTimer):Void entity.SetBehaviourFieldNS(ID, FIELD_PUNCTURE_TIMER, value);
    //endregion

    public static inline var BROKEN_THRESOLD:Float = 200;
    public static var ANUBISAND_OFFSET:Vector3 = new Vector3(-48, 32, 0);
    public static inline var PUNCTURE_TIME:Int = 40;
    static var FIELD_PUNCTURED:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("Punctured");
    static var FIELD_PUNCTURE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("PunctureTimer");
    static var ID:NamespaceID = VanillaEnemyID.hellChariot;
}
