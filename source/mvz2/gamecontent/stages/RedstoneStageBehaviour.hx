// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/RedstoneStageBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.buffs.enemies.RedstoneCarrierBuff;
import mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageBehaviour;
import pvzengine.level.StageDefinition;
import tools.RandomGenerator;
import unity.Mathf;

class RedstoneDropStageBehaviour extends StageBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
    }
    override public function Start(level:LevelEngine):Void
    {
        super.Start(level);
        SetRestoneRNG(level, level.CreateRNG());
        SetRedstoneChance(level, MIN_CHANCE);
    }
    override public function PostWave(level:LevelEngine, wave:Int):Void
    {
        super.PostWave(level, wave);
        var increament = VanillaDifficultyLevelProps.GetRedstoneCarrierCounterIncreament(level);
        AddRedstoneChance(level, increament);
    }
    override public function PostEnemySpawned(entity:Entity):Void
    {
        super.PostEnemySpawned(entity);
        if (VanillaEnemyProps.HasNoReward(entity))
            return;
        var level = entity.Level;
        var chance = GetRedstoneChance(level);
        var rng = GetOrCreateRedstoneRNG(level);
        var value = rng.Next(100);
        if (value < chance)
        {
            entity.AddBuff(RedstoneCarrierBuff);
            chance = Mathf.Max(MIN_CHANCE, chance + CHANCE_REDUCTION);
            SetRedstoneChance(level, chance);
        }
    }
    public static function GetOrCreateRedstoneRNG(level:LevelEngine):RandomGenerator
    {
        var rng = GetRedstoneRNG(level);
        if (rng == null)
        {
            rng = level.CreateRNG();
            SetRestoneRNG(level, rng);
        }
        return rng;
    }
    public static function GetRedstoneRNG(level:LevelEngine):Null<RandomGenerator>
    {
        return level.GetProperty(PROP_REDSTONE_RNG);
    }
    public static function SetRestoneRNG(level:LevelEngine, value:RandomGenerator):Void
    {
        level.SetProperty(PROP_REDSTONE_RNG, value);
    }
    public static function GetRedstoneChance(level:LevelEngine):Float
    {
        return level.GetProperty(PROP_REDSTONE_CHANCE);
    }
    public static function SetRedstoneChance(level:LevelEngine, value:Float):Void
    {
        level.SetProperty(PROP_REDSTONE_CHANCE, value);
    }
    public static function AddRedstoneChance(level:LevelEngine, value:Float):Void
    {
        SetRedstoneChance(level, GetRedstoneChance(level) + value);
    }
    public static inline var PROP_REGION:String = "redstone_drop_stage";
    @:levelPropertyRegistry(PROP_REGION)
    public static var PROP_REDSTONE_RNG:VanillaLevelPropertyMeta<RandomGenerator> = new VanillaLevelPropertyMeta<RandomGenerator>("RedstoneRNG");
    @:levelPropertyRegistry(PROP_REGION)
    public static var PROP_REDSTONE_CHANCE:VanillaLevelPropertyMeta<Float> = new VanillaLevelPropertyMeta<Float>("RedstoneChance");
    public static inline var MIN_CHANCE:Int = -15;
    public static inline var CHANCE_REDUCTION:Int = -125;
}
