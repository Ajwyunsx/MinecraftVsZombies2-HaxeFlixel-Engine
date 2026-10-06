// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter1/Almanac.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID;
import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
using mvz2logic.level.LogicLevelExt;
using mvz2logic.level.LogicStageProps;

@:autoArtifactDefinition(VanillaArtifactNames.almanac)
class Almanac extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LevelCallbacks.POST_LEVEL_START, PostLevelStartCallback);
    }
    function PostLevelStartCallback(param:LevelCallbackParams, result:CallbackResult):Void
    {
        var level = param.level;
        for (artifact in level.GetArtifacts())
        {
            if (artifact == null || artifact.Definition == null || artifact.Definition.GetID() != ID)
                continue;
            var enemies = level.GetEnemyPool();
            if (enemies == null)
                continue;
            // PORT-NOTE: C# int 除法 → Std.int 保证同语义。
            var energy = Std.int(enemies.length / 2) * 25.0;
            if (energy <= 0)
                continue;
            artifact.Highlight();
            level.AddEnergy(energy);
            level.PlaySound(VanillaSoundID.points);
        }
    }
    public static var ID:NamespaceID = VanillaArtifactID.almanac;
}
