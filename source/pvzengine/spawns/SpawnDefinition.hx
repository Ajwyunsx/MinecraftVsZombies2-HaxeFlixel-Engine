// Ported from: Assets/Scripts/Engine/Level/Spawns/SpawnDefinition.cs
// PORT-NOTE: C# 中 ISpawnInLevelBehaviour / ISpawnPreviewBehaviour / ISpawnEndlessBehaviour 与
// SpawnDefinition 同处一个文件，但既有上层代码（mvz2logic/spawns/*.hx、mvz2/gamecontent/spawns/*.hx）
// 以 `import pvzengine.spawns.ISpawnInLevelBehaviour` 等路径引用它们，而 Haxe 的 import 必须精确对应模块文件，
// 故这三个接口各自拆成独立模块。
package pvzengine.spawns;

import pvzengine.NamespaceID;
import pvzengine.base.Definition;
import pvzengine.definitions.EngineDefinitionTypes;
import pvzengine.entities.Entity;
import pvzengine.entities.SpawnParams;
import pvzengine.level.LevelEngine;
import tools.Ref;
import unity.Vector3;

// C# 为 abstract class
class SpawnDefinition extends Definition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    // #region 预览
    public function SpawnPreviewEntity(level:LevelEngine, pos:Vector3, param:SpawnParams):Null<Entity> return GetPreviewBehaviour().SpawnPreviewEntity(this, level, pos, param);
    public function GetCounterTags(level:LevelEngine):Array<NamespaceID> return GetPreviewBehaviour().GetCounterTags(this, level);
    // C#: protected abstract ISpawnPreviewBehaviour GetPreviewBehaviour();
    // PORT-NOTE: Haxe 无 protected；既有子类（mvz2logic/spawns/LogicSpawnDefinition.hx）的 override 未写 public，
    // 因此这里声明为 private，保证可见性一致。
    private function GetPreviewBehaviour():ISpawnPreviewBehaviour
    {
        throw 'abstract';
    }
    // #endregion

    // #region 生成
    // PORT-NOTE: C# 的 `ref float points` → tools.Ref<Float>（与既有调用点 LogicLevelExt 的用法一致）。
    public function PreSpawnAtWave(level:LevelEngine, wave:Int, maxPoints:Float, points:Ref<Float>):Void return GetInLevelBehaviour().PreSpawnAtWave(this, level, wave, maxPoints, points);
    public function PostSpawnAtWave(level:LevelEngine, wave:Int, maxPoints:Float, points:Ref<Float>):Void return GetInLevelBehaviour().PostSpawnAtWave(this, level, wave, maxPoints, points);
    public function GetWeight(level:LevelEngine):Int return GetInLevelBehaviour().GetWeight(this, level);
    public function CanSpawnInLevel(level:LevelEngine):Bool return GetInLevelBehaviour().CanSpawnInLevel(this, level);
    public function GetRandomSpawnLane(level:LevelEngine):Int return GetInLevelBehaviour().GetRandomSpawnLane(this, level);
    // C#: protected abstract ISpawnInLevelBehaviour GetInLevelBehaviour();
    private function GetInLevelBehaviour():ISpawnInLevelBehaviour
    {
        throw 'abstract';
    }
    // #endregion

    // #region 无尽
    public function CanAppearInEndless(level:LevelEngine):Bool return GetEndlessBehaviour().CanAppearInEndless(this, level);
    // C#: protected abstract ISpawnEndlessBehaviour GetEndlessBehaviour();
    private function GetEndlessBehaviour():ISpawnEndlessBehaviour
    {
        throw 'abstract';
    }
    // #endregion

    // C#: public sealed override string GetDefinitionType()
    public override function GetDefinitionType():String return EngineDefinitionTypes.SPAWN;
}
