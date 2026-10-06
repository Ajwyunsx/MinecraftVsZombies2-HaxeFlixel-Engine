// Ported from: Assets/Scripts/Engine/Level/Spawns/SpawnDefinition.cs
// PORT-NOTE: 从 C# 的 SpawnDefinition.cs 中拆出的独立模块（详见 SpawnDefinition.hx 的 PORT-NOTE）。
package pvzengine.spawns;

import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.entities.SpawnParams;
import pvzengine.level.LevelEngine;
import unity.Vector3;

interface ISpawnPreviewBehaviour
{
    public function SpawnPreviewEntity(definition:SpawnDefinition, level:LevelEngine, pos:Vector3, param:SpawnParams):Null<Entity>;
    public function GetCounterTags(definition:SpawnDefinition, level:LevelEngine):Array<NamespaceID>;
}
