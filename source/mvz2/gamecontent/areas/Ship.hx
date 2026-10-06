// Ported from: Assets/Scripts/Vanilla/GameContent/Areas/Ship.cs
package mvz2.gamecontent.areas;

import mvz2.gamecontent.areas.VanillaAreaID.VanillaAreaNames;
import mvz2.gamecontent.armors.VanillaArmorID;
import mvz2.gamecontent.buffs.enemies.ParatroopBuff;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import mvz2logic.armors.LogicArmorSlots;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.definitions.AreaDefinition;
import pvzengine.entities.Entity;
import pvzengine.grids.LawnGrid;
import pvzengine.level.LevelEngine;
import tools.RandomGenerator;
import unity.Mathf;
import unity.Vector3;
using tools.EnumerableExt;

@:autoAreaDefinition(VanillaAreaNames.ship)
class Ship extends AreaDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Setup(level:LevelEngine):Void
    {
        super.Setup(level);
        SetSkyOffsetSpeed(level, SKY_OFFSET_SPEED_NORMAL);
        SetRNG(level, level.CreateRNG());
    }
    public override function Update(level:LevelEngine):Void
    {
        super.Update(level);
        var skyOffsetSpeed = GetSkyOffsetSpeed(level);
        var targetSpeed = SKY_OFFSET_SPEED_NORMAL;
        if (VanillaLevelExt.IsDuringHugeWave(level))
        {
            targetSpeed = SKY_OFFSET_SPEED_FAST;
        }
        var accel = (targetSpeed - skyOffsetSpeed) * SKY_OFFSET_ACCELERATION;
        if (skyOffsetSpeed != targetSpeed)
        {
            if ((skyOffsetSpeed < targetSpeed) == (skyOffsetSpeed + accel > targetSpeed))
            {
                skyOffsetSpeed = targetSpeed;
            }
            else
            {
                skyOffsetSpeed += accel;
            }
        }
        SetSkyOffsetSpeed(level, skyOffsetSpeed);
        LogicLevelExt.SetModelAnimatorFloat(level, "SkyOffsetSpeed", skyOffsetSpeed);
    }
    public override function PostHugeWaveEvent(level:LevelEngine):Void
    {
        super.PostHugeWaveEvent(level);
        SpawnParatroops(level, 3);
    }
    public static function SpawnParatroops(level:LevelEngine, count:Int):Void
    {
        var valid:Array<LawnGrid> = [];
        var weights:Array<Int> = [];

        for (col in SPAWNER_MIN_COLUMN...level.GetMaxColumnCount())
        {
            for (lane in 0...level.GetMaxLaneCount())
            {
                var grid = level.GetGrid(col, lane);
                if (grid != null)
                {
                    valid.push(grid);
                    weights.push(GetParatroopWeight(col));
                }
            }
        }
        // PORT-NOTE: C# Mathf.Clamp(int,int,int) 重载在 Haxe 中改名为 Mathf.ClampInt（count 为 Int）。
        count = Mathf.ClampInt(count, 0, valid.length);
        if (count <= 0)
            return;

        var rng = GetRNG(level);
        var weightArray = weights;
        // TODO-PORT: Tools 扩展方法 WeightedRandomTake（Engine 子模块源码缺失，需由 pvzengine 工作包提供）；LINQ Take → Array.slice。
        var grids = rng != null ? valid.WeightedRandomTake(weightArray, count, rng) : valid.slice(0, count);
        for (grid in grids)
        {
            // TODO-PORT: Tools 扩展方法 Random(this NamespaceID[], RandomGenerator)。
            var entityToSpawn = rng != null ? GetParatroopToSpawn(rng) : VanillaEnemyID.zombie;
            SpawnParatroopOnGrid(level, entityToSpawn, grid);
        }
        LogicLevelExt.PlaySound(level, VanillaSoundID.wind);
    }
    public static function SpawnParatroopOnGrid(level:LevelEngine, enemyID:NamespaceID, grid:LawnGrid):Null<Entity>
    {
        var position = grid.GetEntityPosition() + Vector3.up * 600;
        // PORT-NOTE: C# `?.Let(e => {...})` → 显式判空块。
        var entity = level.Spawn(enemyID, position, null);
        if (entity != null)
        {
            entity.EquipArmorTo(LogicArmorSlots.shield, VanillaArmorID.umbrellaShield);
            entity.AddBuff(ParatroopBuff);
        }
        return entity;
    }
    static function GetParatroopWeight(column:Int):Int
    {
        return column - SPAWNER_MIN_COLUMN + 1;
    }
    static function GetParatroopToSpawn(rng:RandomGenerator):NamespaceID
    {
        // TODO-PORT: Tools 扩展方法 Random(this NamespaceID[], RandomGenerator)。
        return paratroopsToSpawn.Random(rng);
    }
    public static function GetSkyOffsetSpeed(level:LevelEngine):Float return level.GetProperty(PROP_SKY_OFFSET_SPEED);
    public static function SetSkyOffsetSpeed(level:LevelEngine, value:Float):Void level.SetProperty(PROP_SKY_OFFSET_SPEED, value);
    public static function GetRNG(level:LevelEngine):Null<RandomGenerator> return level.GetProperty(PROP_RNG);
    public static function SetRNG(level:LevelEngine, rng:RandomGenerator):Void level.SetProperty(PROP_RNG, rng);

    public static var paratroopsToSpawn:Array<NamespaceID> = [
        VanillaEnemyID.zombie,
        VanillaEnemyID.leatherCappedZombie,
        VanillaEnemyID.ironHelmettedZombie
    ];
    public static inline var SPAWNER_MIN_COLUMN:Int = 5;
    public static inline var SKY_OFFSET_SPEED_NORMAL:Float = 1;
    public static inline var SKY_OFFSET_SPEED_FAST:Float = 10;
    public static inline var SKY_OFFSET_ACCELERATION:Float = 0.1;
    public static var PROP_RNG:VanillaLevelPropertyMeta<RandomGenerator> = new VanillaLevelPropertyMeta<RandomGenerator>("SpawnerRNG");
    public static var PROP_SKY_OFFSET_SPEED:VanillaLevelPropertyMeta<Float> = new VanillaLevelPropertyMeta<Float>("sky_offset_speed");
}
