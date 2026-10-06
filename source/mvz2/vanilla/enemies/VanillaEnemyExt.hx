// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/VanillaEnemyExt.cs
package mvz2.vanilla.enemies;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import mvz2logic.level.LevelPositions;
import pvzengine.EngineEntityProps;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.entities.Entity;
import unity.Mathf;
import unity.Vector3;

// PORT-NOTE: C# 的扩展方法在本移植中为静态方法；调用点沿用扩展方法风格，故以 `using` 引入对应模块。
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.enemies.VanillaEnemyProps;

class VanillaEnemyExt
{
    public static function Neutralize(enemy:Entity):Void
    {
        DropRewards(enemy);
        if (enemy.IsNeutralized())
            return;

        var result = new CallbackResult(true);
        enemy.Level.Triggers.RunCallbackWithResult(VanillaLevelCallbacks.PRE_ENEMY_NEUTRALIZE, new EntityCallbackParams(enemy), result);
        if (!result.GetValue())
            return;
        enemy.SetNeutralized(true);
        enemy.Level.Triggers.RunCallback(VanillaLevelCallbacks.POST_ENEMY_NEUTRALIZE, new EntityCallbackParams(enemy));
    }
    public static function DropRewards(enemy:Entity):Void
    {
        enemy.Level.Triggers.RunCallback(VanillaLevelCallbacks.ENEMY_DROP_REWARDS, new EntityCallbackParams(enemy));
    }
    public static function UpdateWalkVelocity(enemy:Entity):Void
    {
        var velocity = enemy.Velocity;
        var speed = enemy.GetSpeed() * WALK_SPEED_FACTOR;
        if (Mathf.Abs(velocity.x) < speed)
        {
            var min = Mathf.Min(speed, -speed);
            var max = Mathf.Max(speed, -speed);
            var direciton = enemy.GetFacingX();
            velocity.x += speed * direciton;
            velocity.x = Mathf.Clamp(velocity.x, min, max);
        }
        enemy.Velocity = velocity;
    }
    public static inline var WALK_SPEED_FACTOR:Float = 0.4; // 怪物的移速乘算倍率，默认0.4倍
    public static function FaintRemove(enemy:Entity):Void
    {
        var callbackResult = new CallbackResult(true);
        enemy.Level.Triggers.RunCallbackWithResultFiltered(VanillaLevelCallbacks.PRE_ENEMY_FAINT, new EntityCallbackParams(enemy), callbackResult, enemy.GetDefinitionID());
        if (callbackResult.GetValue())
        {
            var param = enemy.GetSpawnParams();
            param.SetProperty(EngineEntityProps.SIZE, enemy.GetSize());
            enemy.Level.Spawn(VanillaEffectID.smoke, enemy.Position, enemy, param);
            enemy.Remove();
            enemy.Level.Triggers.RunCallbackFiltered(VanillaLevelCallbacks.POST_ENEMY_FAINT, new EntityCallbackParams(enemy), enemy.GetDefinitionID());
        }
    }

    public static function CheckAlignToLane(entity:Entity):Void
    {
        if (entity.IsChangingLane())
            return;
        var level = entity.Level;

        var minLane = 0;
        var maxLane = level.GetMaxLaneCount() - 1;

        // PORT-NOTE: C# Mathf.Clamp(int,int,int) → Haxe shim 的 Mathf.ClampInt。
        var lane = Mathf.ClampInt(entity.GetLane(), minLane, maxLane);
        var targetZ = level.GetEntityLaneZ(lane);
        var targetZDistance = entity.Position.z - targetZ;

        if (Mathf.Abs(targetZDistance) < CHANGE_LANE_THRESOLD)
            return;

        var targetLane:Int;
        var adjacentLane = lane - (targetZDistance < 0 ? -1 : 1);
        if (adjacentLane >= minLane && adjacentLane <= maxLane)
        {
            var adjacentZ = level.GetEntityLaneZ(adjacentLane);
            var adjacentZDistance = entity.Position.z - adjacentZ;
            if (Mathf.Abs(targetZDistance) < Mathf.Abs(adjacentZDistance))
            {
                targetLane = lane;
            }
            else
            {
                targetLane = adjacentLane;
            }
        }
        else
        {
            targetLane = lane;
        }
        entity.StartChangingLane(targetLane);
    }

    //region 地图限制
    public static function IsEnemyOutsideLeft(entity:Entity, margin:Float = 0):Bool
    {
        var bounds = entity.GetBounds();
        return bounds.max.x < LevelPositions.ENEMY_LEFT_BORDER + margin;
    }
    public static function IsEnemyOutsideRight(entity:Entity, margin:Float = 0):Bool
    {
        var bounds = entity.GetBounds();
        return bounds.min.x > LevelPositions.ENEMY_RIGHT_BORDER - margin;
    }
    public static function LimitEnemyFromRight(entity:Entity, margin:Float = 0):Void
    {
        var bounds = entity.GetBounds();
        var target = LevelPositions.ENEMY_RIGHT_BORDER - margin;
        var different = bounds.min.x - target;

        var pos = entity.Position;
        pos.x -= different;
        entity.Position = pos;
    }
    //endregion

    public static inline var CHANGE_LANE_THRESOLD:Float = 1;
}
