// Ported from: Assets/Scripts/Logic/Spawns/SpawnInLevelBehaviour.cs
package mvz2logic.spawns;

import Lambda;
import mvz2logic.level.LogicLevelExt;
import pvzengine.level.LevelEngine;
import pvzengine.spawns.ISpawnInLevelBehaviour;
import pvzengine.spawns.SpawnDefinition;
import unity.Mathf;

class SpawnInLevelBehaviour implements ISpawnInLevelBehaviour
{
	public function new()
	{
	}

	public function PreSpawnAtWave(definition:SpawnDefinition, level:LevelEngine, wave:Int, maxPoints:Float, points:tools.Ref<Float>):Void
	{
	}
	public function PostSpawnAtWave(definition:SpawnDefinition, level:LevelEngine, wave:Int, maxPoints:Float, points:tools.Ref<Float>):Void
	{
	}
	public function GetRandomSpawnLane(definition:SpawnDefinition, level:LevelEngine):Int
	{
		var allLanes = LogicLevelExt.GetAllLanes(level);
		var resultLanes = allLanes;

		var isStartWaves = level.CurrentFlag <= 0 && level.CurrentWave <= 3;
		if (isStartWaves || !LogicSpawnProps.SpawnInWater(definition))
		{
			var waterLanes = LogicLevelExt.GetWaterLanes(level);
			// C#: resultLanes = resultLanes.Except(waterLanes);
			resultLanes = Lambda.filter(resultLanes, function(l) return !waterLanes.contains(l));
		}
		if (isStartWaves || !LogicSpawnProps.SpawnInAir(definition))
		{
			var airLanes = LogicLevelExt.GetAirLanes(level);
			// C#: resultLanes = resultLanes.Except(airLanes);
			resultLanes = Lambda.filter(resultLanes, function(l) return !airLanes.contains(l));
		}

		if (resultLanes.length <= 0)
		{
			resultLanes = allLanes;
		}
		return level.GetRandomEnemySpawnLane(resultLanes);
	}
	public function CanSpawnInLevel(definition:SpawnDefinition, level:LevelEngine):Bool
	{
		return LogicSpawnProps.GetSpawnLevel(definition) > 0;
	}
	public function GetWeight(definition:SpawnDefinition, level:LevelEngine):Int
	{
		var weight = LogicSpawnProps.GetWeightBase(definition);
		var decayStart = LogicSpawnProps.GetWeightDecayStartFlag(definition);
		var decayEnd = LogicSpawnProps.GetWeightDecayEndFlag(definition);
		var decay = LogicSpawnProps.GetWeightDecayPerFlag(definition);

		var decayFlags = Mathf.ClampInt(level.CurrentFlag, decayStart, decayEnd) - decayStart;
		return weight - decay * decayFlags;
	}
}
