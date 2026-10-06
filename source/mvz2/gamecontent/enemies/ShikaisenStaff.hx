// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter4/ShikaisenStaff.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.ShikaisenReviveBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.EntityID;
import pvzengine.buffs.BuffExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.damages.DamageInput;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.shikaisenStaff)
class ShikaisenStaff extends EnemyBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostEnemyDeathCallback, EntityTypes.ENEMY);
        AddModifier(new Vector3Modifier(EngineEntityProps.VELOCITY_DAMPEN, NumberOperator.Set, PROP_VELOCITY_DAMPEN));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetTargetPosition(entity, entity.Position);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        var onGround = entity.Position.y <= entity.GetRealGroundLimitY() + 0.01;
        if (onGround)
        {
            if (!IsStickOnGround(entity))
            {
                SetStickOnGround(entity, true);
                SetTargetPosition(entity, entity.Position);
            }
            var targetPosition = GetTargetPosition(entity);
            targetPosition.y = entity.Level.GetGroundY(targetPosition.x, targetPosition.z);
            entity.Position = targetPosition;
            entity.Velocity = Vector3.zero;
            SetVelocityDampen(entity, Vector3.one);
        }
        else
        {
            SetStickOnGround(entity, false);
            SetVelocityDampen(entity, Vector3.zero);
        }
        entity.StopChangingLane();

        entity.SetModelProperty("InAir", !onGround);
        entity.SetAnimationFloat("Range", entity.GetRange());
    }
    public override function PreTakeDamage(input:DamageInput, result:CallbackResult):Void
    {
        super.PreTakeDamage(input, result);
        var entity = input.Entity;
        if (input.HasEffect(VanillaDamageEffects.FIRE))
        {
            input.SetAmount(entity.GetMaxHealth() * 10);
        }
    }
    function PostEnemyDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var info = param.deathInfo;
        if (entity.WillRemoveOnDeath(info) || info.HasEffect(VanillaDamageEffects.DROWN) || info.HasEffect(VanillaDamageEffects.FALL_OFF))
            return;
        var staff = entity.Level.FindFirstEntity(e -> e.IsEntityOf(VanillaEnemyID.shikaisenStaff) && (e.Position - entity.Position).magnitude <= e.GetRange() && e.ExistsAndAlive());
        if (staff == null)
            return;
        var buff = entity.NewBuff(ShikaisenReviveBuff);
        ShikaisenReviveBuff.SetSource(buff, new EntityID(staff));
        entity.AddBuff(buff);
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        entity.Remove();
    }
    public static function IsStickOnGround(enemy:Entity):Bool return enemy.GetBehaviourField(PROP_STICK_ON_GROUND);
    public static function SetStickOnGround(enemy:Entity, value:Bool):Void enemy.SetBehaviourField(PROP_STICK_ON_GROUND, value);
    public static function GetTargetPosition(enemy:Entity):Vector3 return enemy.GetBehaviourField(PROP_TARGET_POSITION);
    public static function SetTargetPosition(enemy:Entity, value:Vector3):Void enemy.SetBehaviourField(PROP_TARGET_POSITION, value);
    public static function GetVelocityDampen(enemy:Entity):Vector3 return enemy.GetBehaviourField(PROP_VELOCITY_DAMPEN);
    public static function SetVelocityDampen(enemy:Entity, value:Vector3):Void enemy.SetBehaviourField(PROP_VELOCITY_DAMPEN, value);
    public static var PROP_STICK_ON_GROUND:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("stick_on_ground");
    public static var PROP_TARGET_POSITION:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("TargetPosition");
    public static var PROP_VELOCITY_DAMPEN:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("velocity_dampen");
    var detectBuffer:Array<Entity> = [];
}
