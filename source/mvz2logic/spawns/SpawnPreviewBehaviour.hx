// Ported from: Assets/Scripts/Logic/Spawns/SpawnPreviewBehaviour.cs
package mvz2logic.spawns;

import mvz2logic.entities.LogicEnemyProps;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.entities.SpawnParams;
import pvzengine.level.LevelEngine;
import pvzengine.spawns.ISpawnPreviewBehaviour;
import pvzengine.spawns.SpawnDefinition;
import unity.Vector3;

class SpawnPreviewBehaviour implements ISpawnPreviewBehaviour
{
	public function new()
	{
	}
	public function SpawnPreviewEntity(definition:SpawnDefinition, level:LevelEngine, pos:Vector3, param:SpawnParams):Null<Entity>
	{
		var entityId = LogicSpawnProps.GetPreviewEntity(definition);
		if (!NamespaceID.IsValid(entityId))
			return null;
		var entityVariant = LogicSpawnProps.GetPreviewVariant(definition);
		param.SetProperty(LogicEntityProps.VARIANT, entityVariant);
		return level.Spawn(entityId, pos, null, param);
	}
	public function GetCounterTags(definition:SpawnDefinition, level:LevelEngine):Array<NamespaceID>
	{
		var entityID = LogicSpawnProps.GetPreviewEntity(definition);
		if (!NamespaceID.IsValid(entityID))
			return [];
		var entityDef = level.Content.GetEntityDefinition(entityID);
		var tags = entityDef != null ? LogicEnemyProps.GetCounterTags(entityDef) : null;
		return tags != null ? tags : [];
	}
}
