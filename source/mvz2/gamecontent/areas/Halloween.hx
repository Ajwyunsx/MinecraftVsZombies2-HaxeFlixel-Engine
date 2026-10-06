// Ported from: Assets/Scripts/Vanilla/GameContent/Areas/Halloween.cs
package mvz2.gamecontent.areas;

import mvz2.gamecontent.areas.VanillaAreaID.VanillaAreaNames;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.obstacles.VanillaObstacleID;
import mvz2.vanilla.level.VanillaLevelProps;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.level.LogicLevelExt;
import pvzengine.definitions.AreaDefinition;
import pvzengine.entities.Entity;
import pvzengine.grids.LawnGrid;
import pvzengine.level.LevelEngine;
import tools.RandomGenerator;
import unity.Mathf;

@:autoAreaDefinition(VanillaAreaNames.halloween)
class Halloween extends AreaDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PrepareForBattle(level:LevelEngine):Void
    {
        super.PrepareForBattle(level);
        SpawnStatues(level, VanillaLevelProps.GetStatueCount(level));
    }
    public override function PostHugeWaveEvent(level:LevelEngine):Void
    {
        super.PostHugeWaveEvent(level);
        if (VanillaLevelProps.GetStatueCount(level) <= 0)
            return;
        SpawnStatues(level, 2);
    }
    public override function PostFinalWaveEvent(level:LevelEngine):Void
    {
        ReviveStatues(level);
    }
    // PORT-NOTE: C# 关系模式 switch（case > 185 等）→ Haxe if/else 链，分支语义一致。
    public override function GetGroundY(level:LevelEngine, x:Float, z:Float):Float
    {
        if (x > 185)
        {
            return 0;
        }
        else if (x > 175)
        {
            // 地面和第一层的交界处
            return Mathf.Lerp(0, 48, (185 - x) / 10);
        }
        else if (x > 140)
        {
            return 48;
        }
        else if (x > 130)
        {
            // 第一层和第二层的交界处
            return Mathf.Lerp(48, 96, (140 - x) / 10);
        }
        else if (x > 95)
        {
            return 96;
        }
        else if (x > 85)
        {
            // 第二层和第三层的交界处
            return Mathf.Lerp(96, 144, (95 - x) / 10);
        }
        else
        {
            return 144;
        }
    }
    public function SpawnStatues(level:LevelEngine, count:Int):Void
    {
        if (count <= 0)
            return;
        var statueDef = level.Content.GetEntityDefinition(VanillaObstacleID.gargoyleStatue);
        if (statueDef == null)
            return;
        var layersToTake = LogicEntityProps.GetGridLayersToTakeOfDefinition(statueDef);
        var rng = GetRNG(level);
        if (rng == null)
        {
            rng = level.CreateRNG();
            SetRNG(level, rng);
        }
        var grids = LogicLevelExt.FindObstacleSpawnGrids(level, layersToTake, rng, count, STATUE_MIN_COLUMN, GetStatueWeight);
        for (grid in grids)
        {
            var pos = grid.GetEntityPosition();
            level.Spawn(VanillaObstacleID.gargoyleStatue, pos, null);
        }
    }
    public function ReviveStatues(level:LevelEngine):Void
    {
        for (statue in level.FindEntities(VanillaObstacleID.gargoyleStatue))
        {
            // PORT-NOTE: C# `?.Let(e => {...})` → 显式判空赋值。
            var gargoyle = level.Spawn(VanillaEnemyID.gargoyle, statue.Position, statue);
            if (gargoyle != null)
            {
                gargoyle.Health = gargoyle.GetMaxHealth() * statue.Health / statue.GetMaxHealth();
            }
            level.Spawn(VanillaEffectID.thunderBolt, statue.Position, statue);
            statue.Die();
        }
    }

    function GetStatueWeight(grid:LawnGrid):Float
    {
        return grid.Column - STATUE_MIN_COLUMN + 1;
    }
    public static function GetRNG(level:LevelEngine):Null<RandomGenerator> return level.GetProperty(PROP_RNG);
    public static function SetRNG(level:LevelEngine, rng:RandomGenerator):Void level.SetProperty(PROP_RNG, rng);

    public static var PROP_RNG:VanillaLevelPropertyMeta<RandomGenerator> = new VanillaLevelPropertyMeta<RandomGenerator>("HalloweenRNG");
    public static inline var STATUE_MIN_COLUMN:Int = 5;
}
