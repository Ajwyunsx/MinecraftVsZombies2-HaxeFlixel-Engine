// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter5/UndeadFlyingObject.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.FlyBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.Explosion;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.enemies.VanillaEnemyStates;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.IDeathEffectsBehaviour;
import mvz2logic.entities.LogicEnemyStates;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.BuffExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.grids.LawnGrid;
import pvzengine.level.LevelEngine;
import tools.FrameTimer;
import unity.Mathf;
import unity.Vector3;
using mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEnemyProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.entities.LogicEntityProps;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.undeadFlyingObject)
class UndeadFlyingObject extends AIEntityBehaviour implements IDeathEffectsBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var column = entity.GetColumn();
        var lane = entity.GetLane();
        SetTargetGridX(entity, column);
        SetTargetGridY(entity, lane);

        var buff = entity.AddBuff(FlyBuff);
        buff.SetProperty(FlyBuff.PROP_TARGET_HEIGHT, FLY_HEIGHT);
        buff.SetProperty(FlyBuff.PROP_FLY_SPEED_FACTOR, FLY_SPEED_FACTOR_ENTER);
        buff.SetProperty(FlyBuff.PROP_FLY_SPEED, FLY_SPEED_ENTER);
        buff.SetProperty(FlyBuff.PROP_MAX_FLY_SPEED, MAX_FLY_SPEED);

        if (!entity.IsPreviewEnemy())
        {
            entity.PlaySound(VanillaSoundID.ufo, 1, 0.5);
        }
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        var variant = entity.GetVariant();
        var behaviour = behaviours.get(variant);
        if (behaviour != null)
        {
            behaviour.UpdateActionState(entity, entity.State);
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        if (entity.IsOnGround)
        {
            var effects = new DamageEffectList([VanillaDamageEffects.SELF_DAMAGE]);
            entity.Die(effects, entity);
        }
        entity.SetAnimationBool("SpotlightOn", entity.State == STATE_ACT);
        var variant = entity.GetVariant();
        var behaviour = behaviours.get(variant);
        if (behaviour != null)
        {
            behaviour.UpdateLogic(entity);
        }
    }

    public function DeathEffects(entity:Entity, info:DeathInfo):Void
    {
        var damageMutliplier = entity.Level.GetReverseSatelliteDamageMultiplier();
        var radius = EXPLOSION_RADIUS;
        var damage = entity.GetDamage() * damageMutliplier;
        if (damage >= 0)
        {
            entity.Explode(entity.GetCenter(), radius, entity.GetFaction(), damage, new DamageEffectList([VanillaDamageEffects.EXPLOSION]));
        }
        // PORT-NOTE: C# 重载 Spawn(Entity, Vector3 position, Vector3 size) 在 Haxe 中改名为 SpawnWithSize。
        Explosion.SpawnWithSize(entity, entity.GetCenter(), entity.GetScaledSize());
        entity.PlaySound(VanillaSoundID.explosion);
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        var variant = entity.GetVariant();
        var behaviour = behaviours.get(variant);
        if (behaviour != null)
        {
            behaviour.PostDeath(entity, info);
        }
        entity.Remove();
    }
    public static function EnterUpdate(enemy:Entity):Void
    {
        for (buff in enemy.GetBuffs(FlyBuff))
        {
            buff.SetProperty(FlyBuff.PROP_TARGET_HEIGHT, FLY_HEIGHT);
            buff.SetProperty(FlyBuff.PROP_FLY_SPEED_FACTOR, FLY_SPEED_FACTOR_ENTER);
            buff.SetProperty(FlyBuff.PROP_FLY_SPEED, FLY_SPEED_ENTER);
        }

        var targetPosition = GetTargetPosition(enemy);
        var targetVelocity = targetPosition - enemy.Position;
        targetVelocity = targetVelocity.normalized * Mathf.Min(MAX_MOVE_SPEED, targetVelocity.magnitude);
        var velocity = enemy.Velocity;
        velocity.x = velocity.x * (1 - MOVE_FACTOR) + targetVelocity.x * MOVE_FACTOR;
        velocity.z = velocity.z * (1 - MOVE_FACTOR) + targetVelocity.z * MOVE_FACTOR;
        enemy.Velocity = velocity;
    }
    public static function LeaveUpdate(enemy:Entity):Void
    {
        for (buff in enemy.GetBuffs(FlyBuff))
        {
            buff.SetProperty(FlyBuff.PROP_TARGET_HEIGHT, LEAVE_HEIGHT);
            buff.SetProperty(FlyBuff.PROP_FLY_SPEED_FACTOR, FLY_SPEED_FACTOR_LEAVE);
            buff.SetProperty(FlyBuff.PROP_FLY_SPEED, FLY_SPEED_LEAVE);
        }

        if (enemy.GetRelativeY() >= LEAVE_HEIGHT)
        {
            enemy.Remove();
        }
    }
    static function GetTargetPosition(enemy:Entity):Vector3
    {
        var level = enemy.Level;
        var column = GetTargetGridX(enemy);
        var lane = GetTargetGridY(enemy);
        var x = level.GetEntityColumnX(column);
        var z = level.GetEntityLaneZ(lane);
        var y = level.GetGroundY(x, z) + FLY_HEIGHT;
        return new Vector3(x, y, z);
    }

    public static function SpawnAtGrid(grid:LawnGrid, variant:Int):Null<Entity>
    {
        var column = grid.Column;
        var lane = grid.Lane;
        var pos = grid.GetEntityPosition();
        pos.y += UndeadFlyingObject.START_HEIGHT;

        var level = grid.Level;
        // C#: level.Spawn(...)?.Let(e => { ... })
        var e = level.Spawn(VanillaEnemyID.ufo, pos, null);
        if (e != null)
        {
            e.SetVariant(variant);
            UndeadFlyingObject.SetTargetGridX(e, column);
            UndeadFlyingObject.SetTargetGridY(e, lane);
        }
        return e;
    }

    //region 属性
    public static function GetStateTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_STATE_TIMER);
    public static function SetStateTimer(entity:Entity, value:FrameTimer):Void entity.SetBehaviourField(PROP_STATE_TIMER, value);
    public static function GetUFOState(entity:Entity):Int return entity.GetBehaviourField(PROP_UFO_STATE);
    public static function SetUFOState(entity:Entity, value:Int):Void entity.SetBehaviourField(PROP_UFO_STATE, value);
    public static function GetTargetGridX(entity:Entity):Int return entity.GetBehaviourField(PROP_TARGET_GRID_X);
    public static function SetTargetGridX(entity:Entity, value:Int):Void entity.SetBehaviourField(PROP_TARGET_GRID_X, value);
    public static function GetTargetGridY(entity:Entity):Int return entity.GetBehaviourField(PROP_TARGET_GRID_Y);
    public static function SetTargetGridY(entity:Entity, value:Int):Void entity.SetBehaviourField(PROP_TARGET_GRID_Y, value);
    //endregion

    //region 生成逻辑
    public static function IsUFO(entity:Entity):Bool
    {
        return entity.IsEntityOf(VanillaEnemyID.ufo);
    }
    public static function FillUFOVariantRandomPool(level:LevelEngine, faction:Int, results:Array<Int>):Void
    {
        for (variant in behaviours.keys())
        {
            if (behaviours.get(variant).CanSpawn(level, faction))
            {
                results.push(variant);
            }
        }
    }
    public static function FillUFOPossibleSpawnGrids(level:LevelEngine, variant:Int, faction:Int, results:Map<LawnGrid, Bool>):Void
    {
        var behaviour = behaviours.get(variant);
        if (behaviour != null)
        {
            behaviour.GetPossibleSpawnGrids(level, faction, results);
        }
    }
    public static function FilterConflictSpawnGrids(level:LevelEngine, possibleGrids:Array<LawnGrid>):Array<LawnGrid>
    {
        var conflictGrids:Map<LawnGrid, Bool> = new Map();
        conflictGrids.clear();
        for (other in level.FindEntities(e -> IsUFO(e)))
        {
            var x = UndeadFlyingObject.GetTargetGridX(other);
            var y = UndeadFlyingObject.GetTargetGridY(other);
            var grid = level.GetGrid(x, y);
            if (grid != null)
            {
                conflictGrids.set(grid, true);
            }
        }
        var notConflictGrids = Lambda.filter(possibleGrids, g -> !conflictGrids.exists(g));
        if (notConflictGrids.length > 0)
        {
            return notConflictGrids;
        }
        else
        {
            return possibleGrids;
        }
    }
    //endregion

    public static inline var VARIANT_RED:Int = 0;
    public static inline var VARIANT_GREEN:Int = 1;
    public static inline var VARIANT_BLUE:Int = 2;
    public static inline var VARIANT_RAINBOW:Int = 3;

    public static inline var EXPLOSION_RADIUS:Float = 24;
    public static inline var FLY_HEIGHT:Float = 80;
    public static inline var FLY_SPEED_ENTER:Float = 0.3;
    public static inline var FLY_SPEED_LEAVE:Float = 0.1;
    public static inline var FLY_SPEED_FACTOR_ENTER:Float = 0.5;
    public static inline var FLY_SPEED_FACTOR_LEAVE:Float = 0.1;
    public static inline var MAX_FLY_SPEED:Float = 100;
    public static inline var START_HEIGHT:Float = 600;
    public static inline var LEAVE_HEIGHT:Float = 600;
    public static inline var MAX_MOVE_SPEED:Float = 15;
    public static inline var MOVE_FACTOR:Float = 0.5;

    public static inline var STATE_IDLE:Int = LogicEnemyStates.IDLE;
    public static inline var STATE_DEATH:Int = LogicEnemyStates.DEATH;
    public static inline var STATE_LEAVE:Int = LogicEnemyStates.LEAVE;
    public static inline var STATE_STAY:Int = VanillaEnemyStates.UFO_STAY;
    public static inline var STATE_ACT:Int = VanillaEnemyStates.UFO_ACT;


    public static var PROP_TARGET_GRID_X:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("target_grid_x");
    public static var PROP_TARGET_GRID_Y:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("target_grid_y");
    public static var PROP_UFO_STATE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("ufo_state", STATE_STAY);
    public static var PROP_STATE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("state_timer");
    // PORT-NOTE: C# 的 SortedDictionary 改为 Haxe Map（此处不依赖有序遍历）。
    public static var behaviours:Map<Int, UFOBehaviour> = makeBehaviours();

    static function makeBehaviours():Map<Int, UFOBehaviour>
    {
        var map:Map<Int, UFOBehaviour> = new Map();
        map.set(VARIANT_RED, new UFOBehaviourRed());
        map.set(VARIANT_GREEN, new UFOBehaviourGreen());
        map.set(VARIANT_BLUE, new UFOBehaviourBlue());
        map.set(VARIANT_RAINBOW, new UFOBehaviourRainbow());
        return map;
    }
}
