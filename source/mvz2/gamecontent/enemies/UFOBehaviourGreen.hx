// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter5/UndeadFlyingObjectGreen.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.contraptions.StolenByUFOBuff;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.contraptions.VanillaContraptionExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.grids.VanillaGridLayers;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.blueprints.LogicBlueprintID;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EntityID;
import pvzengine.NamespaceID;
import pvzengine.PropertyRegions;
import pvzengine.buffs.BuffExt;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.EngineEntityExt;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import pvzengine.grids.LawnGrid;
import pvzengine.level.LevelEngine;

// PORT-NOTE: C# 扩展方法在 Haxe 侧以静态方法 + `using` 提供（PORTING.md §扩展方法）。
using mvz2.vanilla.contraptions.VanillaContraptionProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using pvzengine.buffs.BuffTargetExt;
using pvzengine.entities.EngineEntityExt;

class UFOBehaviourGreen extends UFOBehaviour
{
    public function new()
    {
        super(UndeadFlyingObject.VARIANT_GREEN);
    }
    public override function CanSpawn(level:LevelEngine, faction:Int):Bool
    {
        return level.GetEntityCount(e -> CanStartSteal(faction, e)) > 3;
    }
    public override function GetPossibleSpawnGrids(level:LevelEngine, faction:Int, results:Map<LawnGrid, Bool>):Void
    {
        var filled = false;
        for (ent in level.FindEntities(e -> CanStartSteal(faction, e)))
        {
            var grid = ent.GetGrid();
            if (grid != null)
            {
                results.set(grid, true);
                filled = true;
            }
        }
        if (!filled)
        {
            var maxColumn = level.GetMaxColumnCount();
            var maxLane = level.GetMaxLaneCount();
            for (x in 0...maxColumn)
            {
                for (y in 0...maxLane)
                {
                    var grid = level.GetGrid(x, y);
                    if (grid != null)
                    {
                        results.set(grid, true);
                    }
                }
            }
        }
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        var stolen = GetStolenEntityID(entity);
        if (NamespaceID.IsValid(stolen))
        {
            var blueprintID = LogicBlueprintID.FromEntity(stolen);
            var spawnParams = entity.GetSpawnParams();
            spawnParams.SetProperty(VanillaPickupProps.CONTENT_ID, blueprintID);
            var pickup = entity.Spawn(VanillaPickupID.blueprintPickup, entity.GetCenter(), spawnParams);
        }
    }
    public override function UpdateActionState(entity:Entity, state:Int):Void
    {
        super.UpdateActionState(entity, state);
        // PORT-NOTE: Haxe 不继承静态成员，C# 中直接引用的基类静态成员需以 UFOBehaviour. 限定。
        switch (state)
        {
            case UFOBehaviour.STATE_STAY:
                UpdateStateStay(entity);
            case UFOBehaviour.STATE_ACT:
                UpdateStateAct(entity);
            case UFOBehaviour.STATE_LEAVE:
                UpdateStateLeave(entity);
        }
    }
    function UpdateStateStay(enemy:Entity):Void
    {
        EnterUpdate(enemy);

        var timer = UFOBehaviour.GetOrInitStateTimer(enemy, STAY_TIME);
        if (timer.RunToExpiredAndNotNull())
        {
            var grid = enemy.GetGrid();
            if (grid != null)
            {
                var layers = grid.GetLayers();
                var orderedLayers = VanillaGridLayers.ufoLayers;
                for (layer in orderedLayers)
                {
                    var entity = grid.GetLayerEntity(layer);
                    // PORT-NOTE: C# 重载 CanStartSteal(Entity ufo, Entity entity) 在 Haxe 中重命名为 CanStartStealEntity。
                    if (entity == null || !CanStartStealEntity(enemy, entity))
                        continue;
                    enemy.Target = entity;
                    var buff = entity.AddBuff(StolenByUFOBuff);
                    buff.SetProperty(StolenByUFOBuff.PROP_UFO, new EntityID(enemy));
                    break;
                }
            }
            if (!enemy.Target.ExistsAndAlive())
            {
                UFOBehaviour.SetUFOState(enemy, UFOBehaviour.STATE_LEAVE);
            }
            else
            {
                UFOBehaviour.SetUFOState(enemy, UFOBehaviour.STATE_ACT);
            }
        }
    }
    function UpdateStateAct(enemy:Entity):Void
    {
        EnterUpdate(enemy);

        if (!enemy.Target.ExistsAndAlive() || !enemy.Target.HasBuff(StolenByUFOBuff) || NamespaceID.IsValid(GetStolenEntityID(enemy)))
        {
            UFOBehaviour.SetUFOState(enemy, UFOBehaviour.STATE_LEAVE);
        }
    }
    function UpdateStateLeave(entity:Entity):Void
    {
        LeaveUpdate(entity);
    }
    public static function CanStartStealEntity(ufo:Entity, entity:Entity):Bool
    {
        return CanStartSteal(ufo.GetFaction(), entity);
    }
    public static function CanStartSteal(ufoFaction:Int, entity:Entity):Bool
    {
        if (!entity.ExistsAndAlive())
            return false;
        if (entity.Type != EntityTypes.PLANT && entity.Type != EntityTypes.OBSTACLE)
            return false;
        if (entity.HasBuff(StolenByUFOBuff))
            return false;
        if (!EngineEntityExt.IsHostile(ufoFaction, entity.GetFaction()))
            return false;
        if (entity.IsNoAbduction())
            return false;
        return true;
    }
    public static function GetStolenEntityID(entity:Entity):Null<NamespaceID> return entity.GetBehaviourField(PROP_STOLEN_ENTITY_ID);
    public static function SetStolenEntityID(entity:Entity, value:NamespaceID):Void entity.SetBehaviourField(PROP_STOLEN_ENTITY_ID, value);

    public static inline var STAY_TIME:Int = 240;
    public static inline var ACT_TIME:Int = 150;
    public static inline var STEAL_CONTRAPTION_TIME:Int = 30;

    public static inline var PROP_REGION:String = VanillaEnemyNames.ufo;
    @:propertyRegistry(PROP_REGION)
    public static var PROP_STOLEN_ENTITY_ID:VanillaEntityPropertyMeta<NamespaceID> = new VanillaEntityPropertyMeta<NamespaceID>("stolen_entity_id");
}
