// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter3/InvertedMirror.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.buffs.projectiles.InvertedMirrorBuff;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.invertedMirror)
class InvertedMirror extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_PROJECTILE_SHOT, PostProjectileShotCallback);
    }
    function PostProjectileShotCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var projectile = param.entity;
        if (!projectile.IsHostileEntity())
            return;
        var level = projectile.Level;
        var artifacts = level.GetArtifacts();
        var valid = false;
        for (artifact in artifacts)
        {
            if (artifact == null)
                continue;
            if (artifact.Definition != this)
                continue;
            artifact.Highlight();
            valid = true;
        }
        if (valid)
        {
            projectile.AddBuff(InvertedMirrorBuff);
        }
    }
}
