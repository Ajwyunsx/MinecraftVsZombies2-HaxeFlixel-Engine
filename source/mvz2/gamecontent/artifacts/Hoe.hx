// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter1/Hoe.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID;
import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.callbacks.LevelCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.grids.LogicGridProps;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.hoe)
class Hoe extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LevelCallbacks.POST_LEVEL_START, PostLevelStartCallback);
        AddTrigger(LevelCallbacks.POST_ENEMY_SPAWNED, PostEnemySpawnedCallback);
    }
    function PostLevelStartCallback(param:LevelCallbackParams, result:CallbackResult):Void
    {
        var level = param.level;
        var artifacts = level.GetArtifacts();
        for (artifact in artifacts)
        {
            if (artifact == null)
                continue;
            if (artifact.Definition.GetID() != VanillaArtifactID.hoe)
                continue;
            artifact.SetInactive(false);
        }
    }
    function PostEnemySpawnedCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var enemy = param.entity;
        var level = enemy.Level;
        var artifacts = level.GetArtifacts();
        for (artifact in artifacts)
        {
            if (artifact == null)
                continue;
            if (artifact.Definition.GetID() != VanillaArtifactID.hoe)
                continue;
            if (artifact.IsInactive())
                continue;
            var targetLane = enemy.GetLane();
            var targetColumn = TARGET_COLUMN;
            var grid = level.GetGrid(targetColumn, targetLane);
            while (grid != null && !grid.IsLand())
            {
                grid = level.GetGrid(grid.Column - 1, grid.Lane);
            }
            if (grid == null)
                continue;
            var pos = grid.GetEntityPosition();
            // PORT-NOTE: C# `?.Let(...)` 嵌套写法 → 显式判空块。
            var hoe = level.Spawn(VanillaEffectID.hoe, pos, null);
            if (hoe != null)
            {
                var smoke = level.Spawn(VanillaEffectID.smoke, pos, null);
                if (smoke != null)
                {
                    hoe.SetSize(smoke.GetSize());
                }
            }
            artifact.Highlight();
            artifact.SetInactive(true);
            break;
        }
    }
    public static inline var TARGET_COLUMN:Int = 3;
}
