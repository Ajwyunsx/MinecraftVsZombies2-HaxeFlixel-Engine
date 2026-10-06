// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter2/SweetSleepPillow.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.entities.EntityTypes;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.level.LogicLevelExt;
using mvz2logic.level.LogicLevelProps;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoArtifactDefinition(VanillaArtifactNames.sweetSleepPillow)
class SweetSleepPillow extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        if (artifact.Level.IsAllEnemiesCleared() || artifact.Level.IsCleared)
        {
            artifact.SetGlowing(false);
        }
        else
        {
            artifact.SetGlowing(true);
            var level = artifact.Level;
            for (contraption in level.FindEntities(e -> e.Type == EntityTypes.PLANT && e.IsFriendlyEntity()))
            {
                contraption.HealEffects(0.33333333, contraption);
            }
        }
    }
}
