// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/ArtifactPickup/CollectBehaviour_Artifact.cs
package mvz2.gamecontent.pickups;

import mvz2.gamecontent.artifacts.VanillaArtifactID;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2logic.Global;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.localization.LogicStrings;
import pvzengine.entities.Entity;
using mvz2.vanilla.pickups.VanillaPickupProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.pickupCollectArtifact)
class CollectBehaviour_Artifact extends CollectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function CanCollect(pickup:Entity):Bool
    {
        return true;
    }
    public override function PostCollect(pickup:Entity):Void
    {
        super.PostCollect(pickup);
        var level = pickup.Level;
        var artifactID = pickup.GetPickupContentID();
        var saves = Global.Saves;
        if (artifactID != null && !saves.IsArtifactUnlocked(artifactID))
        {
            var unlockID = VanillaArtifactID.GetUnlockID(artifactID);
            saves.Unlock(unlockID);
            saves.SaveToFile(); // 获得制品后保存游戏。
            level.ShowAdvice(LogicStrings.CONTEXT_ADVICE, VanillaStrings.ADVICE_YOU_FOUND_A_NEW_ARTIFACT, 0, 150, []);
        }
        level.PlaySoundIfNotNull(pickup.GetCollectSound());
        level.Spawn(VanillaEffectID.starParticles, pickup.Position, pickup);
        pickup.Remove();
    }
}
