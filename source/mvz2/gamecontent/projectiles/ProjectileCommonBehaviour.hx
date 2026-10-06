// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/ProjectileCommonBehaviour.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostProjectileHitParams;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PreProjectileHitParams;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.ProjectileHitInput;
import mvz2.vanilla.projectiles.ProjectileHitOutput;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DamageOutput;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
import unity.Mathf;
import unity.Vector2;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2.vanilla.projectiles.VanillaProjectileProps;
using mvz2logic.entities.LogicProjectileProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.projectileCommon)
class ProjectileCommonBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Timeout = entity.GetMaxTimeout();
        entity.CollisionMaskHostile = EntityCollisionHelper.MASK_PLANT
            | EntityCollisionHelper.MASK_ENEMY
            | EntityCollisionHelper.MASK_OBSTACLE
            | EntityCollisionHelper.MASK_BOSS;
        entity.UpdatePointTowardsDirection();
        SetStartHitSpawnerProtectTimeout(entity, 2);
    }

    public override function Update(projectile:Entity):Void
    {
        super.Update(projectile);
        projectile.Timeout--;
        if (projectile.Timeout <= 0)
        {
            projectile.Die();
            return;
        }
        if (projectile.WillDestroyOutsideLawn() && projectile.IsProjectileOutsideView())
        {
            projectile.Remove();
            return;
        }
        projectile.UpdatePointTowardsDirection();

        var protectTimout = GetStartHitSpawnerProtectTimeout(projectile);
        if (protectTimout > 0)
        {
            protectTimout--;
            SetStartHitSpawnerProtectTimeout(projectile, protectTimout);
        }

        RollUpdate(projectile);
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        var entity = collision.Entity;
        if (entity.DontHitEntities())
            return;
        var spawner = entity.SpawnerReference != null ? entity.SpawnerReference.GetEntity(entity.Level) : null;
        var otherCollider = collision.OtherCollider;
        if (state == EntityCollisionHelper.STATE_EXIT)
        {
            entity.RemoveIgnoredProjectileCollider(otherCollider);
        }
        else
        {
            if (collision.Other == spawner && GetStartHitSpawnerProtectTimeout(entity) > 0)
            {
                entity.AddIgnoredProjectileCollider(otherCollider);
            }
            UnitCollide(collision);
        }
    }

    public override function PostContactGround(entity:Entity, velocity:Vector3):Void
    {
        super.PostContactGround(entity, velocity);
        if (entity.KillOnGround())
        {
            entity.Die();
        }
    }
    public override function PostDeath(entity:Entity, damageInfo:DeathInfo):Void
    {
        super.PostDeath(entity, damageInfo);
        if (damageInfo.Effects.HasEffect(VanillaDamageEffects.DROWN))
        {
            entity.PlaySplashEffect();
            entity.PlaySplashSound();
        }
        entity.Remove();
    }
    function UnitCollide(collision:EntityCollision):Void
    {
        var projectile = collision.Entity;
        if (projectile.Removed)
            return;

        // 不能击中死亡的实体。
        var other = collision.Other;
        if (other.IsDead)
            return;

        var otherCollider = collision.OtherCollider;
        // 已经击中过对方
        if (projectile.IsProjectileColliderIgnored(otherCollider))
            return;

        // 不是敌方
        if (!projectile.IsHostile(other))
            return;

        // 无视护盾
        if (projectile.IgnoreShields() && !otherCollider.IsForMain() && !otherCollider.IsForHelmet())
            return;

        // 锁定的目标
        var lockedTargetID = projectile.GetLockedTargetID();
        if (lockedTargetID != null && lockedTargetID.ID != other.ID)
            return;


        // 击中敌人前
        var hitInput = new ProjectileHitInput(projectile, other, projectile.IsPiercing());

        var damageEffects = projectile.GetDamageEffects();
        var effects:DamageEffectList;
        if (damageEffects != null)
        {
            effects = new DamageEffectList([VanillaDamageEffects.PROJECTILE].concat(damageEffects));
        }
        else
        {
            effects = new DamageEffectList([VanillaDamageEffects.PROJECTILE]);
        }
        var damageInput = otherCollider.GetDamageInput(projectile.GetDamage(), effects, projectile);
        if (damageInput == null)
            return;

        // 触发击中前回调。
        var callbackResult = new CallbackResult(true);
        // PORT-NOTE: C# 为 `var preParam = new PreProjectileHitParams(); preParam.hit = hitInput; ...`（struct 隐式无参构造 + 逐字段赋值）。
        // TODO-PORT: PreProjectileHitParams（mvz2.vanilla.callbacks.VanillaLevelCallbacks）缺少无参构造函数，
        //   暂用 Type.createEmptyInstance 构造（字段随后逐个赋值，语义等价 C# struct 的 new()）；该域补 new() 后可改回。
        var preParam = Type.createEmptyInstance(PreProjectileHitParams);
        preParam.hit = hitInput;
        preParam.damage = damageInput;
        projectile.Level.Triggers.RunCallbackWithResultFiltered(VanillaLevelCallbacks.PRE_PROJECTILE_HIT, preParam, callbackResult, projectile.GetDefinitionID());
        if (!callbackResult.GetValue())
            return;

        // 对敌人造成伤害
        var damageOutput:DamageOutput = VanillaEntityExt.TakeDamageFromInput(damageInput);

        // 击中敌人后
        var hitOutput = new ProjectileHitOutput(hitInput.Projectile, hitInput.Other, otherCollider, hitInput.Pierce);
        if (damageOutput != null)
        {
            if (damageOutput.ShieldResult != null)
            {
                hitOutput.Shield = damageOutput.ShieldResult.Armor;
            }
            else
            {
                var ethereal = damageOutput.ArmorResult != null ? false : other.IsEthereal();
                hitOutput.Pierce = ethereal || hitOutput.Pierce;
            }
        }
        // 将碰撞箱加入到已被碰撞的的列表。
        projectile.AddIgnoredProjectileCollider(otherCollider);

        // 触发击中后回调。
        // TODO-PORT: PostProjectileHitParams 同 PreProjectileHitParams，缺无参构造函数，暂用 createEmptyInstance。
        var postParam = Type.createEmptyInstance(PostProjectileHitParams);
        postParam.hit = hitOutput;
        postParam.damage = damageOutput;
        projectile.Level.Triggers.RunCallbackFiltered(VanillaLevelCallbacks.POST_PROJECTILE_HIT, postParam, projectile.GetDefinitionID());

        if (!hitOutput.Pierce)
        {
            projectile.Die();
            return;
        }
    }
    function RollUpdate(projectile:Entity):Void
    {
        if (!projectile.Rolls())
            return;
        var gravity = projectile.GetGravity();
        if (gravity > 0 && projectile.IsOnGround)
        {
            var level = projectile.Level;
            var x = projectile.Position.x;
            var z = projectile.Position.z;
            var groundY = projectile.GetGroundY();
            var velocityAddition = Vector2.zero;
            var checkDistance = 1;
            for (i in 0...8)
            {
                var direction = tools.VectorExt.RotateClockwise(Vector2.right, i * 45);
                var opposite = -direction;
                var checkPoint = direction * checkDistance;
                var relativeGroundY = level.GetGroundY(x + checkPoint.x, z + checkPoint.y) - groundY;

                var slope = Mathf.Atan2(relativeGroundY, checkDistance);

                var horiSpeed = gravity * Mathf.Sin(slope) * Mathf.Cos(slope);
                velocityAddition += opposite * horiSpeed;
            }
            var vel = projectile.Velocity;
            vel.x += velocityAddition.x;
            vel.z += velocityAddition.y;
            projectile.Velocity = vel;
        }
    }

    //region 创建者保护
    function SetStartHitSpawnerProtectTimeout(entity:Entity, value:Int):Void entity.SetBehaviourField(FIELD_HIT_SPAWNER_PROTECT_TIMEOUT, value);
    function GetStartHitSpawnerProtectTimeout(entity:Entity):Int return entity.GetBehaviourField(FIELD_HIT_SPAWNER_PROTECT_TIMEOUT);
    //endregion
    public static var FIELD_HIT_SPAWNER_PROTECT_TIMEOUT:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("HitSpawnerProtectTimeout");
}
