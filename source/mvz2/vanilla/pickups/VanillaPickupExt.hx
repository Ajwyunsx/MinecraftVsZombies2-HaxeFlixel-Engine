// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/VanillaPickupExt.cs
package mvz2.vanilla.pickups;

import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.level.LevelPositions;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.definitions.EntityDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.SpawnParams;
import pvzengine.level.LevelEngine;
import unity.Vector3;

// PORT-NOTE: C# 的扩展方法在本移植中为静态方法；调用点沿用扩展方法风格，故以 `using` 引入对应模块。
using mvz2.vanilla.pickups.VanillaPickupProps;

class VanillaPickupExt
{
    // PORT-NOTE: EntityDefinition.GetBehaviour<T>/GetBehaviours<T> 的 T 受限于 EntityBehaviourDefinition 类，
    //   而 C# 此处传入的是行为接口 ICollectBehaviour（Haxe 的 interface 不能继承 class）。
    //   故沿用 VanillaArmorExt.TryDestroyBySpikes 的做法，以 GetBehaviourAt()/GetBehaviourCount() + Std.isOfType 运行期筛选。
    private static function GetBehaviourOfType<T>(definition:EntityDefinition, type:Class<T>):Null<T>
    {
        for (i in 0...definition.GetBehaviourCount())
        {
            var behaviour = definition.GetBehaviourAt(i);
            if (Std.isOfType(behaviour, type))
            {
                return cast behaviour;
            }
        }
        return null;
    }
    private static function GetBehavioursOfType<T>(definition:EntityDefinition, type:Class<T>):Array<T>
    {
        var result:Array<T> = [];
        for (i in 0...definition.GetBehaviourCount())
        {
            var behaviour = definition.GetBehaviourAt(i);
            if (Std.isOfType(behaviour, type))
            {
                result.push(cast behaviour);
            }
        }
        return result;
    }
    // C#: extension method Collect(this Entity pickup)
    public static function Collect(pickup:Entity):Void
    {
        if (!CanCollect(pickup))
            return;
        var collectibles = GetBehavioursOfType(pickup.Definition, ICollectBehaviour);
        for (collectible in collectibles)
        {
            if (collectible.CanCollect(pickup))
            {
                pickup.State = VanillaPickupStates.COLLECTED;
                if (pickup.RemoveOnCollect())
                {
                    pickup.Remove();
                }
                collectible.PostCollect(pickup);
            }
        }
        pickup.Level.Triggers.RunCallbackFiltered(VanillaLevelCallbacks.POST_PICKUP_COLLECT, new EntityCallbackParams(pickup), pickup.GetDefinitionID());
    }
    // C#: extension method CanCollect(this Entity entity)
    public static function CanCollect(entity:Entity):Bool
    {
        var collectibles = GetBehavioursOfType(entity.Definition, ICollectBehaviour);
        var canCollect = false;
        for (collectible in collectibles)
        {
            if (collectible.CanCollect(entity))
            {
                canCollect = true;
                break;
            }
        }
        var result = new CallbackResult(canCollect);
        entity.Level.Triggers.RunCallbackWithResult(VanillaLevelCallbacks.CAN_PICKUP_COLLECT, new EntityCallbackParams(entity), result);
        return result.GetValue();
    }
    // C#: extension method CanAutoCollect(this Entity entity)
    public static function CanAutoCollect(entity:Entity):Bool
    {
        var collectible = GetBehaviourOfType(entity.Definition, ICollectBehaviour);
        if (collectible == null)
            return false;
        if (!collectible.CanAutoCollect(entity))
            return false;
        return true;
    }
    // C#: extension method IsCollected(this Entity entity)
    public static function IsCollected(entity:Entity):Bool
    {
        return entity.State == VanillaPickupStates.COLLECTED;
    }
    // C#: extension method Produce(this Entity entity, NamespaceID pickupID, SpawnParams? param = null)
    // C#: extension method Produce(this Entity entity, EntityDefinition pickupDef, SpawnParams? param = null)
    // PORT-NOTE: Haxe 不支持重载，两个重载合并为一个方法，第二个参数按运行期类型分派。
    public static function Produce(entity:Entity, pickupIDOrDef:Dynamic, ?param:Null<SpawnParams>):Null<Entity>
    {
        var def:EntityDefinition;
        if (Std.isOfType(pickupIDOrDef, EntityDefinition))
        {
            def = cast pickupIDOrDef;
        }
        else
        {
            def = entity.Level.Content.GetEntityDefinition(cast pickupIDOrDef);
            if (def == null)
                return null;
        }
        return ProduceFromLevel(entity.Level, def, entity.Position, entity, param);
    }
    // C#: extension method Produce(this LevelEngine level, NamespaceID pickupID, Vector3 position, Entity? spawner, SpawnParams? param = null)
    // C#: extension method Produce(this LevelEngine level, EntityDefinition pickupDef, Vector3 position, Entity? spawner, SpawnParams? param = null)
    // PORT-NOTE: Haxe 不支持重载，两个重载合并为一个方法，第二个参数按运行期类型分派；
    // 为避免与接收者为 Entity 的 Produce 重名（Haxe 不允许同类内同名方法），本方法命名为 ProduceOnLevel。
    public static function ProduceOnLevel(level:LevelEngine, pickupIDOrDef:Dynamic, position:Vector3, spawner:Null<Entity>, ?param:Null<SpawnParams>):Null<Entity>
    {
        var def:EntityDefinition;
        if (Std.isOfType(pickupIDOrDef, EntityDefinition))
        {
            def = cast pickupIDOrDef;
        }
        else
        {
            def = level.Content.GetEntityDefinition(cast pickupIDOrDef);
            if (def == null)
                return null;
        }
        return ProduceFromLevel(level, def, position, spawner, param);
    }
    private static function ProduceFromLevel(level:LevelEngine, pickupDef:EntityDefinition, position:Vector3, spawner:Null<Entity>, param:Null<SpawnParams>):Null<Entity>
    {
        var xSpeed:Float;
        var maxSpeed:Float = 1.6;
        // C#: level.Spawn(pickupDef, position, spawner, param)?.Let(e => { ... })
        var pickup = level.Spawn(pickupDef, position, spawner, param);
        if (pickup != null)
        {
            var rng = pickup.RNG;
            if (position.x <= LevelPositions.GetBorderX(false) + 150)
            {
                xSpeed = rng.Next(0, maxSpeed);
            }
            else if (position.x >= LevelPositions.GetBorderX(true) - 150)
            {
                xSpeed = rng.Next(-maxSpeed, 0);
            }
            else
            {
                xSpeed = rng.Next(-maxSpeed, maxSpeed);
            }
            var dropVelocity = new Vector3(xSpeed, 7, 0);
            pickup.Velocity = dropVelocity;
        }

        return pickup;
    }
}
