// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter2/FlyBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.enemies.VanillaEnemyExt;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.EntityTypes;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import unity.Mathf;

@:autoBuffDefinition(VanillaBuffNames.Enemy_fly)
class FlyBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(EngineEntityProps.GRAVITY, NumberOperator.Multiply, PROP_GRAVITY_MULTIPLIER));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_GRAVITY_MULTIPLIER, 0.0);
        buff.SetProperty(PROP_TARGET_HEIGHT, 0.0);
        buff.SetProperty(PROP_FLY_SPEED, 0.1);
        buff.SetProperty(PROP_FLY_SPEED_FACTOR, 0.2);
        buff.SetProperty(PROP_MAX_FLY_SPEED, 10.0);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        if (VanillaEntityProps.IsAIFrozen(entity) && !buff.GetProperty(PROP_WORKS_ON_FROZEN))
        {
            buff.SetProperty(PROP_GRAVITY_MULTIPLIER, 1.0);
            return;
        }
        buff.SetProperty(PROP_GRAVITY_MULTIPLIER, 0.0);
        var targetHeight = entity.Level.KillerEnemy == entity ? 0 : buff.GetProperty(PROP_TARGET_HEIGHT);
        var flySpeed = buff.GetProperty(PROP_FLY_SPEED);
        var flySpeedFactor = buff.GetProperty(PROP_FLY_SPEED_FACTOR);
        var maxFlySpeed = buff.GetProperty(PROP_MAX_FLY_SPEED);
        var currentHeight = entity.GetRelativeY();
        var heightToMove = targetHeight - currentHeight;
        var targetSpeed = Mathf.Clamp(heightToMove * flySpeed, -maxFlySpeed, maxFlySpeed);
        var velocity = entity.Velocity;
        velocity.y = velocity.y * (1 - flySpeedFactor) + targetSpeed * flySpeedFactor;
        entity.Velocity = velocity;

        if (entity.Type == EntityTypes.ENEMY && !VanillaEnemyProps.NoAlignToLane(entity))
        {
            VanillaEnemyExt.CheckAlignToLane(entity);
        }
    }
    public static var PROP_GRAVITY_MULTIPLIER:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("GravityMultiplier");
    public static var PROP_TARGET_HEIGHT:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("TargetHeight");
    public static var PROP_MAX_FLY_SPEED:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("MaxFlySpeed");
    public static var PROP_FLY_SPEED:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("FlySpeed");
    public static var PROP_FLY_SPEED_FACTOR:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("FlySpeedFactor");
    public static var PROP_WORKS_ON_FROZEN:VanillaBuffPropertyMeta<Bool> = new VanillaBuffPropertyMeta<Bool>("works_on_frozen");
}
