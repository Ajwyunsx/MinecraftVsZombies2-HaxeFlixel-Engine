// Ported from: Assets/Scripts/Engine/Level/Spawns/SpawnDefinition.cs
// PORT-NOTE: 从 C# 的 SpawnDefinition.cs 中拆出的独立模块（详见 SpawnDefinition.hx 的 PORT-NOTE）。
package pvzengine.spawns;

import pvzengine.level.LevelEngine;
import tools.Ref;

interface ISpawnInLevelBehaviour
{
    // PORT-NOTE: C# 的 `ref float points` → tools.Ref<Float>（与既有实现 UFOSpawnInLevelBehaviour / SpawnInLevelBehaviour 一致）。
    public function PreSpawnAtWave(definition:SpawnDefinition, level:LevelEngine, wave:Int, maxPoints:Float, points:Ref<Float>):Void;
    public function PostSpawnAtWave(definition:SpawnDefinition, level:LevelEngine, wave:Int, maxPoints:Float, points:Ref<Float>):Void;
    public function GetWeight(definition:SpawnDefinition, level:LevelEngine):Int;
    public function CanSpawnInLevel(definition:SpawnDefinition, level:LevelEngine):Bool;
    public function GetRandomSpawnLane(definition:SpawnDefinition, level:LevelEngine):Int;
}
