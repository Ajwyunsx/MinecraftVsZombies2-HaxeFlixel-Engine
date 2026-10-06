// Ported from: Assets/Scripts/Vanilla/GameContent/Areas/Mausoleum.cs
package mvz2.gamecontent.areas;

import mvz2.gamecontent.areas.VanillaAreaID.VanillaAreaNames;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.obstacles.MonsterSpawner;
import mvz2.gamecontent.obstacles.VanillaObstacleID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.level.VanillaLevelProps;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.definitions.AreaDefinition;
import pvzengine.grids.LawnGrid;
import pvzengine.level.LevelEngine;
import tools.RandomGenerator;
using tools.EnumerableExt;

@:autoAreaDefinition(VanillaAreaNames.mausoleum)
class Mausoleum extends AreaDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PrepareForBattle(level:LevelEngine):Void
    {
        super.PrepareForBattle(level);
        SpawnSpawners(level, VanillaLevelProps.GetSpawnerCount(level));
    }
    public override function PostHugeWaveEvent(level:LevelEngine):Void
    {
        super.PostHugeWaveEvent(level);
        if (VanillaLevelProps.GetSpawnerCount(level) <= 0)
            return;
        SpawnSpawners(level, 2);
    }
    public function SpawnSpawners(level:LevelEngine, count:Int):Void
    {
        if (count <= 0)
            return;
        var statueDef = level.Content.GetEntityDefinition(VanillaObstacleID.monsterSpawner);
        if (statueDef == null)
            return;
        var layersToTake = LogicEntityProps.GetGridLayersToTakeOfDefinition(statueDef);
        var rng = GetRNG(level);
        if (rng == null)
        {
            rng = level.CreateRNG();
            SetRNG(level, rng);
        }
        var grids = LogicLevelExt.FindObstacleSpawnGrids(level, layersToTake, rng, count, SPAWNER_MIN_COLUMN, GetSpawnerWeight);
        for (grid in grids)
        {
            var pos = grid.GetEntityPosition();
            // PORT-NOTE: C# `?.Let(e => {...})` → 显式判空块。
            var e = level.Spawn(VanillaObstacleID.monsterSpawner, pos, null);
            if (e != null)
            {
                var entityToSpawn = GetEntityToSpawn(rng);
                MonsterSpawner.SetEntityToSpawn(e, entityToSpawn);

                var param = VanillaEntityExt.GetSpawnParams(e);
                param.SetProperty(LogicEntityProps.UPDATE_BEFORE_GAME, true);
                e.Spawn(VanillaEffectID.spawnerAppearEmbers, e.GetCenter(), param);
                LogicEntityExt.PlaySound(e, VanillaSoundID.odd);
            }
        }
    }
    function GetEntityToSpawn(rng:RandomGenerator):NamespaceID
    {
        // TODO-PORT: Tools 扩展方法 Random(this NamespaceID[], RandomGenerator)（Engine 子模块源码缺失，需由 pvzengine 工作包提供）。
        return entitiesToSpawn.Random(rng);
    }
    function GetSpawnerWeight(grid:LawnGrid):Float
    {
        return grid.Column - SPAWNER_MIN_COLUMN + 1;
    }
    public static function GetRNG(level:LevelEngine):Null<RandomGenerator> return level.GetProperty(PROP_RNG);
    public static function SetRNG(level:LevelEngine, rng:RandomGenerator):Void level.SetProperty(PROP_RNG, rng);
    public static var PROP_RNG:VanillaLevelPropertyMeta<RandomGenerator> = new VanillaLevelPropertyMeta<RandomGenerator>("SpawnerRNG");
    public static var entitiesToSpawn:Array<NamespaceID> = [
        VanillaEnemyID.zombie,
        VanillaEnemyID.leatherCappedZombie,
        VanillaEnemyID.ironHelmettedZombie
    ];
    public static inline var SPAWNER_MIN_COLUMN:Int = 5;
}
