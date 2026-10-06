// Ported from: Assets/Scripts/Vanilla/GameContent/Spawns/UFOSpawnInLevelBehaviour.cs
package mvz2.gamecontent.spawns;

import mvz2.gamecontent.areas.VanillaAreaID;
import mvz2.gamecontent.buffs.level.UFOSpawnBuff;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.enemies.UndeadFlyingObject;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicStageProps;
import pvzengine.spawns.ISpawnInLevelBehaviour;
import mvz2logic.spawns.LogicSpawnProps;
import pvzengine.level.LevelEngine;
import pvzengine.spawns.SpawnDefinition;
import tools.RandomGenerator;
import tools.Ref;
import unity.Mathf;
import unity.Vector3;

class UFOSpawnInLevelBehaviour implements ISpawnInLevelBehaviour
{
    public function new(intervalWaves:Int = 5, maxCount:Int = 10)
    {
        IntervalWaves = intervalWaves;
        MaxCount = maxCount;
    }

    // PORT-NOTE: C# `ref float points` → tools.Ref<Float>（Haxe 无 ref 基本类型参数）。
    public function PreSpawnAtWave(definition:SpawnDefinition, level:LevelEngine, wave:Int, maxPoints:Float, points:Ref<Float>):Void
    {
    }
    public function PostSpawnAtWave(definition:SpawnDefinition, level:LevelEngine, wave:Int, maxPoints:Float, points:Ref<Float>):Void
    {
        var minWave = LogicSpawnProps.GetMinSpawnWave(definition);
        if (wave <= minWave)
            return;
        var finalWave = level.IsFinalWave(wave);
        if (finalWave)
            return;
        var intervalWaves = IntervalWaves;
        if (intervalWaves > 1)
        {
            var flagModular = wave % level.GetWavesPerFlag();
            var modular = flagModular % intervalWaves;
            if (modular == (intervalWaves - 1))
            {
                PrepareUFO(definition, level, maxPoints);
            }
        }
        else
        {
            PrepareUFO(definition, level, maxPoints);
        }
    }
    function PrepareUFO(definition:SpawnDefinition, level:LevelEngine, totalPoints:Float):Void
    {
        var rng = new RandomGenerator(level.GetSpawnRNG().Next());
        // PORT-NOTE: C# Mathf.Min(int,int) 重载在 Haxe 中改名为 Mathf.MinInt（count 需为 Int 供 0...count 使用）。
        var count = Mathf.MinInt(MaxCount, Mathf.CeilToInt(totalPoints * 0.3333333));
        var entityVariant = LogicSpawnProps.GetSpawnEntityVariant(definition);

        var random = entityVariant < 0;
        var variantPool:Array<Int> = [];
        var startIndex = 0;
        if (random)
        {
            UndeadFlyingObject.FillUFOVariantRandomPool(level, level.Option.RightFaction, variantPool);

            if (variantPool.length <= 0)
            {
                return;
            }
            startIndex = rng.Next(variantPool.length);
        }
        for (i in 0...count)
        {
            var variant = entityVariant;
            if (random)
            {
                var typeIndex = (startIndex + i) % variantPool.length;
                variant = variantPool[typeIndex];

                if (rng.Next(100) < 10)
                {
                    variant = UndeadFlyingObject.VARIANT_RAINBOW;
                }
            }
            if (level.AreaID == VanillaAreaID.ship)
            {
                var x = rng.Next(BACKGROUND_MIN_X, BACKGROUND_MAX_X);
                var z = rng.Next(BACKGROUND_MIN_Z, BACKGROUND_MAX_Z);
                var y = rng.Next(BACKGROUND_MIN_Y, BACKGROUND_MAX_Y);
                var pos = new Vector3(x, y, z);
                var background = level.Spawn(VanillaEffectID.ufoBackground, pos, null);
                var speedMultiplier:Float = 1;
                // 若关卡时间较短则将一切加快，因此背景的UFO也会变快。
                var minLevelTime = Mathf.Min(LogicStageProps.GetWaveMaxSeconds(level), LogicStageProps.GetWaveAdvanceSeconds(level));
                if (minLevelTime <= TARGET_BACKGROUND_TIME)
                {
                    speedMultiplier = TARGET_BACKGROUND_TIME / minLevelTime;
                }
                if (background != null)
                {
                    var velocity = BACKGROUND_FLY_DIRECTION * rng.Next(BACKGROUND_MIN_SPEED, BACKGROUND_MAX_SPEED) * speedMultiplier;
                    background.Velocity = velocity;
                    LogicEntityProps.SetVariant(background, variant);
                }
            }
            UFOSpawnBuff.Prepare(level, variant, LogicSpawnProps.GetSpawnLevel(definition));
        }
        LogicLevelExt.PlaySound(level, VanillaSoundID.ufoAlert);
    }
    public function GetRandomSpawnLane(definition:SpawnDefinition, level:LevelEngine):Int
    {
        return level.GetRandomEnemySpawnLane();
    }
    public function CanSpawnInLevel(definition:SpawnDefinition, level:LevelEngine):Bool return false;
    public function GetWeight(definition:SpawnDefinition, level:LevelEngine):Int return 0;
    public static inline var TARGET_BACKGROUND_TIME:Float = 6;

    // PORT-NOTE: 常量声明顺序按依赖关系调整，保证静态初始化时依赖项已就绪（C# 中为编译期 const，顺序无关）。
    public static inline var BACKGROUND_MIN_X:Float = 520;
    public static inline var BACKGROUND_MAX_X:Float = 720;
    public static inline var BACKGROUND_MIN_Y:Float = -160;
    public static inline var BACKGROUND_MAX_Y:Float = -120;
    public static inline var BACKGROUND_MIN_Z:Float = 40;
    public static inline var BACKGROUND_MAX_Z:Float = 80;
    public static inline var BACKGROUND_TIMEOUT:Int = 120;
    public static var BACKGROUND_MIN_SPEED:Float = (600 - (BACKGROUND_MIN_Y + BACKGROUND_MIN_Z)) / BACKGROUND_TIMEOUT;
    public static var BACKGROUND_MAX_SPEED:Float = BACKGROUND_MIN_SPEED * 1.25;
    public static var BACKGROUND_FLY_DIRECTION:Vector3 = new Vector3(0.2, 0, 1);
    public var IntervalWaves(default, null):Int;
    public var MaxCount(default, null):Int;
}
