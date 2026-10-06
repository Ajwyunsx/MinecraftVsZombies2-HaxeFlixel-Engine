// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter4/Lightbomb.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.damages.DamageEffectList;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.entities.LogicEntityProps;
using mvz2logic.level.LogicLevelExt;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoArtifactDefinition(VanillaArtifactNames.lightbomb)
class Lightbomb extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_CONTRAPTION_DETONATE, PostContraptionDetonateCallback);
    }
    public function PostContraptionDetonateCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var contraption = param.entity;
        var level = contraption.Level;
        if (!contraption.IsFriendlyEntity())
            return;
        for (artifact in level.GetArtifacts())
        {
            if (artifact == null || artifact.Definition != this)
                continue;
            var damage = contraption.GetCost();
            if (damage <= 0)
                continue;
            artifact.Highlight();

            for (enemy in level.FindEntities(e -> e.IsVulnerableEntity() && e.IsHostile(contraption)))
            {
                enemy.TakeDamage(damage, new DamageEffectList([VanillaDamageEffects.IGNORE_ARMOR, VanillaDamageEffects.LIGHT, VanillaDamageEffects.MUTE]), contraption);
            }
            contraption.Spawn(VanillaEffectID.stunningFlash, contraption.GetCenter());
            contraption.PlaySound(VanillaSoundID.evocation);
        }
    }
}
