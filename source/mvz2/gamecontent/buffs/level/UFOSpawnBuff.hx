// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter5/UFOSpawnBuff.cs
// PORT-NOTE: C# HashSet<LawnGrid> → Haxe Map<LawnGrid, Bool>，传给 FilterConflictSpawnGrids 前转为数组
//（与 IndependenceDayEvent 的移植方式保持一致）。
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.enemies.UndeadFlyingObject;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.enemies.VanillaSpawnID;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.callbacks.LogicLevelCallbacks;
import mvz2logic.callbacks.LogicLevelCallbacks.WaveEnemySpawnParams;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.Buff;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.BuffDefinition;
import pvzengine.grids.LawnGrid;
import pvzengine.level.LevelEngine;
import tools.EnumerableExt;

@:autoBuffDefinition(VanillaBuffNames.Level_ufoSpawn)
class UFOSpawnBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LogicLevelCallbacks.PRE_WAVE_ENEMY_SPAWN, PreWaveEnemySpawnCallback);
    }
    private function PreWaveEnemySpawnCallback(args:WaveEnemySpawnParams, result:CallbackResult):Void
    {
        var level = args.level;
        var totalPoints:Float = result.GetValue();

        var rng = level.GetSpawnRNG();
        var possibleGrids:Map<LawnGrid, Bool> = new Map();

        for (buff in level.GetBuffs(UFOSpawnBuff))
        {
            var type = GetVariant(buff);
            var spawnLevel = GetSpawnLevel(buff);
            possibleGrids.clear();
            UndeadFlyingObject.FillUFOPossibleSpawnGrids(level, type, level.Option.RightFaction, possibleGrids);

            var possibleGridList = [for (grid in possibleGrids.keys()) grid];
            var filteredGrids = UndeadFlyingObject.FilterConflictSpawnGrids(level, possibleGridList);

            var grid = EnumerableExt.Random(filteredGrids, rng);
            // C#: UndeadFlyingObject.SpawnAtGrid(grid, type)?.Let(e => { ... });
            var entity = UndeadFlyingObject.SpawnAtGrid(grid, type);
            if (entity != null)
            {
                LogicLevelExt.TriggerEnemySpawned(level, VanillaSpawnID.GetFromEntity(VanillaEnemyID.ufo), entity);
            }
            totalPoints -= spawnLevel;

            buff.Remove();
        }
        result.SetValue(totalPoints);
    }
    public static function Prepare(level:LevelEngine, variant:Int, spawnLevel:Int):Buff
    {
        var buff = level.NewBuff(UFOSpawnBuff);
        UFOSpawnBuff.SetVariant(buff, variant);
        UFOSpawnBuff.SetSpawnLevel(buff, spawnLevel);
        level.AddBuff(buff);
        return buff;
    }
    public static function SetVariant(buff:Buff, type:Int):Void buff.SetProperty(PROP_VARIANT, type);
    public static function GetVariant(buff:Buff):Int return buff.GetProperty(PROP_VARIANT);
    public static function SetSpawnLevel(buff:Buff, value:Int):Void buff.SetProperty(PROP_SPAWN_LEVEL, value);
    public static function GetSpawnLevel(buff:Buff):Int return buff.GetProperty(PROP_SPAWN_LEVEL);
    public static var PROP_VARIANT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("variant");
    public static var PROP_SPAWN_LEVEL:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("spawn_level");
}
