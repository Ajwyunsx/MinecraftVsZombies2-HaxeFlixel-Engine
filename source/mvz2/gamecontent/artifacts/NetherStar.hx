// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter3/NetherStar.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.netherStar)
class NetherStar extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_USE_STARSHARD, PostUseStarshardCallback);
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        var number = artifact.GetNumber();
        if (number < 0)
        {
            number = 0;
            artifact.SetNumber(number);
        }
        artifact.SetGlowing(number == MAX_NUMBER - 1);
    }
    function PostUseStarshardCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var contraption = param.entity;
        var level = contraption.Level;
        var artifacts = level.GetArtifacts();
        for (artifact in artifacts)
        {
            if (artifact == null)
                continue;
            if (artifact.Definition != this)
                continue;
            var number = artifact.GetNumber();
            number++;
            if (number >= MAX_NUMBER)
            {
                artifact.Highlight();
                number -= MAX_NUMBER;
                contraption.Spawn(VanillaPickupID.starshard, contraption.Position);
            }
            artifact.SetNumber(number);
        }
    }
    static inline var MAX_NUMBER:Int = 4;
}
