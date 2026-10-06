// Ported from: Assets/Scripts/Logic/Spawns/SpawnEndlessBehaviour.cs
package mvz2logic.spawns;

import Lambda;
import mvz2logic.level.LogicAreaTags;
import pvzengine.level.LevelEngine;
import pvzengine.spawns.ISpawnEndlessBehaviour;
import pvzengine.spawns.SpawnDefinition;

class SpawnEndlessBehaviour implements ISpawnEndlessBehaviour
{
	public function new()
	{
	}
	public function CanAppearInEndless(definition:SpawnDefinition, level:LevelEngine):Bool
	{
		if (LogicSpawnProps.IsNoEndless(definition) || LogicSpawnProps.GetSpawnLevel(definition) <= 0)
			return false;
		var excludedAreaTags = LogicSpawnProps.GetExcludedAreaTags(definition);
		var areaDef = level.AreaDefinition;
		if (Lambda.exists(areaDef.GetAreaTags(), function(t) return excludedAreaTags.contains(t)))
			return false;
		return true;
	}
}
