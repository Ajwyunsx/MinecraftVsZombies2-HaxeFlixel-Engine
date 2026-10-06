// Ported from: Assets/Scripts/Vanilla/GameContent/Obstacles/MonsterSpawner.cs
package mvz2.gamecontent.obstacles;

import mvz2.gamecontent.buffs.level.DelayedSpawnerTriggerBuff;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.obstacles.VanillaObstacleID.VanillaObstacleNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.grids.LogicGridExt;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.grids.LawnGrid;
import tools.Ref;
import unity.Mathf;
import unity.Vector2Int;

@:autoEntityBehaviourDefinition(VanillaObstacleNames.monsterSpawner)
class MonsterSpawner extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LevelCallbacks.POST_HUGE_WAVE_EVENT, PostHugeWaveEventCallback);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var mainCollider = entity.GetCollider(EntityCollisionHelper.NAME_MAIN);
        if (mainCollider != null)
        {
            mainCollider.SetEnabled(false);
        }
        SetEntityToSpawn(entity, VanillaEnemyID.zombie);
    }
    public override function PostDeath(entity:Entity, damageInfo:DeathInfo):Void
    {
        super.PostDeath(entity, damageInfo);
        entity.Remove();
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);

        var level = entity.Level;
        var spinSpeed:Float = 1;
        if (level.HasBuff(DelayedSpawnerTriggerBuff))
        {
            spinSpeed = 5;
        }
        else
        {
            spinSpeed = Mathf.Lerp(1, 5, (level.CurrentWave / level.GetWavesPerFlag()) % 1);
        }
        entity.SetAnimationFloat("SpinSpeed", spinSpeed);
    }
    function PostHugeWaveEventCallback(param:LevelCallbackParams, result:CallbackResult):Void
    {
        var level = param.level;
        level.AddBuff(DelayedSpawnerTriggerBuff);
    }
    public static function Trigger(spawner:Entity):Void
    {
        var spawned = new Ref<Entity>(null);
        if (TrySpawnEntity(spawner, spawned))
        {
            spawner.Spawn(VanillaEffectID.emberParticles, spawned.value.GetCenter());
        }
    }
    // PORT-NOTE: Haxe 无 out 参数；C# 重载 TrySpawnEntity(Entity, out Entity?) 保留原名。
    public static function TrySpawnEntity(spawner:Entity, spawned:Ref<Entity>):Bool
    {
        var id = GetEntityToSpawn(spawner);
        if (id == null)
        {
            spawned.value = null;
            return false;
        }
        return TrySpawnEntityWithId(spawner, id, spawned);
    }
    // PORT-NOTE: Haxe has no method overloading; renamed overload to TrySpawnEntityWithId.
    public static function TrySpawnEntityWithId(spawner:Entity, id:NamespaceID, spawned:Ref<Entity>):Bool
    {
        var lane = spawner.GetLane();
        var column = spawner.GetColumn();
        var level = spawner.Level;
        for (i in 0...spawnGrids.length)
        {
            var offset = spawnGrids[i];
            var l = lane + offset.y;
            var c = column + offset.x;
            var grid = level.GetGrid(c, l);
            var s = new Ref<Entity>(null);
            if (grid != null && TrySpawnEntityAt(spawner, id, grid, s))
            {
                spawned.value = s.value;
                return true;
            }
        }
        spawned.value = null;
        return false;
    }
    public static function TrySpawnEntityAt(spawner:Entity, id:NamespaceID, grid:LawnGrid, spawned:Ref<Entity>):Bool
    {
        spawned.value = null;
        if (!LogicGridExt.CanSpawnEntity(grid, id))
            return false;
        var pos = grid.GetEntityPosition();
        spawned.value = VanillaEntityExt.SpawnWithParams(spawner, id, pos);
        return true;
    }
    public static function GetEntityToSpawn(entity:Entity):Null<NamespaceID>
    {
        return entity.GetProperty(PROP_ENTITY_TO_SPAWN);
    }
    public static function SetEntityToSpawn(entity:Entity, id:NamespaceID):Void
    {
        entity.SetProperty(PROP_ENTITY_TO_SPAWN, id);
        entity.SetModelProperty("EntityToSpawn", id);
    }
    public static var PROP_ENTITY_TO_SPAWN:VanillaEntityPropertyMeta<NamespaceID> = new VanillaEntityPropertyMeta<NamespaceID>("EntityToSpawn");
    public static var spawnGrids:Array<Vector2Int> = [
        new Vector2Int(0, 0),
        new Vector2Int(0, 1),
        new Vector2Int(0, -1),
        new Vector2Int(1, 0),
        new Vector2Int(-1, 0),
        new Vector2Int(1, 1),
        new Vector2Int(1, -1),
        new Vector2Int(-1, -1),
        new Vector2Int(-1, 1),
    ];
}
