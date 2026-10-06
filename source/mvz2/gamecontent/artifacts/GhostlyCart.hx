// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter6/GhostlyCart.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import tools.TimerHelper;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.level.LogicLevelProps;
using mvz2.vanilla.level.VanillaLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.ghostlyCart)
class GhostlyCart extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostAdd(artifact:Artifact):Void
    {
        super.PostAdd(artifact);
        artifact.SetNumber(MAX_COOLDOWN_SECONDS);
        artifact.SetSecondTimer(TimerHelper.NewSecondTimer(1));
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        if (artifact.Level.IsAllEnemiesCleared() || artifact.Level.IsCleared)
            return;

        var secondTimer = artifact.GetSecondTimer();
        if (secondTimer == null)
        {
            secondTimer = TimerHelper.NewSecondTimer(1);
            artifact.SetSecondTimer(secondTimer);
        }

        if (secondTimer.RunToExpired())
        {
            var number = artifact.GetNumber();
            number--;
            if (number <= 0)
            {
                number = MAX_COOLDOWN_SECONDS;
                artifact.Level.RefreshCarts();
                artifact.Highlight();
            }
            artifact.SetNumber(number);
            secondTimer.Reset();
        }
    }
    public static inline var MAX_COOLDOWN_SECONDS:Int = 180;
}
