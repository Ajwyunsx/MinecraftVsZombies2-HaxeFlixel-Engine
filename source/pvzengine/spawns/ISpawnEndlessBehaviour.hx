// Ported from: Assets/Scripts/Engine/Level/Spawns/SpawnDefinition.cs
// PORT-NOTE: 从 C# 的 SpawnDefinition.cs 中拆出的独立模块（详见 SpawnDefinition.hx 的 PORT-NOTE）。
package pvzengine.spawns;

import pvzengine.level.LevelEngine;

interface ISpawnEndlessBehaviour
{
    public function CanAppearInEndless(definition:SpawnDefinition, level:LevelEngine):Bool;
}
