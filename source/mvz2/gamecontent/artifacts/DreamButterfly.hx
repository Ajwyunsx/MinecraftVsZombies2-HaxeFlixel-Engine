// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter2/DreamButterfly.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID;
import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.buffs.contraptions.DreamButterflyShieldBuff;
import mvz2logic.artifacts.ArtifactDefinition;
import mvz2logic.callbacks.LogicLevelCallbacks;
import mvz2logic.callbacks.LogicLevelCallbacks.PostPlaceEntityParams;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.entities.EntityTypes;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.dreamButterfly)
class DreamButterfly extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LogicLevelCallbacks.POST_PLACE_ENTITY, PostEntityPlaceCallback);
    }
    function PostEntityPlaceCallback(param:PostPlaceEntityParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        if (entity.Type != EntityTypes.PLANT)
            return;
        var level = entity.Level;
        var artifact = level.GetArtifact(ID);
        if (artifact == null)
            return;
        entity.AddBuff(DreamButterflyShieldBuff);
        artifact.Highlight();
    }
    public static var ID:NamespaceID = VanillaArtifactID.dreamButterfly;
}
